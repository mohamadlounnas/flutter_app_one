import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:flutter_one/data/models/user.dart';
import '../database/database.dart';

class UserHandler {
  final AppDatabase _db = AppDatabase.instance;

  Response getAll(Request request) {
    try {
      final result = _db.db.select('SELECT * FROM users ORDER BY id');
      final users = result.map((row) {
        return UserModel(
          id: row['id'] as int,
          name: row['name'] as String,
          phone: row['phone'] as String,
          password: row['password'] as String?,
          role: row['role'] as String,
        ).toJson();
      }).toList();

      return Response.ok(
        jsonEncode(users),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(body: e.toString());
    }
  }

  Response getById(Request request, String id) {
    try {
      final result = _db.db.select(
        'SELECT * FROM users WHERE id = ?',
        [int.parse(id)],
      );

      if (result.isEmpty) {
        return Response.notFound('User not found');
      }

      final row = result.first;
      final user = UserModel(
        id: row['id'] as int,
        name: row['name'] as String,
        phone: row['phone'] as String,
        password: row['password'] as String?,
        role: row['role'] as String,
      ).toJson();

      return Response.ok(
        jsonEncode(user),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(body: e.toString());
    }
  }

  Future<Response> create(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      _db.db.execute(
        'INSERT INTO users (name, phone, password, role) VALUES (?, ?, ?, ?)',
        [
          json['name'] as String,
          json['phone'] as String,
          json['password'] as String?,
          json['role'] as String,
        ],
      );

      final lastId = _db.db.lastInsertRowId;
      final result = _db.db.select(
        'SELECT * FROM users WHERE id = ?',
        [lastId],
      );

      final row = result.first;
      final user = UserModel(
        id: row['id'] as int,
        name: row['name'] as String,
        phone: row['phone'] as String,
        password: row['password'] as String?,
        role: row['role'] as String,
      ).toJson();

      return Response.ok(
        jsonEncode(user),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(body: e.toString());
    }
  }

  Future<Response> update(Request request, String id) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      _db.db.execute(
        'UPDATE users SET name = ?, phone = ?, password = ?, role = ? WHERE id = ?',
        [
          json['name'] as String,
          json['phone'] as String,
          json['password'] as String?,
          json['role'] as String,
          int.parse(id),
        ],
      );

      final result = _db.db.select(
        'SELECT * FROM users WHERE id = ?',
        [int.parse(id)],
      );

      if (result.isEmpty) {
        return Response.notFound('User not found');
      }

      final row = result.first;
      final user = UserModel(
        id: row['id'] as int,
        name: row['name'] as String,
        phone: row['phone'] as String,
        password: row['password'] as String?,
        role: row['role'] as String,
      ).toJson();

      return Response.ok(
        jsonEncode(user),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(body: e.toString());
    }
  }

  Response delete(Request request, String id) {
    try {
      final result = _db.db.select(
        'SELECT * FROM users WHERE id = ?',
        [int.parse(id)],
      );

      if (result.isEmpty) {
        return Response.notFound('User not found');
      }

      _db.db.execute('DELETE FROM users WHERE id = ?', [int.parse(id)]);

      return Response(204);
    } catch (e) {
      return Response.internalServerError(body: e.toString());
    }
  }
}

