import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'handlers/user_handler.dart';
import 'handlers/auth_handler.dart';
import 'handlers/post_handler.dart';
import 'handlers/comment_handler.dart';
import 'handlers/storage_handler.dart';
import 'auth/auth_middleware.dart';

Router setupRoutes() {
  final router = Router();
  final userHandler = UserHandler();
  final authHandler = AuthHandler();
  final postHandler = PostHandler();
  final commentHandler = CommentHandler();
  final storageHandler = StorageHandler();

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

  // Update current user profile (protected)
  router.put('/api/auth/me', (Request request) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => authHandler.update(req))(request);
  });

  // Posts routes (public read, protected write)
  router.get('/api/posts', postHandler.getAll);
  router.get('/api/posts/<id>', (Request request, String id) {
    return postHandler.getById(request, id);
  });
  router.get('/api/posts/user/<userId>', (Request request, String userId) {
    return postHandler.getByUser(request, userId);
  });
  router.post('/api/posts', (Request request) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => postHandler.create(req))(request);
  });
  router.put('/api/posts/<id>', (Request request, String id) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => postHandler.update(req, id))(request);
  });
  router.delete('/api/posts/<id>', (Request request, String id) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => postHandler.delete(req, id))(request);
  });
  router.post('/api/posts/<id>/upvote', (Request request, String id) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => postHandler.upvote(req, id))(request);
  });
  router.post('/api/posts/<id>/downvote', (Request request, String id) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => postHandler.downvote(req, id))(request);
  });

  // Comments routes (public read, protected write)
  router.get('/api/posts/<postId>/comments', (Request request, String postId) {
    return commentHandler.getByPost(request, postId);
  });
  router.get('/api/comments/<id>', (Request request, String id) {
    return commentHandler.getById(request, id);
  });
  router.post('/api/posts/<postId>/comments', (Request request, String postId) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => commentHandler.create(req, postId))(request);
  });
  router.put('/api/comments/<id>', (Request request, String id) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => commentHandler.update(req, id))(request);
  });
  router.delete('/api/comments/<id>', (Request request, String id) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => commentHandler.delete(req, id))(request);
  });
  router.post('/api/comments/<id>/upvote', (Request request, String id) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => commentHandler.upvote(req, id))(request);
  });
  router.post('/api/comments/<id>/downvote', (Request request, String id) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => commentHandler.downvote(req, id))(request);
  });

  // Storage routes (protected)
  router.post('/api/storage/upload', (Request request) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => storageHandler.upload(req))(request);
  });
  // List files of current user
  router.get('/api/storage/my', (Request request) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => storageHandler.getMyFiles(req))(request);
  });
  router.get('/api/storage/<filename|.*>', (Request request, String filename) {
    return storageHandler.getFile(request, filename);
  });
  router.delete('/api/storage/<id>', (Request request, String id) {
    return Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler((req) => storageHandler.delete(req, id))(request);
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
      _apiDocsHtml,
      headers: {'Content-Type': 'text/html; charset=utf-8'},
    );
  });

  // Note: Flutter web is handled by middleware in server.dart before routing
  // No routes needed here for /flutter paths

  return router;
}

const _apiDocsHtml = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Flutter Blog API Documentation</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #1a1a1b; color: #d7dadc; line-height: 1.6; }
    .container { max-width: 1000px; margin: 0 auto; padding: 20px; }
    h1 { color: #ff4500; margin-bottom: 10px; }
    h2 { color: #ff4500; margin: 30px 0 15px; border-bottom: 1px solid #343536; padding-bottom: 10px; }
    h3 { color: #818384; margin: 20px 0 10px; }
    .description { color: #818384; margin-bottom: 30px; }
    .endpoint { background: #272729; border-radius: 8px; margin: 10px 0; overflow: hidden; }
    .endpoint-header { padding: 15px; display: flex; align-items: center; gap: 15px; }
    .method { padding: 5px 12px; border-radius: 4px; font-weight: bold; font-size: 12px; min-width: 70px; text-align: center; }
    .get { background: #2e7d32; color: white; }
    .post { background: #1565c0; color: white; }
    .put { background: #f57c00; color: white; }
    .delete { background: #c62828; color: white; }
    .path { font-family: 'Monaco', 'Menlo', monospace; color: #d7dadc; }
    .auth { font-size: 12px; color: #ff4500; margin-left: auto; }
    .endpoint-body { padding: 0 15px 15px; color: #818384; font-size: 14px; }
    code { background: #343536; padding: 2px 6px; border-radius: 3px; font-family: 'Monaco', 'Menlo', monospace; font-size: 13px; }
    pre { background: #343536; padding: 15px; border-radius: 4px; overflow-x: auto; margin: 10px 0; }
    pre code { background: none; padding: 0; }
    .params { margin-top: 10px; }
    .param { display: flex; gap: 10px; margin: 5px 0; }
    .param-name { color: #ff4500; min-width: 120px; }
    .note { background: #343536; border-left: 3px solid #ff4500; padding: 10px 15px; margin: 15px 0; }
  </style>
</head>
<body>
  <div class="container">
    <h1>🔥 Flutter Blog API</h1>
    <p class="description">RESTful API for a Reddit-style blog platform with posts, comments, and voting.</p>

    <h2>🔐 Authentication</h2>
    <p>Protected endpoints require a Bearer token in the Authorization header.</p>
    
    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method post">POST</span>
        <span class="path">/api/auth/register</span>
      </div>
      <div class="endpoint-body">
        Register a new user account.
        <pre><code>{
  "name": "John Doe",
  "phone": "1234567890",
  "password": "password123",
  "image_url": "https://example.com/avatar.jpg" // optional
}</code></pre>
      </div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method post">POST</span>
        <span class="path">/api/auth/login</span>
      </div>
      <div class="endpoint-body">
        Login with phone and password. Returns JWT tokens.
        <pre><code>{
  "phone": "1234567890",
  "password": "password123"
}</code></pre>
        <div style="margin-top:10px;">
          <strong>Example:</strong>
          <pre><code>curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"0987654321","password":"user123"}'</code></pre>
          <strong>Response:</strong>
          <pre><code>{
  "message": "Login successful",
  "token": "<JWT_TOKEN>",
  "user": { "id": 2, "name": "John Doe", "phone": "0987654321", "role": "user" }
}</code></pre>
        </div>
      </div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method get">GET</span>
        <span class="path">/api/auth/me</span>
        <span class="auth">🔒 Auth Required</span>
      </div>
      <div class="endpoint-body">
        Get current user profile.
        <div style="margin-top:10px;">
          <strong>Example:</strong>
          <pre><code>curl -s -H "Authorization: Bearer <JWT_TOKEN>" http://localhost:8080/api/auth/me | python3 -m json.tool</code></pre>
          <strong>Response:</strong>
          <pre><code>{
  "id": 2,
  "name": "John Doe",
  "phone": "0987654321",
  "role": "user"
}</code></pre>
        </div>
      </div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method put">PUT</span>
        <span class="path">/api/auth/me</span>
        <span class="auth">🔒 Auth Required</span>
      </div>
      <div class="endpoint-body">
        Update current user profile.
        <pre><code>{
  "name": "New Name",
  "image_url": "https://example.com/new-avatar.jpg"
}</code></pre>
      </div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method put">PUT</span>
        <span class="path">/api/auth/change-password</span>
        <span class="auth">🔒 Auth Required</span>
      </div>
      <div class="endpoint-body">
        Change password.
        <pre><code>{
  "current_password": "oldpassword",
  "new_password": "newpassword123"
}</code></pre>
      </div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method post">POST</span>
        <span class="path">/api/auth/refresh</span>
        <span class="auth">🔒 Auth Required</span>
      </div>
      <div class="endpoint-body">
        Refresh JWT token for the current user.
        <div style="margin-top:10px;">
          <strong>Example:</strong>
          <pre><code>curl -s -X POST -H "Authorization: Bearer <JWT_TOKEN>" http://localhost:8080/api/auth/refresh | python3 -m json.tool</code></pre>
          <strong>Response:</strong>
          <pre><code>{"message":"Token refreshed","token":"<NEW_JWT_TOKEN>"}</code></pre>
        </div>
      </div>
    </div>

    <h2>📝 Posts</h2>
    
    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method get">GET</span>
        <span class="path">/api/posts</span>
      </div>
      <div class="endpoint-body">
        Get all posts with pagination and sorting.
        <div class="params">
          <div class="param"><span class="param-name">page</span> Page number (default: 1)</div>
          <div class="param"><span class="param-name">limit</span> Items per page (default: 20)</div>
          <div class="param"><span class="param-name">sort</span> Sort by: newest, oldest, top (default: newest)</div>
        </div>
        <div style="margin-top:10px;">
          <strong>Example:</strong>
          <pre><code>curl -s http://localhost:8080/api/posts | python3 -m json.tool</code></pre>
          <strong>Sample Response (truncated):</strong>
          <pre><code>[
  {
    "id": 1,
    "user_id": 2,
    "title": "Getting Started with Flutter",
    "description": "A beginner-friendly guide to Flutter development",
    "image_url": "https://picsum.photos/seed/flutter/800/400",
    "created_at": "2025-12-03 12:09:26",
    "author": { "id": 2, "name": "John Doe" }
  },
  { "id": 2, "title": "Clean Architecture in Dart", "user_id": 3 }
]</code></pre>
        </div>
      </div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method get">GET</span>
        <span class="path">/api/posts/:id</span>
      </div>
      <div class="endpoint-body">
        Get a single post by ID.
        <div style="margin-top:10px;">
          <strong>Example:</strong>
          <pre><code>curl -s http://localhost:8080/api/posts/1 | python3 -m json.tool</code></pre>
          <strong>Response Example:</strong>
          <pre><code>{
  "id": 1,
  "user_id": 2,
  "title": "Getting Started with Flutter",
  "description": "A beginner-friendly guide to Flutter development",
  "body": "Flutter is Google's UI toolkit...",
  "image_url": "https://picsum.photos/seed/flutter/800/400",
  "created_at": "2025-12-03 12:09:26",
  "author": { "id": 2, "name": "John Doe" }
}</code></pre>
        </div>
      </div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method get">GET</span>
        <span class="path">/api/posts/user/:userId</span>
      </div>
      <div class="endpoint-body">Get all posts by a specific user.</div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method post">POST</span>
        <span class="path">/api/posts</span>
        <span class="auth">🔒 Auth Required</span>
      </div>
      <div class="endpoint-body">
        Create a new post.
        <pre><code>{
  "title": "Post Title",
  "description": "Short description",
  "body": "Full post content...",
  "image_url": "https://example.com/image.jpg" // optional
}</code></pre>
        <div style="margin-top:10px;">
          <strong>Example:</strong>
          <pre><code>curl -s -X POST http://localhost:8080/api/posts \
    -H "Authorization: Bearer <JWT_TOKEN>" \
    -H "Content-Type: application/json" \
    -d '{"title":"Test Post from Curl", "description":"Test desc", "body":"Test body via curl"}'</code></pre>
          <strong>Response:</strong>
          <pre><code>{
    "id": 7,
    "user_id": 2,
    "title": "Test Post from Curl",
    "description": "Test desc",
    "body": "Test body via curl",
    "image_url": null,
    "created_at": "2025-12-03 12:18:10",
    "author": { "id": 2, "name": "John Doe", "phone": "0987654321", "role": "user" }
  }</code></pre>
        </div>
      </div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method put">PUT</span>
        <span class="path">/api/posts/:id</span>
        <span class="auth">🔒 Auth Required (Owner)</span>
      </div>
      <div class="endpoint-body">Update a post. Only the author can update.</div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method delete">DELETE</span>
        <span class="path">/api/posts/:id</span>
        <span class="auth">🔒 Auth Required (Owner/Admin)</span>
      </div>
      <div class="endpoint-body">Soft delete a post. Author or admin can delete.</div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method post">POST</span>
        <span class="path">/api/posts/:id/upvote</span>
        <span class="auth">🔒 Auth Required</span>
      </div>
      <div class="endpoint-body">Upvote a post.</div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method post">POST</span>
        <span class="path">/api/posts/:id/downvote</span>
        <span class="auth">🔒 Auth Required</span>
      </div>
      <div class="endpoint-body">Downvote a post.</div>
    </div>

    <h2>💬 Comments</h2>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method get">GET</span>
        <span class="path">/api/posts/:postId/comments</span>
      </div>
      <div class="endpoint-body">
        Get all comments for a post.
        <div class="params">
          <div class="param"><span class="param-name">page</span> Page number (default: 1)</div>
          <div class="param"><span class="param-name">limit</span> Items per page (default: 50)</div>
        </div>
      </div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method get">GET</span>
        <span class="path">/api/comments/:id</span>
      </div>
      <div class="endpoint-body">Get a single comment by ID.</div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method post">POST</span>
        <span class="path">/api/posts/:postId/comments</span>
        <span class="auth">🔒 Auth Required</span>
      </div>
      <div class="endpoint-body">
        Create a comment. Use @username to mention users.
        <pre><code>{
  "comment": "Great post! @john what do you think?"
}</code></pre>
        <div style="margin-top:10px;">
          <strong>Example:</strong>
          <pre><code>curl -s -X POST http://localhost:8080/api/posts/1/comments \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"comment":"Nice post! @jane"}'</code></pre>
          <strong>Response:</strong>
          <pre><code>{
  "id": 15,
  "post_id": 1,
  "user_id": 2,
  "comment": "Nice post! - from curl",
  "mentions": null,
  "created_at": "2025-12-03 12:18:32",
  "author": { "id": 2, "name": "John Doe" }
}</code></pre>
        </div>
      </div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method put">PUT</span>
        <span class="path">/api/comments/:id</span>
        <span class="auth">🔒 Auth Required (Owner)</span>
      </div>
      <div class="endpoint-body">Update a comment. Only the author can update.</div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method delete">DELETE</span>
        <span class="path">/api/comments/:id</span>
        <span class="auth">🔒 Auth Required (Owner/Admin)</span>
      </div>
      <div class="endpoint-body">Delete a comment.</div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method post">POST</span>
        <span class="path">/api/comments/:id/upvote</span>
        <span class="auth">🔒 Auth Required</span>
      </div>
      <div class="endpoint-body">Upvote a comment.</div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method post">POST</span>
        <span class="path">/api/comments/:id/downvote</span>
        <span class="auth">🔒 Auth Required</span>
      </div>
      <div class="endpoint-body">Downvote a comment.</div>
    </div>

    <h2>📁 Storage</h2>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method post">POST</span>
        <span class="path">/api/storage/upload</span>
        <span class="auth">🔒 Auth Required</span>
      </div>
      <div class="endpoint-body">
        Upload a file. Send as multipart/form-data with field name "file".
        Returns the file URL.
        <div style="margin-top:10px;">
          <strong>Example:</strong>
          <pre><code>curl -s -X POST http://localhost:8080/api/storage/upload \
    -H "Authorization: Bearer <JWT_TOKEN>" \
    -F "file=@/tmp/test_upload.txt"</code></pre>
          <strong>Response:</strong>
          <pre><code>{
    "id": 4,
    "file_name": "test_upload.txt",
    "content_type": "text/plain",
    "size": 23,
    "url": "http://localhost:8080/api/storage/2_1764764506713.txt"
  }</code></pre>
        </div>
      </div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method get">GET</span>
        <span class="path">/api/storage/my</span>
        <span class="auth">🔒 Auth Required</span>
      </div>
      <div class="endpoint-body">
        List files uploaded by current user.
        <div style="margin-top:10px;">
          <strong>Example:</strong>
          <pre><code>curl -s -H "Authorization: Bearer <JWT_TOKEN>" http://localhost:8080/api/storage/my | python3 -m json.tool</code></pre>
          <strong>Response:</strong>
          <pre><code>[
  { "id": 3, "owner_id": 2, "file_name":"test_upload.txt", "url":"http://localhost:8080/api/storage/2_...txt" }
]</code></pre>
        </div>
      </div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method get">GET</span>
        <span class="path">/api/storage/:filename</span>
      </div>
      <div class="endpoint-body">
        Get/download a file by filename.
        <div style="margin-top:10px;">
          <strong>Example:</strong>
          <pre><code>curl -s http://localhost:8080/api/storage/2_1764764440729.txt --output downloaded.txt</code></pre>
          <strong>Response:</strong>
          <pre><code>200 OK - file bytes returned (e.g., 'Hello from curl storage')</code></pre>
        </div>
      </div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method delete">DELETE</span>
        <span class="path">/api/storage/:id</span>
        <span class="auth">🔒 Auth Required</span>
      </div>
      <div class="endpoint-body">
        Delete a file (by ID). Use the id from the upload response.
        <div style="margin-top:10px;">
          <strong>Example:</strong>
          <pre><code>curl -s -X DELETE http://localhost:8080/api/storage/3 \
  -H "Authorization: Bearer <JWT_TOKEN>"</code></pre>
          <strong>Response:</strong>
          <pre><code>{"message":"File deleted successfully"}</code></pre>
        </div>
      </div>
    </div>

    <h2>👥 Users (Admin Only)</h2>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method get">GET</span>
        <span class="path">/api/users</span>
        <span class="auth">🔒 Admin Only</span>
      </div>
      <div class="endpoint-body">
        Get all users.
        <div style="margin-top:10px;">
          <strong>Example:</strong>
          <pre><code>curl -s -H "Authorization: Bearer <ADMIN_TOKEN>" http://localhost:8080/api/users | python3 -m json.tool</code></pre>
          <strong>Sample Response:</strong>
          <pre><code>{
  "success": true,
  "data": [
    { "id": 1, "name": "Admin User", "phone": "1234567890", "role":"admin" },
    { "id": 2, "name": "John Doe", "phone": "0987654321", "role":"user" }
  ]
}</code></pre>
        </div>
      </div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header">
        <span class="method get">GET</span>
        <span class="path">/api/users/:id</span>
        <span class="auth">🔒 Admin Only</span>
      </div>
      <div class="endpoint-body">
        Get a user by ID.
        <div style="margin-top:10px;">
          <strong>Example:</strong>
          <pre><code>curl -s -H "Authorization: Bearer <ADMIN_TOKEN>" http://localhost:8080/api/users/2 | python3 -m json.tool</code></pre>
          <strong>Response:</strong>
          <pre><code>{
  "success": true,
  "data": { "id": 2, "name": "John Doe", "phone":"0987654321", "role":"user" }
}</code></pre>
        </div>
      </div>
    </div>

    <div class="note">
      <strong>Health Check:</strong> <code>GET /health</code> - Returns "Server is running"
    </div>

  </div>
</body>
</html>
''';

