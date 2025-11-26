import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:flutter_one/data/models/order.dart';
import '../database/database.dart';

class OrderHandler {
  final AppDatabase _db = AppDatabase.instance;

  Response getAll(Request request) {
    try {
      final result = _db.db.select('SELECT * FROM orders ORDER BY id DESC');
      final orders = result.map((row) {
        return OrderModel(
          id: row['id'] as int,
          userId: row['userId'] as int?,
          phone: row['phone'] as String,
          dishId: row['dishId'] as String,
          latitude: row['latitude'] as double,
          longitude: row['longitude'] as double,
          address: row['address'] as String,
          completed: (row['completed'] as int) == 1,
        ).toJson();
      }).toList();

      return Response.ok(
        jsonEncode(orders),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(body: e.toString());
    }
  }

  Response getById(Request request, String id) {
    try {
      final result = _db.db.select(
        'SELECT * FROM orders WHERE id = ?',
        [int.parse(id)],
      );

      if (result.isEmpty) {
        return Response.notFound('Order not found');
      }

      final row = result.first;
      final order = OrderModel(
        id: row['id'] as int,
        userId: row['userId'] as int?,
        phone: row['phone'] as String,
        dishId: row['dishId'] as String,
        latitude: row['latitude'] as double,
        longitude: row['longitude'] as double,
        address: row['address'] as String,
        completed: (row['completed'] as int) == 1,
      ).toJson();

      return Response.ok(
        jsonEncode(order),
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
        'INSERT INTO orders (userId, phone, dishId, latitude, longitude, address, completed) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [
          json['userId'],
          json['phone'] as String,
          json['dishId'] as String,
          json['latitude'] as double,
          json['longitude'] as double,
          json['address'] as String,
          (json['completed'] as bool? ?? false) ? 1 : 0,
        ],
      );

      final lastId = _db.db.lastInsertRowId;
      final result = _db.db.select(
        'SELECT * FROM orders WHERE id = ?',
        [lastId],
      );

      final row = result.first;
      final order = OrderModel(
        id: row['id'] as int,
        userId: row['userId'] as int?,
        phone: row['phone'] as String,
        dishId: row['dishId'] as String,
        latitude: row['latitude'] as double,
        longitude: row['longitude'] as double,
        address: row['address'] as String,
        completed: (row['completed'] as int) == 1,
      ).toJson();

      return Response.ok(
        jsonEncode(order),
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
        'UPDATE orders SET userId = ?, phone = ?, dishId = ?, latitude = ?, longitude = ?, address = ?, completed = ? WHERE id = ?',
        [
          json['userId'],
          json['phone'] as String,
          json['dishId'] as String,
          json['latitude'] as double,
          json['longitude'] as double,
          json['address'] as String,
          (json['completed'] as bool? ?? false) ? 1 : 0,
          int.parse(id),
        ],
      );

      final result = _db.db.select(
        'SELECT * FROM orders WHERE id = ?',
        [int.parse(id)],
      );

      if (result.isEmpty) {
        return Response.notFound('Order not found');
      }

      final row = result.first;
      final order = OrderModel(
        id: row['id'] as int,
        userId: row['userId'] as int?,
        phone: row['phone'] as String,
        dishId: row['dishId'] as String,
        latitude: row['latitude'] as double,
        longitude: row['longitude'] as double,
        address: row['address'] as String,
        completed: (row['completed'] as int) == 1,
      ).toJson();

      return Response.ok(
        jsonEncode(order),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(body: e.toString());
    }
  }

  Response delete(Request request, String id) {
    try {
      final result = _db.db.select(
        'SELECT * FROM orders WHERE id = ?',
        [int.parse(id)],
      );

      if (result.isEmpty) {
        return Response.notFound('Order not found');
      }

      _db.db.execute('DELETE FROM orders WHERE id = ?', [int.parse(id)]);

      return Response(204);
    } catch (e) {
      return Response.internalServerError(body: e.toString());
    }
  }
}

