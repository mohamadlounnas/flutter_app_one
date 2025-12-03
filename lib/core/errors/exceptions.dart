/// Base exception class for the app
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Network-related exceptions
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException(
    super.message, {
    this.statusCode,
    super.code,
    super.originalError,
  });

  @override
  String toString() =>
      'NetworkException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'AuthException: $message';
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'ValidationException: $message';
}

/// Not found exceptions
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'NotFoundException: $message';
}

/// Server error exceptions
class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'ServerException: $message';
}

/// Cache exceptions
class CacheException extends AppException {
  const CacheException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'CacheException: $message';
}
