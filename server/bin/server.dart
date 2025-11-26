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

  // Setup Flutter web static handler if directory exists
  Handler? flutterWebHandler;
  final flutterWebPath = path.join(Directory.current.path, 'flutter_web');
  if (Directory(flutterWebPath).existsSync()) {
    print('Flutter web found at: $flutterWebPath');
    flutterWebHandler = createStaticHandler(
      flutterWebPath,
      defaultDocument: 'index.html',
      serveFilesOutsidePath: false,
    );
  } else {
    print('Flutter web not found at: $flutterWebPath');
  }

  // Setup routes with Flutter web middleware
  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addMiddleware((Handler innerHandler) {
        return (Request request) {
          // Handle /flutter paths before routing
          final requestPath = request.url.path;
          if (flutterWebHandler != null && requestPath.startsWith('/flutter')) {
            // Redirect /flutter to /flutter/
            if (requestPath == '/flutter') {
              return Response.movedPermanently('/flutter/');
            }
            // Handle /flutter/ and sub-paths
            if (requestPath.startsWith('/flutter/')) {
              final filePath = requestPath.substring('/flutter'.length);
              final newRequest = request.change(path: filePath.isEmpty ? '/' : filePath);
              return flutterWebHandler(newRequest);
            }
          }
          // Pass to router for other paths
          return innerHandler(request);
        };
      })
      .addHandler(setupRoutes().call);

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

