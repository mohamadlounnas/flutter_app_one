import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:path/path.dart' as path;
import '../lib/database/database.dart';
import '../lib/routes.dart';
import '../lib/test_data.dart';

void main(List<String> arguments) async {
  // Initialize database
  AppDatabase.instance.initialize();

  // Inject test data
  injectTestData();

  // Setup routes
  final router = setupRoutes();
  
  // Setup Flutter web static handler if directory exists
  final flutterWebPath = path.join(Directory.current.path, 'flutter_web');
  print('Checking Flutter web at: $flutterWebPath');
  print('Directory exists: ${Directory(flutterWebPath).existsSync()}');
  
  Handler handler;
  if (Directory(flutterWebPath).existsSync()) {
    print('Flutter web found - setting up static handler');
    final flutterHandler = createStaticHandler(
      flutterWebPath,
      defaultDocument: 'index.html',
    );
    
    // Create a handler that checks path and routes accordingly
    handler = Pipeline()
        .addMiddleware(corsHeaders())
        .addMiddleware(logRequests())
        .addHandler((Request request) {
          final requestPath = request.url.path;
          
          // Handle /flutter paths
          if (requestPath == '/flutter' || requestPath == '/flutter/') {
            // Serve index.html for /flutter/
            final indexRequest = request.change(path: '/');
            return flutterHandler(indexRequest);
          } else if (requestPath.startsWith('/flutter/')) {
            // Serve files under /flutter/
            final filePath = requestPath.substring('/flutter'.length);
            final fileRequest = request.change(path: filePath.isEmpty ? '/' : filePath);
            return flutterHandler(fileRequest);
          }
          
          // All other paths go to router
          return router(request);
        });
  } else {
    print('Flutter web not found - serving API only');
    handler = Pipeline()
        .addMiddleware(corsHeaders())
        .addMiddleware(logRequests())
        .addHandler(router);
  }

  // Get port from environment or use default
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  
  // Get host - use 0.0.0.0 to allow access from local network
  final host = InternetAddress.anyIPv4;

  final server = await shelf_io.serve(handler, host, port);
  final localIP = await _getLocalIP();

  print('Server running on http://${server.address.host}:${server.port}');
  print('Local network access: http://$localIP:${server.port}');
  print('');
  print('Available endpoints:');
  print('  GET    /api/dishes');
  print('  GET    /api/dishes/<id>');
  print('  POST   /api/dishes');
  print('  PUT    /api/dishes/<id>');
  print('  DELETE /api/dishes/<id>');
  print('');
  print('  GET    /api/orders');
  print('  GET    /api/orders/<id>');
  print('  POST   /api/orders');
  print('  PUT    /api/orders/<id>');
  print('  DELETE /api/orders/<id>');
  print('');
  print('  GET    /api/users');
  print('  GET    /api/users/<id>');
  print('  POST   /api/users');
  print('  PUT    /api/users/<id>');
  print('  DELETE /api/users/<id>');
  print('');
  print('  GET    /health');
}

Future<String> _getLocalIP() async {
  try {
    final interfaces = await NetworkInterface.list();
    for (var interface in interfaces) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
          return addr.address;
        }
      }
    }
  } catch (e) {
    print('Could not determine local IP: $e');
  }
  return 'localhost';
}

