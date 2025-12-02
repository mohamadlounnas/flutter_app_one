import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'handlers/dish_handler.dart';
import 'handlers/order_handler.dart';
import 'handlers/user_handler.dart';
import 'handlers/auth_handler.dart';
import 'auth/auth_middleware.dart';
import 'static/api_docs.dart';

Router setupRoutes() {
  final router = Router();
  final dishHandler = DishHandler();
  final orderHandler = OrderHandler();
  final userHandler = UserHandler();
  final authHandler = AuthHandler();

  // Auth routes (public)
  router.post('/api/auth/register', authHandler.register);
  router.post('/api/auth/login', authHandler.login);

  // Auth routes (protected)
  router.get('/api/auth/me', (Request request) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => authHandler.me(req))(request);
  });
  router.post('/api/auth/refresh', (Request request) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => authHandler.refresh(req))(request);
  });
  router.put('/api/auth/change-password', (Request request) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => authHandler.changePassword(req))(request);
  });

  // Dishes routes (public read, protected write)
  router.get('/api/dishes', dishHandler.getAll);
  router.get('/api/dishes/<id>', (Request request, String id) {
    return dishHandler.getById(request, id);
  });
  router.post('/api/dishes', (Request request) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addMiddleware(roleMiddleware(['admin']))
        .addHandler((req) => dishHandler.create(req))(request);
  });
  router.put('/api/dishes/<id>', (Request request, String id) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addMiddleware(roleMiddleware(['admin']))
        .addHandler((req) => dishHandler.update(req, id))(request);
  });
  router.delete('/api/dishes/<id>', (Request request, String id) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addMiddleware(roleMiddleware(['admin']))
        .addHandler((req) => dishHandler.delete(req, id))(request);
  });

  // Orders routes (protected)
  router.get('/api/orders', (Request request) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => orderHandler.getAll(req))(request);
  });
  router.get('/api/orders/<id>', (Request request, String id) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => orderHandler.getById(req, id))(request);
  });
  router.post('/api/orders', (Request request) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => orderHandler.create(req))(request);
  });
  router.put('/api/orders/<id>', (Request request, String id) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => orderHandler.update(req, id))(request);
  });
  router.delete('/api/orders/<id>', (Request request, String id) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => orderHandler.delete(req, id))(request);
  });

  // Users routes (admin only)
  router.get('/api/users', (Request request) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addMiddleware(roleMiddleware(['admin']))
        .addHandler((req) => userHandler.getAll(req))(request);
  });
  router.get('/api/users/<id>', (Request request, String id) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addMiddleware(roleMiddleware(['admin']))
        .addHandler((req) => userHandler.getById(req, id))(request);
  });
  router.post('/api/users', (Request request) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addMiddleware(roleMiddleware(['admin']))
        .addHandler((req) => userHandler.create(req))(request);
  });
  router.put('/api/users/<id>', (Request request, String id) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addMiddleware(roleMiddleware(['admin']))
        .addHandler((req) => userHandler.update(req, id))(request);
  });
  router.delete('/api/users/<id>', (Request request, String id) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addMiddleware(roleMiddleware(['admin']))
        .addHandler((req) => userHandler.delete(req, id))(request);
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

  // Note: Flutter web is handled by middleware in server.dart before routing
  // No routes needed here for /flutter paths

  return router;
}

