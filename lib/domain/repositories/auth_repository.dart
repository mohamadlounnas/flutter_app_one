import '../entities/user.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Register a new user
  Future<AuthResult> register({
    required String name,
    required String phone,
    required String password,
    String? imageUrl,
  });

  /// Login with phone and password
  Future<AuthResult> login({
    required String phone,
    required String password,
  });

  /// Get current authenticated user
  Future<UserEntity> getCurrentUser();

  /// Update current user profile
  Future<AuthResult> updateProfile({
    String? name,
    String? phone,
    String? imageUrl,
  });

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Refresh authentication token
  Future<String> refreshToken();

  /// Logout - clear stored token
  Future<void> logout();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get stored token
  Future<String?> getToken();
}

/// Result of authentication operations
class AuthResult {
  final UserEntity user;
  final String token;

  const AuthResult({
    required this.user,
    required this.token,
  });
}
