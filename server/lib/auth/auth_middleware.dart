import 'package:shelf/shelf.dart';
import 'jwt_service.dart';

/// Middleware to check for valid JWT token
/// Adds user info to request context if valid
Middleware authMiddleware() {
  return (Handler innerHandler) {
    return (Request request) {
      // Get Authorization header
      final authHeader = request.headers['Authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden(
          '{"error": "Missing or invalid Authorization header"}',
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Extract token
      final token = authHeader.substring(7); // Remove 'Bearer ' prefix

      // Verify token
      final payload = JwtService.verifyToken(token);

      if (payload == null) {
        return Response.forbidden(
          '{"error": "Invalid or expired token"}',
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Add user info to request context
      final updatedRequest = request.change(
        context: {
          ...request.context,
          'userId': payload['userId'],
          'phone': payload['phone'],
          'role': payload['role'],
        },
      );

      return innerHandler(updatedRequest);
    };
  };
}

/// Middleware to check for specific roles
Middleware roleMiddleware(List<String> allowedRoles) {
  return (Handler innerHandler) {
    return (Request request) {
      final role = request.context['role'] as String?;

      if (role == null || !allowedRoles.contains(role)) {
        return Response.forbidden(
          '{"error": "Insufficient permissions"}',
          headers: {'Content-Type': 'application/json'},
        );
      }

      return innerHandler(request);
    };
  };
}

/// Optional auth middleware - doesn't fail if no token, but adds user info if valid
Middleware optionalAuthMiddleware() {
  return (Handler innerHandler) {
    return (Request request) {
      final authHeader = request.headers['Authorization'];

      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        final token = authHeader.substring(7);
        final payload = JwtService.verifyToken(token);

        if (payload != null) {
          final updatedRequest = request.change(
            context: {
              ...request.context,
              'userId': payload['userId'],
              'phone': payload['phone'],
              'role': payload['role'],
            },
          );
          return innerHandler(updatedRequest);
        }
      }

      return innerHandler(request);
    };
  };
}
