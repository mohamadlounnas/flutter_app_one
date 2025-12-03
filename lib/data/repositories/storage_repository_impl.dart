import 'dart:typed_data';
import '../../domain/repositories/storage_repository.dart';
import '../datasources/remote/storage_remote_data_source.dart';

/// Implementation of StorageRepository
class StorageRepositoryImpl implements StorageRepository {
  final StorageRemoteDataSource _remoteDataSource;

  StorageRepositoryImpl({
    required StorageRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<StorageResult> uploadFile({
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final response = await _remoteDataSource.uploadFile(
      fileName: fileName,
      bytes: bytes,
      contentType: contentType,
    );

    return StorageResult(
      id: response.id,
      url: response.url,
      fileName: response.fileName,
      contentType: response.contentType,
      size: response.size,
    );
  }

  @override
  Future<void> deleteFile(int id) async {
    await _remoteDataSource.deleteFile(id);
  }

  @override
  Future<List<StorageItem>> getMyFiles() async {
    final files = await _remoteDataSource.getMyFiles();
    return files
        .map((model) => StorageItem(
              id: model.id,
              ownerId: model.ownerId,
              fileName: model.fileName,
              contentType: model.contentType,
              size: model.size,
              url: model.url,
              createdAt: model.createdAt,
            ))
        .toList();
  }
}
