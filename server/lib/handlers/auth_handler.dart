import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../database/database.dart';
import '../auth/jwt_service.dart';

class AuthHandler {
  final AppDatabase _db = AppDatabase.instance;

  /// POST /api/auth/register
  /// Register a new user
  Future<Response> register(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      // Validate required fields
      if (json['name'] == null || json['phone'] == null || json['password'] == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Name, phone, and password are required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final name = json['name'] as String;
      final phone = json['phone'] as String;
      final password = json['password'] as String;
      final role = json['role'] as String? ?? 'user';
      final imageUrl = json['image_url'] as String?;

      // Check if user already exists
      final existingUser = _db.db.select(
        'SELECT * FROM users WHERE phone = ?',
        [phone],
      );

      if (existingUser.isNotEmpty) {
        return Response(
          409, // Conflict
          body: jsonEncode({'error': 'User with this phone already exists'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Hash password
      final hashedPassword = JwtService.hashPassword(password);

      // Insert user (including optional image_url)
      _db.db.execute(
        'INSERT INTO users (name, phone, password, role, image_url) VALUES (?, ?, ?, ?, ?)',
        [name, phone, hashedPassword, role, imageUrl],
      );

      final lastId = _db.db.lastInsertRowId;

      // Generate token
      final token = JwtService.generateToken(
        userId: lastId,
        phone: phone,
        role: role,
      );

      return Response.ok(
        jsonEncode({
          'message': 'User registered successfully',
          'token': token,
            'user': {
            'id': lastId,
            'name': name,
            'phone': phone,
            'role': role,
            'image_url': imageUrl,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST /api/auth/login
  /// Login with phone and password
  Future<Response> login(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      // Validate required fields
      if (json['phone'] == null || json['password'] == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Phone and password are required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final phone = json['phone'] as String;
      final password = json['password'] as String;

      // Find user by phone
      final result = _db.db.select(
        'SELECT * FROM users WHERE phone = ?',
        [phone],
      );

      if (result.isEmpty) {
        return Response.unauthorized(
          jsonEncode({'error': 'Invalid phone or password'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final row = result.first;
      final storedPassword = row['password'] as String?;

      // Check password
      if (storedPassword == null || !JwtService.verifyPassword(password, storedPassword)) {
        return Response.unauthorized(
          jsonEncode({'error': 'Invalid phone or password'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final userId = row['id'] as int;
      final name = row['name'] as String;
      final role = row['role'] as String;
      final imageUrl = row['image_url'] as String?;

      // Generate token
      final token = JwtService.generateToken(
        userId: userId,
        phone: phone,
        role: role,
      );

      return Response.ok(
        jsonEncode({
          'message': 'Login successful',
          'token': token,
          'user': {
            'id': userId,
            'name': name,
            'phone': phone,
            'role': role,
            'image_url': imageUrl,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// GET /api/auth/me
  /// Get current user info (requires authentication)
  Response me(Request request) {
    try {
      final userId = request.context['userId'] as int?;

      if (userId == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Not authenticated'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = _db.db.select(
        'SELECT * FROM users WHERE id = ?',
        [userId],
      );

      if (result.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final row = result.first;
      final user = {
        'id': row['id'] as int,
        'name': row['name'] as String,
        'phone': row['phone'] as String,
        'role': row['role'] as String,
        'image_url': row['image_url'] as String?,
      };

      return Response.ok(
        jsonEncode(user),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST /api/auth/refresh
  /// Refresh token (requires valid token)
  Response refresh(Request request) {
    try {
      final userId = request.context['userId'] as int?;
      final phone = request.context['phone'] as String?;
      final role = request.context['role'] as String?;

      if (userId == null || phone == null || role == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Not authenticated'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Generate new token
      final token = JwtService.generateToken(
        userId: userId,
        phone: phone,
        role: role,
      );

      return Response.ok(
        jsonEncode({
          'message': 'Token refreshed',
          'token': token,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// PUT /api/auth/change-password
  /// Change password (requires authentication)
  Future<Response> changePassword(Request request) async {
    try {
      final userId = request.context['userId'] as int?;

      if (userId == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Not authenticated'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      if (json['currentPassword'] == null || json['newPassword'] == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Current password and new password are required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final currentPassword = json['currentPassword'] as String;
      final newPassword = json['newPassword'] as String;

      // Get current user
      final result = _db.db.select(
        'SELECT * FROM users WHERE id = ?',
        [userId],
      );

      if (result.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final row = result.first;
      final storedPassword = row['password'] as String?;

      // Verify current password
      if (storedPassword == null || !JwtService.verifyPassword(currentPassword, storedPassword)) {
        return Response.unauthorized(
          jsonEncode({'error': 'Current password is incorrect'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Hash and update new password
      final hashedNewPassword = JwtService.hashPassword(newPassword);
      _db.db.execute(
        'UPDATE users SET password = ? WHERE id = ?',
        [hashedNewPassword, userId],
      );

      return Response.ok(
        jsonEncode({'message': 'Password changed successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// PUT /api/auth/me
  /// Update current user profile (requires authentication). Returns new token if phone changed.
  Future<Response> update(Request request) async {
    try {
      final userId = request.context['userId'] as int?;

      if (userId == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Not authenticated'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = await request.readAsString();
      final jsonBody = jsonDecode(body) as Map<String, dynamic>;

      final newName = jsonBody['name'] as String?;
      final newPhone = jsonBody['phone'] as String?;
      final newImageUrl = jsonBody['image_url'] as String?;

      if (newName == null && newPhone == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Nothing to update'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // If phone is changing, ensure uniqueness
      if (newPhone != null) {
        final existing = _db.db.select(
          'SELECT * FROM users WHERE phone = ?',
          [newPhone],
        );
        if (existing.isNotEmpty) {
          // allow if it's the same user
          final row = existing.first;
          if ((row['id'] as int) != userId) {
            return Response(
              409,
              body: jsonEncode({'error': 'Phone number already in use'}),
              headers: {'Content-Type': 'application/json'},
            );
          }
        }
      }

      final updates = <String>[];
      final params = <Object>[];
      if (newName != null) {
        updates.add('name = ?');
        params.add(newName);
      }
      if (newImageUrl != null) {
        updates.add('image_url = ?');
        params.add(newImageUrl);
      }
      if (newPhone != null) {
        updates.add('phone = ?');
        params.add(newPhone);
      }

      if (updates.isNotEmpty) {
        params.add(userId);
        _db.db.execute(
          'UPDATE users SET ${updates.join(', ')} WHERE id = ?',
          params,
        );
      }

      // Fetch updated user
      final result = _db.db.select(
        'SELECT * FROM users WHERE id = ?',
        [userId],
      );
      if (result.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      final row = result.first;

      final user = {
        'id': row['id'] as int,
        'name': row['name'] as String,
        'phone': row['phone'] as String,
        'role': row['role'] as String,
      };

      // If phone changed, issue a new token
      String? token;
      if (newPhone != null) {
        token = JwtService.generateToken(
          userId: user['id'] as int,
          phone: user['phone'] as String,
          role: user['role'] as String,
        );
      }

      final responseBody = <String, dynamic>{
        'message': 'User updated successfully',
        'user': user,
      };
      if (token != null) responseBody['token'] = token;

      return Response.ok(
        jsonEncode(responseBody),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
