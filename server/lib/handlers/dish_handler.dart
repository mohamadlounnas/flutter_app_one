import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:flutter_one/data/models/dish.dart';
import '../database/database.dart';

class DishHandler {
  final AppDatabase _db = AppDatabase.instance;

  Response getAll(Request request) {
    try {
      final result = _db.db.select('SELECT * FROM dishes ORDER BY id');
      final dishes = result.map((row) {
        return DishModel(
          id: row['id'] as int,
          name: row['name'] as String,
          photoUrl: row['photoUrl'] as String,
          price: row['price'] as double,
        ).toJson();
      }).toList();

      return Response.ok(
        jsonEncode(dishes),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(body: e.toString());
    }
  }

  Response getById(Request request, String id) {
    try {
      final result = _db.db.select(
        'SELECT * FROM dishes WHERE id = ?',
        [int.parse(id)],
      );

      if (result.isEmpty) {
        return Response.notFound('Dish not found');
      }

      final row = result.first;
      final dish = DishModel(
        id: row['id'] as int,
        name: row['name'] as String,
        photoUrl: row['photoUrl'] as String,
        price: row['price'] as double,
      ).toJson();

      return Response.ok(
        jsonEncode(dish),
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
        'INSERT INTO dishes (name, photoUrl, price) VALUES (?, ?, ?)',
        [
          json['name'] as String,
          json['photoUrl'] as String,
          double.parse(json['price'].toString()),
        ],
      );

      final lastId = _db.db.lastInsertRowId;
      final result = _db.db.select(
        'SELECT * FROM dishes WHERE id = ?',
        [lastId],
      );

      final dish = DishModel(
        id: result.first['id'] as int,
        name: result.first['name'] as String,
        photoUrl: result.first['photoUrl'] as String,
        price: result.first['price'] as double,
      ).toJson();

      return Response.ok(
        jsonEncode(dish),
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
        'UPDATE dishes SET name = ?, photoUrl = ?, price = ? WHERE id = ?',
        [
          json['name'] as String,
          json['photoUrl'] as String,
          json['price'] as double,
          int.parse(id),
        ],
      );

      final result = _db.db.select(
        'SELECT * FROM dishes WHERE id = ?',
        [int.parse(id)],
      );

      if (result.isEmpty) {
        return Response.notFound('Dish not found');
      }

      final dish = DishModel(
        id: result.first['id'] as int,
        name: result.first['name'] as String,
        photoUrl: result.first['photoUrl'] as String,
        price: result.first['price'] as double,
      ).toJson();

      return Response.ok(
        jsonEncode(dish),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(body: e.toString());
    }
  }

  Response delete(Request request, String id) {
    try {
      final result = _db.db.select(
        'SELECT * FROM dishes WHERE id = ?',
        [int.parse(id)],
      );

      if (result.isEmpty) {
        return Response.notFound('Dish not found');
      }

      _db.db.execute('DELETE FROM dishes WHERE id = ?', [int.parse(id)]);

      return Response(204);
    } catch (e) {
      return Response.internalServerError(body: e.toString());
    }
  }
}

