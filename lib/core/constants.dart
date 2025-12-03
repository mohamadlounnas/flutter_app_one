/// API constants
class ApiConstants {
  ApiConstants._();

  /// Base URL for the API
  static const String baseUrl = 'http://localhost:8080';

  /// API version prefix
  static const String apiPrefix = '/api';

  /// Auth endpoints
  static const String authRegister = '$apiPrefix/auth/register';
  static const String authLogin = '$apiPrefix/auth/login';
  static const String authMe = '$apiPrefix/auth/me';
  static const String authRefresh = '$apiPrefix/auth/refresh';
  static const String authChangePassword = '$apiPrefix/auth/change-password';

  /// Posts endpoints
  static const String posts = '$apiPrefix/posts';
  static String postById(int id) => '$apiPrefix/posts/$id';
  static String postRestore(int id) => '$apiPrefix/posts/$id/restore';
  static String postComments(int postId) => '$apiPrefix/posts/$postId/comments';

  /// Comments endpoints
  static const String comments = '$apiPrefix/comments';
  static String commentById(int id) => '$apiPrefix/comments/$id';

  /// Storage endpoints
  static const String storageUpload = '$apiPrefix/storage/upload';
  static String storageById(int id) => '$apiPrefix/storage/$id';
  static const String storageMyFiles = '$apiPrefix/storage/my';

  /// Users endpoints (admin)
  static const String users = '$apiPrefix/users';
  static String userById(int id) => '$apiPrefix/users/$id';
}

/// App-wide constants
class AppConstants {
  AppConstants._();

  /// Token storage key
  static const String tokenKey = 'auth_token';

  /// User storage key
  static const String userKey = 'current_user';

  /// Default page size for pagination
  static const int defaultPageSize = 20;

  /// Maximum file upload size (5MB)
  static const int maxFileSize = 5 * 1024 * 1024;

  /// Allowed image extensions
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
}
