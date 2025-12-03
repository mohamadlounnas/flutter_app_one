import '../errors/exceptions.dart';

/// Maps network exceptions to user-friendly messages
class NetworkExceptions {
  NetworkExceptions._();

  /// Get user-friendly error message from exception
  static String getMessage(dynamic exception) {
    if (exception is NetworkException) {
      return _getNetworkMessage(exception);
    } else if (exception is AuthException) {
      return exception.message;
    } else if (exception is ValidationException) {
      return exception.message;
    } else if (exception is NotFoundException) {
      return exception.message;
    } else if (exception is ServerException) {
      return 'Server error. Please try again later.';
    } else if (exception is AppException) {
      return exception.message;
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  static String _getNetworkMessage(NetworkException exception) {
    switch (exception.statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'You don\'t have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'This resource already exists.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        if (exception.message.contains('SocketException') ||
            exception.message.contains('Connection refused')) {
          return 'Unable to connect to server. Please check your internet connection.';
        }
        return exception.message;
    }
  }

  /// Check if error is authentication related
  static bool isAuthError(dynamic exception) {
    if (exception is AuthException) return true;
    if (exception is NetworkException) {
      return exception.statusCode == 401 || exception.statusCode == 403;
    }
    return false;
  }

  /// Check if error is network connectivity related
  static bool isConnectionError(dynamic exception) {
    if (exception is NetworkException) {
      return exception.message.contains('SocketException') ||
          exception.message.contains('Connection refused') ||
          exception.message.contains('Network error');
    }
    return false;
  }
}
