import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../database/database.dart';

class UserHandler {
  final db = AppDatabase.instance;

  /// Get all users (admin only)
  Future<Response> getAll(Request request) async {
    try {
      final results = db.db.select(
        'SELECT id, name, phone, role, image_url, created_at FROM users ORDER BY created_at DESC',
      );

      final users = results.map((row) {
        return {
          'id': row['id'],
          'name': row['name'],
          'phone': row['phone'],
          'role': row['role'],
          'image_url': row['image_url'],
          'created_at': row['created_at'],
        };
      }).toList();

      return Response.ok(
        jsonEncode({'success': true, 'data': users}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': 'Failed to get users: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Get user by ID (admin only)
  Future<Response> getById(Request request, String id) async {
    try {
      final results = db.db.select(
        'SELECT id, name, phone, role, image_url, created_at FROM users WHERE id = ?',
        [int.parse(id)],
      );

      if (results.isEmpty) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final user = results.first;
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'id': user['id'],
            'name': user['name'],
            'phone': user['phone'],
            'role': user['role'],
            'image_url': user['image_url'],
            'created_at': user['created_at'],
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': 'Failed to get user: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Create a new user (admin only)
  Future<Response> create(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString());

      final name = body['name'];
      final phone = body['phone'];
      final password = body['password'];
      final role = body['role'] ?? 'user';
      final imageUrl = body['image_url'];

      if (name == null || phone == null || password == null) {
        return Response(
          400,
          body: jsonEncode({'success': false, 'error': 'Name, phone, and password are required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check if phone already exists
      final existing = db.db.select('SELECT id FROM users WHERE phone = ?', [phone]);
      if (existing.isNotEmpty) {
        return Response(
          409,
          body: jsonEncode({'success': false, 'error': 'Phone number already registered'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      db.db.execute(
        'INSERT INTO users (name, phone, password, role, image_url) VALUES (?, ?, ?, ?, ?)',
        [name, phone, password, role, imageUrl],
      );

      final newUser = db.db.select('SELECT * FROM users WHERE id = last_insert_rowid()').first;

      return Response(
        201,
        body: jsonEncode({
          'success': true,
          'data': {
            'id': newUser['id'],
            'name': newUser['name'],
            'phone': newUser['phone'],
            'role': newUser['role'],
            'image_url': newUser['image_url'],
            'created_at': newUser['created_at'],
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': 'Failed to create user: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Update a user (admin only)
  Future<Response> update(Request request, String id) async {
    try {
      final body = jsonDecode(await request.readAsString());
      final userId = int.parse(id);

      // Check if user exists
      final existing = db.db.select('SELECT * FROM users WHERE id = ?', [userId]);
      if (existing.isEmpty) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final updates = <String>[];
      final values = <dynamic>[];

      if (body['name'] != null) {
        updates.add('name = ?');
        values.add(body['name']);
      }
      if (body['phone'] != null) {
        // Check if phone is taken by another user
        final phoneCheck = db.db.select(
          'SELECT id FROM users WHERE phone = ? AND id != ?',
          [body['phone'], userId],
        );
        if (phoneCheck.isNotEmpty) {
          return Response(
            409,
            body: jsonEncode({'success': false, 'error': 'Phone number already in use'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        updates.add('phone = ?');
        values.add(body['phone']);
      }
      if (body['password'] != null) {
        updates.add('password = ?');
        values.add(body['password']);
      }
      if (body['role'] != null) {
        updates.add('role = ?');
        values.add(body['role']);
      }
      if (body.containsKey('image_url')) {
        updates.add('image_url = ?');
        values.add(body['image_url']);
      }

      if (updates.isEmpty) {
        return Response(
          400,
          body: jsonEncode({'success': false, 'error': 'No fields to update'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      values.add(userId);
      db.db.execute(
        'UPDATE users SET ${updates.join(', ')} WHERE id = ?',
        values,
      );

      final updated = db.db.select(
        'SELECT id, name, phone, role, image_url, created_at FROM users WHERE id = ?',
        [userId],
      ).first;

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'id': updated['id'],
            'name': updated['name'],
            'phone': updated['phone'],
            'role': updated['role'],
            'image_url': updated['image_url'],
            'created_at': updated['created_at'],
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': 'Failed to update user: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Delete a user (admin only)
  Future<Response> delete(Request request, String id) async {
    try {
      final userId = int.parse(id);

      // Check if user exists
      final existing = db.db.select('SELECT * FROM users WHERE id = ?', [userId]);
      if (existing.isEmpty) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Delete user's comments first
      db.db.execute('DELETE FROM comments WHERE user_id = ?', [userId]);
      
      // Delete user's posts
      db.db.execute('DELETE FROM posts WHERE user_id = ?', [userId]);
      
      // Delete the user
      db.db.execute('DELETE FROM users WHERE id = ?', [userId]);

      return Response.ok(
        jsonEncode({'success': true, 'message': 'User deleted successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': 'Failed to delete user: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
