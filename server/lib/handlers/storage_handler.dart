import 'dart:async';
import 'dart:convert';
import 'dart:io' show Directory, File;

import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/shelf_multipart.dart';
import 'package:path/path.dart' as path;
import '../database/database.dart';

class StorageHandler {
  final AppDatabase _db = AppDatabase.instance;
  final String _uploadDir = 'uploads';

  StorageHandler() {
    // Create uploads directory if it doesn't exist
    final dir = Directory(_uploadDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  /// POST /api/storage/upload
  /// Upload a file (requires authentication)
  Future<Response> upload(Request request) async {
    try {
      // Add a top-level try/catch so we can log errors (prints will show in
      // cloud providers' logs) for debugging and to return a proper error
      // response instead of letting the process crash.
      
      final userId = request.context['userId'] as int?;
      if (userId == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Not authenticated'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final contentType = request.headers['content-type'];
      if (contentType == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Missing Content-Type header'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Support multipart/form-data uploads (preferred) and legacy JSON base64 uploads
      String? fileName;
      String? fileContentType;
      List<int>? fileBytes;

      // Try multipart/form-data first using shelf_multipart
      if (request.multipart() case var multipart?) {
        // Read all parts — we capture the first file part, and drain the
        // rest to ensure the multipart stream is fully consumed. Not
        // consuming all parts can cause client/proxy timeouts or errors.
        bool foundFile = false;
        await for (final part in multipart.parts) {
          final contentDisposition = part.headers['content-disposition'] ?? '';
          final partContentType = part.headers['content-type'];
          // Extract filename from content-disposition header
          final fileNameMatch = RegExp(r'filename="?([^";\n]+)"?').firstMatch(contentDisposition);
          if (fileNameMatch != null && !foundFile) {
            foundFile = true;
            fileName = fileNameMatch.group(1);
            fileContentType = partContentType;
            fileBytes = await part.readBytes();
            // continue iterating to drain remaining parts rather than break
            continue;
          }

          // For non-file parts or additional file parts, ensure we read them
          // to free the underlying request stream resources.
          try {
            await part.readBytes();
          } catch (_) {
            // ignore errors while draining non-essential parts
          }
        }
        
        if (fileName == null || fileBytes == null) {
          return Response.badRequest(
            body: jsonEncode({'error': 'No file found in multipart upload'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        
        // Detect actual content type from magic bytes if not provided
        final detectedType = _detectContentTypeFromBytes(fileBytes);
        fileContentType = detectedType ?? fileContentType ?? 'application/octet-stream';
        
      } else if (contentType.toLowerCase().contains('application/json')) {
        final bodyString = await request.readAsString();
        final Map<String, dynamic> jsonBody = jsonDecode(bodyString) as Map<String, dynamic>;
        final base64Data = jsonBody['data'] as String?;
        final uploadedFileName = jsonBody['file_name'] as String?;
        final uploadedContentType = jsonBody['content_type'] as String?;
        if (base64Data == null || uploadedFileName == null) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Invalid JSON upload payload'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        if (base64Data.trim().isEmpty || uploadedFileName.trim().isEmpty) {
          return Response.badRequest(
            body: jsonEncode({'error': 'No file provided'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        fileName = uploadedFileName;
        fileContentType = uploadedContentType;
        try {
          fileBytes = base64Decode(base64Data);
        } catch (e) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Invalid base64 data'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        
        // Detect actual content type from magic bytes
        final detectedType = _detectContentTypeFromBytes(fileBytes);
        fileContentType = detectedType ?? fileContentType;
        
        // If we're dealing with a base64 encoded small JSON payload that is
        // actually a placeholder string (e.g., "file=[$file.xyz]"), reject it
        // to avoid saving invalid text as files. This matches the behavior of
        // the clients that send the real file bytes.
        if (fileBytes.isNotEmpty && fileContentType == 'text/plain') {
          final contentStr = utf8.decode(fileBytes, allowMalformed: true);
          if (contentStr.startsWith('file=[') || contentStr.startsWith('file=')) {
            return Response.badRequest(
              body: jsonEncode({'error': 'Invalid file payload; upload raw file or send base64 data'}),
              headers: {'Content-Type': 'application/json'},
            );
          }
        }
        
      } else {
        return Response.badRequest(
          body: jsonEncode({'error': 'Unsupported Content-Type. Use multipart/form-data or application/json.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // At this point fileName and fileBytes are guaranteed to be non-null
      final resolvedFileName = fileName;
      final resolvedBytes = fileBytes;
      if (resolvedBytes.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'No file provided'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      
      // Generate unique filename and pick a sane extension based on content-type
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final providedExt = path.extension(resolvedFileName).toLowerCase();
      final inferredExt = _extensionForContentType(fileContentType ?? 'application/octet-stream');
      final useExt = (providedExt.isEmpty || providedExt == '.bin') ? inferredExt : providedExt;
      final uniqueFileName = '${userId}_$timestamp$useExt';
      final filePath = path.join(_uploadDir, uniqueFileName);

      // Save file
      final file = File(filePath);
      await file.writeAsBytes(resolvedBytes);

      final fileSize = await file.length();

      // Get base URL from request headers or use default
      final host = request.headers['host'] ?? 'localhost:8080';
      final scheme = request.headers['x-forwarded-proto'] ?? 'http';
      final fileUrl = '$scheme://$host/api/storage/$uniqueFileName';

      // Save to database
      _db.db.execute(
        '''INSERT INTO storage (owner_id, file_name, content_type, size, url) 
           VALUES (?, ?, ?, ?, ?)''',
        [userId, resolvedFileName, fileContentType, fileSize, fileUrl],
      );

      final fileId = _db.db.lastInsertRowId;

      return Response.ok(
        jsonEncode({
          'id': fileId,
          'file_name': resolvedFileName,
          'content_type': fileContentType,
          'size': fileSize,
          'url': fileUrl,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, st) {
      // Log the full stack trace for easier debugging in production
      print('storage_handler.upload - error: $e');
      print(st.toString());
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// GET /api/storage/my
  /// Get files uploaded by current user
  Future<Response> getMyFiles(Request request) async {
    try {
      final userId = request.context['userId'] as int?;
      if (userId == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Not authenticated'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = _db.db.select(
        '''SELECT * FROM storage WHERE owner_id = ? ORDER BY created_at DESC''',
        [userId],
      );

      final files = result.map((row) {
        var url = row['url'] as String? ?? '';
        // Normalize url to /api/storage/<filename>
        if (url.contains('/uploads/')) {
          final filename = url.split('/').last;
          final host = request.headers['host'] ?? 'localhost:8080';
          final scheme = request.headers['x-forwarded-proto'] ?? 'http';
          url = '$scheme://$host/api/storage/$filename';
        }
        return {
          'id': row['id'],
          'owner_id': row['owner_id'],
          'file_name': row['file_name'],
          'content_type': row['content_type'],
          'size': row['size'],
          'url': url,
          'created_at': row['created_at'],
        };
      }).toList();

      return Response.ok(
        jsonEncode(files),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// GET /api/storage/:filename
  /// Get/download a file by filename
  Future<Response> getFile(Request request, String filename) async {
    try {
      var fn = filename;
      // Strip uploads/ if present
      if (fn.startsWith('${_uploadDir}/')) {
        fn = fn.substring('${_uploadDir}/'.length);
      }
      final filePath = path.join(_uploadDir, fn);
      final file = File(filePath);
      
      if (!await file.exists()) {
        return Response.notFound(
          jsonEncode({'error': 'File not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final bytes = await file.readAsBytes();

      // Try to get the content type from DB for the file if available so
      // that uploads saved as e.g. `.bin` still get served with the
      // original content-type. Fallback to extension-based detection.
      String? contentTypeFromDb;
      try {
        final res = _db.db.select('SELECT content_type FROM storage WHERE url LIKE ?', ['%/$fn']);
        if (res.isNotEmpty) {
          contentTypeFromDb = res.first['content_type'] as String?;
        }
      } catch (_) {
        // Ignore DB lookup errors and fallback to extension detection below
      }

      String contentType;
      if (contentTypeFromDb != null && contentTypeFromDb.trim().isNotEmpty) {
        contentType = contentTypeFromDb;
      } else {
        final ext = path.extension(fn).toLowerCase();
        switch (ext) {
          case '.jpg':
          case '.jpeg':
            contentType = 'image/jpeg';
            break;
          case '.png':
            contentType = 'image/png';
            break;
          case '.gif':
            contentType = 'image/gif';
            break;
          case '.webp':
            contentType = 'image/webp';
            break;
          case '.pdf':
            contentType = 'application/pdf';
            break;
          case '.json':
            contentType = 'application/json';
            break;
          case '.txt':
            contentType = 'text/plain';
            break;
          case '.html':
            contentType = 'text/html';
            break;
          case '.css':
            contentType = 'text/css';
            break;
          case '.js':
            contentType = 'application/javascript';
            break;
          default:
            contentType = 'application/octet-stream';
        }
      }

      return Response.ok(
        bytes,
        headers: {
          'Content-Type': contentType,
          'Content-Length': bytes.length.toString(),
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// DELETE /api/storage/:id
  /// Delete a file (requires authentication & ownership)
  Future<Response> delete(Request request, String id) async {
    try {
      final userId = request.context['userId'] as int?;
      final role = request.context['role'] as String?;

      if (userId == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Not authenticated'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final fileId = int.tryParse(id);
      if (fileId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid file ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check ownership or admin
      final existing = _db.db.select(
        'SELECT owner_id, url FROM storage WHERE id = ?',
        [fileId],
      );

      if (existing.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'File not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final row = existing.first;
      final ownerId = row['owner_id'] as int?;
      if (ownerId != userId && role != 'admin') {
        return Response.forbidden(
          jsonEncode({'error': 'You can only delete your own files'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Delete physical file
      final url = row['url'] as String;
      final fileName = url.split('/').last;
      final filePath = path.join(_uploadDir, fileName);
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Delete from database
      _db.db.execute('DELETE FROM storage WHERE id = ?', [fileId]);

      return Response.ok(
        jsonEncode({'message': 'File deleted successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}

String _extensionForContentType(String contentType) {
  final ct = contentType.toLowerCase().split(';').first.trim();
  switch (ct) {
    case 'image/jpeg':
    case 'image/jpg':
      return '.jpg';
    case 'image/png':
      return '.png';
    case 'image/gif':
      return '.gif';
    case 'image/webp':
      return '.webp';
    case 'application/pdf':
      return '.pdf';
    case 'application/json':
      return '.json';
    case 'text/plain':
      return '.txt';
    case 'text/html':
      return '.html';
    case 'text/css':
      return '.css';
    case 'application/javascript':
      return '.js';
    case 'application/octet-stream':
    default:
      // Try to infer a known extension for common content types
      if (ct.startsWith('image/')) return '.png';
      if (ct.startsWith('audio/')) return '.mp3';
      if (ct.startsWith('video/')) return '.mp4';
      return '.bin';
  }
}

/// Detect content type from magic bytes (file signature)
String? _detectContentTypeFromBytes(List<int> bytes) {
  if (bytes.length < 12) return null;

  // JPEG: starts with FF D8 FF
  if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
    return 'image/jpeg';
  }

  // PNG: starts with 89 50 4E 47 0D 0A 1A 0A
  if (bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47 &&
      bytes[4] == 0x0D &&
      bytes[5] == 0x0A &&
      bytes[6] == 0x1A &&
      bytes[7] == 0x0A) {
    return 'image/png';
  }

  // GIF: starts with GIF87a or GIF89a
  if (bytes[0] == 0x47 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x38 &&
      (bytes[4] == 0x37 || bytes[4] == 0x39) &&
      bytes[5] == 0x61) {
    return 'image/gif';
  }

  // WebP: starts with RIFF....WEBP
  if (bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50) {
    return 'image/webp';
  }

  // PDF: starts with %PDF
  if (bytes[0] == 0x25 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x44 &&
      bytes[3] == 0x46) {
    return 'application/pdf';
  }

  return null;
}
