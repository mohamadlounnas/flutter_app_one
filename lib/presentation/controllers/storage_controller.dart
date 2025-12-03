// dart:typed_data is unnecessary -- types are available via foundation import
import 'package:flutter/foundation.dart';
import '../../domain/repositories/storage_repository.dart';
import '../../core/api/network_exceptions.dart';

enum StorageState { idle, uploading, error }

class StorageController extends ChangeNotifier {
  final StorageRepository _storageRepository;

  StorageController(this._storageRepository);

  StorageState _state = StorageState.idle;
  String? _error;

  StorageState get state => _state;
  String? get error => _error;

  Future<StorageResult?> uploadFile({
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  }) async {
    _state = StorageState.uploading;
    _error = null;
    notifyListeners();

    try {
      final result = await _storageRepository.uploadFile(
        fileName: fileName,
        bytes: bytes,
        contentType: contentType,
      );
      _state = StorageState.idle;
      notifyListeners();
      return result;
    } catch (e) {
      _error = NetworkExceptions.getMessage(e);
      _state = StorageState.error;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    if (_state == StorageState.error) {
      _state = StorageState.idle;
    }
    notifyListeners();
  }
}
