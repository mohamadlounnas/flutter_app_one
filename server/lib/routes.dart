import 'dart:io';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:path/path.dart' as path;
import 'handlers/dish_handler.dart';
import 'handlers/order_handler.dart';
import 'handlers/user_handler.dart';
import 'static/api_docs.dart';

Router setupRoutes() {
  final router = Router();
  final dishHandler = DishHandler();
  final orderHandler = OrderHandler();
  final userHandler = UserHandler();

  // Dishes routes
  router.get('/api/dishes', dishHandler.getAll);
  router.get('/api/dishes/<id>', (Request request, String id) {
    return dishHandler.getById(request, id);
  });
  router.post('/api/dishes', dishHandler.create);
  router.put('/api/dishes/<id>', (Request request, String id) {
    return dishHandler.update(request, id);
  });
  router.delete('/api/dishes/<id>', (Request request, String id) {
    return dishHandler.delete(request, id);
  });

  // Orders routes
  router.get('/api/orders', orderHandler.getAll);
  router.get('/api/orders/<id>', (Request request, String id) {
    return orderHandler.getById(request, id);
  });
  router.post('/api/orders', orderHandler.create);
  router.put('/api/orders/<id>', (Request request, String id) {
    return orderHandler.update(request, id);
  });
  router.delete('/api/orders/<id>', (Request request, String id) {
    return orderHandler.delete(request, id);
  });

  // Users routes
  router.get('/api/users', userHandler.getAll);
  router.get('/api/users/<id>', (Request request, String id) {
    return userHandler.getById(request, id);
  });
  router.post('/api/users', userHandler.create);
  router.put('/api/users/<id>', (Request request, String id) {
    return userHandler.update(request, id);
  });
  router.delete('/api/users/<id>', (Request request, String id) {
    return userHandler.delete(request, id);
  });

  // Health check
  router.get('/health', (Request request) {
    return Response.ok('Server is running');
  });

  // API Documentation (home page)
  router.get('/', (Request request) {
    return Response.ok(
      apiDocsHtml,
      headers: {'Content-Type': 'text/html; charset=utf-8'},
    );
  });

  // Flutter Web App - serve static files from /flutter
  final flutterWebPath = path.join(Directory.current.path, 'flutter_web');
  if (Directory(flutterWebPath).existsSync()) {
    final flutterHandler = createStaticHandler(
      flutterWebPath,
      defaultDocument: 'index.html',
      serveFilesOutsidePath: false,
    );
    
    // Serve Flutter web app - handle all paths under /flutter
    router.all('/flutter<path|.*>', (Request request) {
      // Extract the path after /flutter
      final requestPath = request.url.path;
      String filePath;
      
      if (requestPath == '/flutter' || requestPath == '/flutter/') {
        filePath = '/';
      } else {
        // Remove /flutter prefix
        filePath = requestPath.replaceFirst('/flutter', '');
        if (filePath.isEmpty) filePath = '/';
      }
      
      // Create new request with adjusted path
      final newRequest = request.change(path: filePath);
      return flutterHandler(newRequest);
    });
  }

  return router;
}

