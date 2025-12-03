import '../../../core/api/api_client.dart';
import '../../../core/constants.dart';
import '../../models/user_model.dart';

/// Remote data source for authentication
abstract class AuthRemoteDataSource {
  Future<AuthResponse> register({
    required String name,
    required String phone,
    required String password,
    String? imageUrl,
  });

  Future<AuthResponse> login({
    required String phone,
    required String password,
  });

  Future<UserModel> getCurrentUser();

  Future<AuthResponse> updateProfile({
    String? name,
    String? phone,
    String? imageUrl,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<String> refreshToken();
}

/// Auth response containing user and token
class AuthResponse {
  final UserModel user;
  final String token;

  const AuthResponse({required this.user, required this.token});
}

/// Implementation of auth remote data source
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthResponse> register({
    required String name,
    required String phone,
    required String password,
    String? imageUrl,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.authRegister,
      body: {
        'name': name,
        'phone': phone,
        'password': password,
        if (imageUrl != null) 'image_url': imageUrl,
      },
    );

    final user = UserModel.fromJson(response['user'] as Map<String, dynamic>);
    final token = response['token'] as String;

    return AuthResponse(user: user, token: token);
  }

  @override
  Future<AuthResponse> login({
    required String phone,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.authLogin,
      body: {
        'phone': phone,
        'password': password,
      },
    );

    final user = UserModel.fromJson(response['user'] as Map<String, dynamic>);
    final token = response['token'] as String;

    return AuthResponse(user: user, token: token);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get(
      ApiConstants.authMe,
      requireAuth: true,
    );

    return UserModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<AuthResponse> updateProfile({
    String? name,
    String? phone,
    String? imageUrl,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.authMe,
      body: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (imageUrl != null) 'image_url': imageUrl,
      },
      requireAuth: true,
    );

    final user = UserModel.fromJson(response['user'] as Map<String, dynamic>);
    final token = response['token'] as String? ?? _apiClient.token ?? '';

    return AuthResponse(user: user, token: token);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.put(
      ApiConstants.authChangePassword,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      requireAuth: true,
    );
  }

  @override
  Future<String> refreshToken() async {
    final response = await _apiClient.post(
      ApiConstants.authRefresh,
      requireAuth: true,
    );

    return response['token'] as String;
  }
}
