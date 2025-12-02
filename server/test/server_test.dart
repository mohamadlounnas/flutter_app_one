import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../lib/database/database.dart';
import '../lib/test_data.dart';

void main() {
  group('Server API Tests', () {
    const baseUrl = 'http://localhost:8080';

    setUpAll(() {
      // Initialize database and inject test data
      AppDatabase.instance.initialize();
      injectTestData();
    });

    tearDownAll(() {
      AppDatabase.instance.close();
    });

    group('Dishes API', () {
      test('GET /api/dishes - should return list of dishes', () async {
        final response = await http.get(Uri.parse('$baseUrl/api/dishes'));
        expect(response.statusCode, 200);
        final data = jsonDecode(response.body);
        expect(data['success'], true);
        expect(data['data'], isA<List>());
        expect(data['data'].length, greaterThan(0));
      });

      test('GET /api/dishes/<id> - should return a specific dish', () async {
        final response = await http.get(Uri.parse('$baseUrl/api/dishes/1'));
        expect(response.statusCode, 200);
        final data = jsonDecode(response.body);
        expect(data['success'], true);
        expect(data['data'], isA<Map>());
        expect(data['data']['id'], 1);
      });

      test('POST /api/dishes - should create a new dish', () async {
        final newDish = {
          'name': 'Test Dish',
          'photoUrl': 'https://example.com/test.jpg',
          'price': 15.99,
        };
        final response = await http.post(
          Uri.parse('$baseUrl/api/dishes'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(newDish),
        );
        expect(response.statusCode, 200);
        final data = jsonDecode(response.body);
        expect(data['success'], true);
        expect(data['data']['name'], 'Test Dish');
      });

      test('PUT /api/dishes/<id> - should update a dish', () async {
        final updatedDish = {
          'name': 'Updated Dish',
          'photoUrl': 'https://example.com/updated.jpg',
          'price': 19.99,
        };
        final response = await http.put(
          Uri.parse('$baseUrl/api/dishes/1'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(updatedDish),
        );
        expect(response.statusCode, 200);
        final data = jsonDecode(response.body);
        expect(data['success'], true);
        expect(data['data']['name'], 'Updated Dish');
      });

      test('DELETE /api/dishes/<id> - should delete a dish', () async {
        // First create a dish to delete
        final newDish = {
          'name': 'To Delete',
          'photoUrl': 'https://example.com/delete.jpg',
          'price': 10.0,
        };
        final createResponse = await http.post(
          Uri.parse('$baseUrl/api/dishes'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(newDish),
        );
        final createdData = jsonDecode(createResponse.body);
        final dishId = createdData['data']['id'];

        // Now delete it
        final deleteResponse = await http.delete(
          Uri.parse('$baseUrl/api/dishes/$dishId'),
        );
        expect(deleteResponse.statusCode, 200);
        final deleteData = jsonDecode(deleteResponse.body);
        expect(deleteData['success'], true);
      });
    });

    group('Orders API', () {
      test('GET /api/orders - should return list of orders', () async {
        final response = await http.get(Uri.parse('$baseUrl/api/orders'));
        expect(response.statusCode, 200);
        final data = jsonDecode(response.body);
        expect(data['success'], true);
        expect(data['data'], isA<List>());
      });

      test('POST /api/orders - should create a new order', () async {
        final newOrder = {
          'userId': 1,
          'phone': '5551234567',
          'dishId': '1',
          'latitude': 40.7128,
          'longitude': -74.0060,
          'address': '123 Test St',
          'completed': false,
        };
        final response = await http.post(
          Uri.parse('$baseUrl/api/orders'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(newOrder),
        );
        expect(response.statusCode, 200);
        final data = jsonDecode(response.body);
        expect(data['success'], true);
        expect(data['data']['phone'], '5551234567');
      });
    });

    group('Users API', () {
      test('GET /api/users - should return list of users', () async {
        final response = await http.get(Uri.parse('$baseUrl/api/users'));
        expect(response.statusCode, 200);
        final data = jsonDecode(response.body);
        expect(data['success'], true);
        expect(data['data'], isA<List>());
        expect(data['data'].length, greaterThan(0));
      });

      test('POST /api/users - should create a new user', () async {
        final newUser = {
          'name': 'Test User',
          'phone': '9998887777',
          'password': 'test123',
          'role': 'user',
        };
        final response = await http.post(
          Uri.parse('$baseUrl/api/users'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(newUser),
        );
        expect(response.statusCode, 200);
        final data = jsonDecode(response.body);
        expect(data['success'], true);
        expect(data['data']['name'], 'Test User');
      });
    });

    group('Health Check', () {
      test('GET /health - should return server status', () async {
        final response = await http.get(Uri.parse('$baseUrl/health'));
        expect(response.statusCode, 200);
        expect(response.body, 'Server is running');
      });
    });
  });
}



