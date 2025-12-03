import '../../core/api/api_client.dart';
import '../../core/storage/storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_data_source.dart';
import '../datasources/local/cache_data_source.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final StorageService _storageService;
  final CacheDataSource _cacheDataSource;
  final ApiClient _apiClient;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required StorageService storageService,
    required CacheDataSource cacheDataSource,
    required ApiClient apiClient,
  })  : _remoteDataSource = remoteDataSource,
        _storageService = storageService,
        _cacheDataSource = cacheDataSource,
        _apiClient = apiClient;

  @override
  Future<AuthResult> register({
    required String name,
    required String phone,
    required String password,
    String? imageUrl,
  }) async {
    final response = await _remoteDataSource.register(
      name: name,
      phone: phone,
      password: password,
      imageUrl: imageUrl,
    );

    // Store token and user
    await _storageService.saveToken(response.token);
    await _cacheDataSource.cacheUser(response.user);
    _apiClient.setToken(response.token);

    return AuthResult(
      user: response.user.toEntity(),
      token: response.token,
    );
  }

  @override
  Future<AuthResult> login({
    required String phone,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      phone: phone,
      password: password,
    );

    // Store token and user
    await _storageService.saveToken(response.token);
    await _cacheDataSource.cacheUser(response.user);
    _apiClient.setToken(response.token);

    return AuthResult(
      user: response.user.toEntity(),
      token: response.token,
    );
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final userModel = await _remoteDataSource.getCurrentUser();
    await _cacheDataSource.cacheUser(userModel);
    return userModel.toEntity();
  }

  @override
  Future<AuthResult> updateProfile({
    String? name,
    String? phone,
    String? imageUrl,
  }) async {
    final response = await _remoteDataSource.updateProfile(
      name: name,
      phone: phone,
      imageUrl: imageUrl,
    );

    // Update stored data if token changed
    if (response.token.isNotEmpty) {
      await _storageService.saveToken(response.token);
      _apiClient.setToken(response.token);
    }
    await _cacheDataSource.cacheUser(response.user);

    return AuthResult(
      user: response.user.toEntity(),
      token: response.token,
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<String> refreshToken() async {
    final token = await _remoteDataSource.refreshToken();
    await _storageService.saveToken(token);
    _apiClient.setToken(token);
    return token;
  }

  @override
  Future<void> logout() async {
    await _storageService.removeToken();
    await _cacheDataSource.clearUserCache();
    _apiClient.clearToken();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> getToken() async {
    return _storageService.getToken();
  }
}
