/// Base failure class for representing errors in the domain layer
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure: $message${code != null ? ' (code: $code)' : ''}';
}

/// Network-related failures
class NetworkFailure extends Failure {
  final int? statusCode;

  const NetworkFailure(super.message, {this.statusCode, super.code});

  @override
  String toString() =>
      'NetworkFailure: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});

  @override
  String toString() => 'AuthFailure: $message';
}

/// Validation failures
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure(super.message, {this.fieldErrors, super.code});

  @override
  String toString() => 'ValidationFailure: $message';
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code});

  @override
  String toString() => 'NotFoundFailure: $message';
}

/// Server failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});

  @override
  String toString() => 'ServerFailure: $message';
}

/// Cache failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});

  @override
  String toString() => 'CacheFailure: $message';
}
