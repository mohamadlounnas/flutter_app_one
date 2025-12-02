import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtService {
  // Secret key for signing tokens - in production, use environment variable
  static const String _secretKey = 'your-super-secret-key-change-in-production';
  static const Duration _tokenDuration = Duration(hours: 24);

  /// Generate a JWT token for a user
  static String generateToken({
    required int userId,
    required String phone,
    required String role,
  }) {
    final jwt = JWT(
      {
        'userId': userId,
        'phone': phone,
        'role': role,
      },
      issuer: 'flutter_one_server',
    );

    return jwt.sign(
      SecretKey(_secretKey),
      expiresIn: _tokenDuration,
    );
  }

  /// Verify and decode a JWT token
  /// Returns the payload if valid, null if invalid
  static Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secretKey));
      return jwt.payload as Map<String, dynamic>;
    } on JWTExpiredException {
      print('JWT expired');
      return null;
    } on JWTException catch (e) {
      print('JWT error: ${e.message}');
      return null;
    }
  }

  /// Hash a password using SHA-256
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify a password against a hash
  static bool verifyPassword(String password, String hash) {
    return hashPassword(password) == hash;
  }
}
