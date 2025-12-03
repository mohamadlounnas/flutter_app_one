import 'dart:typed_data';

/// Storage repository interface for file uploads
abstract class StorageRepository {
  /// Upload a file and return the public URL
  Future<StorageResult> uploadFile({
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  });

  /// Delete a file by ID
  Future<void> deleteFile(int id);

  /// Get files uploaded by current user
  Future<List<StorageItem>> getMyFiles();
}

/// Result of a file upload
class StorageResult {
  final int id;
  final String url;
  final String fileName;
  final String contentType;
  final int size;

  const StorageResult({
    required this.id,
    required this.url,
    required this.fileName,
    required this.contentType,
    required this.size,
  });
}

/// Storage item metadata
class StorageItem {
  final int id;
  final int? ownerId;
  final String fileName;
  final String? contentType;
  final int? size;
  final String url;
  final DateTime? createdAt;

  const StorageItem({
    required this.id,
    this.ownerId,
    required this.fileName,
    this.contentType,
    this.size,
    required this.url,
    this.createdAt,
  });
}
