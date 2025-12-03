import 'dart:typed_data';
import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../../../core/constants.dart';

/// Remote data source for file storage
abstract class StorageRemoteDataSource {
  Future<StorageUploadResponse> uploadFile({
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  });

  Future<void> deleteFile(int id);

  Future<List<StorageItemModel>> getMyFiles();
}

/// Storage upload response
class StorageUploadResponse {
  final int id;
  final String url;
  final String fileName;
  final String contentType;
  final int size;

  const StorageUploadResponse({
    required this.id,
    required this.url,
    required this.fileName,
    required this.contentType,
    required this.size,
  });

  factory StorageUploadResponse.fromJson(Map<String, dynamic> json) {
    return StorageUploadResponse(
      id: json['id'] as int,
      url: json['url'] as String,
      fileName: json['file_name'] as String,
      contentType: json['content_type'] as String? ?? 'application/octet-stream',
      size: json['size'] as int? ?? 0,
    );
  }
}

/// Storage item model
class StorageItemModel {
  final int id;
  final int? ownerId;
  final String fileName;
  final String? contentType;
  final int? size;
  final String url;
  final DateTime? createdAt;

  const StorageItemModel({
    required this.id,
    this.ownerId,
    required this.fileName,
    this.contentType,
    this.size,
    required this.url,
    this.createdAt,
  });

  factory StorageItemModel.fromJson(Map<String, dynamic> json) {
    return StorageItemModel(
      id: json['id'] as int,
      ownerId: json['owner_id'] as int?,
      fileName: json['file_name'] as String,
      contentType: json['content_type'] as String?,
      size: json['size'] as int?,
      url: json['url'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}

/// Implementation of storage remote data source
class StorageRemoteDataSourceImpl implements StorageRemoteDataSource {
  final ApiClient _apiClient;

  StorageRemoteDataSourceImpl(this._apiClient);

  @override
  Future<StorageUploadResponse> uploadFile({
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final base64Data = base64Encode(bytes);
    final response = await _apiClient.post(
      ApiConstants.storageUpload,
      body: {
        'file_name': fileName,
        'content_type': contentType,
        'data': base64Data,
      },
      requireAuth: true,
    );

    return StorageUploadResponse.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deleteFile(int id) async {
    await _apiClient.delete(
      ApiConstants.storageById(id),
      requireAuth: true,
    );
  }

  @override
  Future<List<StorageItemModel>> getMyFiles() async {
    final response = await _apiClient.get(
      ApiConstants.storageMyFiles,
      requireAuth: true,
    );

    final List<dynamic> filesJson = response is List ? response : response['files'] ?? [];
    return filesJson
        .map((json) => StorageItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
