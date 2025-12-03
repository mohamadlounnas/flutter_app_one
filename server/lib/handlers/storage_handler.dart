import 'dart:convert';
import 'dart:io' show File, Directory;
import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:path/path.dart' as path;
// Note: we accept JSON uploads (base64) in this server. Multipart parsing
// may be added later if needed.
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
      final userId = request.context['userId'] as int?;
      if (userId == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Not authenticated'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final contentType = request.headers['content-type']?.toLowerCase();
      if (contentType == null || !contentType.contains('application/json')) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Content-Type must be application/json'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Support JSON uploads with base64 (useful on web) or multipart form-data
      String? fileName;
      String? fileContentType;
      List<int>? fileBytes;

      if (contentType.contains('application/json')) {
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
      } else {
        // We currently only support JSON uploads with base64 payloads.
        return Response.badRequest(
          body: jsonEncode({'error': 'Only application/json uploads are supported at the moment. Try sending base64-encoded files.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (fileName == null || fileBytes == null || fileBytes.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'No file provided'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(fileName);
      final uniqueFileName = '${userId}_${timestamp}$extension';
      final filePath = path.join(_uploadDir, uniqueFileName);

      // Save file
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      final fileSize = await file.length();

      // Get base URL from request headers or use default
      final host = request.headers['host'] ?? 'localhost:8080';
      final scheme = request.headers['x-forwarded-proto'] ?? 'http';
      final fileUrl = '$scheme://$host/api/storage/$uniqueFileName';

      // Save to database
      _db.db.execute(
        '''INSERT INTO storage (owner_id, file_name, content_type, size, url) 
           VALUES (?, ?, ?, ?, ?)''',
        [userId, fileName, fileContentType, fileSize, fileUrl],
      );

      final fileId = _db.db.lastInsertRowId;

      return Response.ok(
        jsonEncode({
          'id': fileId,
          'file_name': fileName,
          'content_type': fileContentType,
          'size': fileSize,
          'url': fileUrl,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
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
      
      // Determine content type from extension
      final ext = path.extension(fn).toLowerCase();
      String contentType;
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
