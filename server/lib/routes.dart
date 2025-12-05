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
  <title>Flutter Blog API - Interactive Docs</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #1a1a1b; color: #d7dadc; line-height: 1.6; }
    .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
    h1 { color: #ff4500; margin-bottom: 10px; }
    h2 { color: #ff4500; margin: 30px 0 15px; border-bottom: 1px solid #343536; padding-bottom: 10px; }
    h3 { color: #818384; margin: 20px 0 10px; }
    .description { color: #818384; margin-bottom: 20px; }
    
    /* Auth Panel */
    .auth-panel { background: #272729; border-radius: 8px; padding: 20px; margin-bottom: 30px; border: 1px solid #343536; }
    .auth-panel h3 { color: #ff4500; margin-bottom: 15px; display: flex; align-items: center; gap: 10px; }
    .auth-status { display: flex; align-items: center; gap: 15px; margin-bottom: 15px; flex-wrap: wrap; }
    .status-badge { padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; }
    .status-logged-in { background: #2e7d32; color: white; }
    .status-logged-out { background: #c62828; color: white; }
    .user-info { color: #818384; font-size: 14px; }
    .auth-form { display: flex; gap: 10px; flex-wrap: wrap; align-items: flex-end; }
    .form-group { display: flex; flex-direction: column; gap: 5px; }
    .form-group label { font-size: 12px; color: #818384; }
    .form-group input { background: #1a1a1b; border: 1px solid #343536; color: #d7dadc; padding: 8px 12px; border-radius: 4px; font-size: 14px; }
    .form-group input:focus { outline: none; border-color: #ff4500; }
    .btn { padding: 8px 16px; border-radius: 4px; border: none; cursor: pointer; font-weight: bold; font-size: 14px; transition: opacity 0.2s; }
    .btn:hover { opacity: 0.8; }
    .btn-primary { background: #ff4500; color: white; }
    .btn-secondary { background: #343536; color: #d7dadc; }
    .btn-danger { background: #c62828; color: white; }
    .token-display { background: #1a1a1b; border: 1px solid #343536; padding: 10px; border-radius: 4px; font-family: monospace; font-size: 12px; word-break: break-all; margin-top: 10px; max-height: 60px; overflow-y: auto; }
    
    /* Endpoint Styles */
    .endpoint { background: #272729; border-radius: 8px; margin: 10px 0; overflow: hidden; border: 1px solid #343536; }
    .endpoint-header { padding: 15px; display: flex; align-items: center; gap: 15px; cursor: pointer; transition: background 0.2s; }
    .endpoint-header:hover { background: #343536; }
    .method { padding: 5px 12px; border-radius: 4px; font-weight: bold; font-size: 12px; min-width: 70px; text-align: center; }
    .get { background: #2e7d32; color: white; }
    .post { background: #1565c0; color: white; }
    .put { background: #f57c00; color: white; }
    .delete { background: #c62828; color: white; }
    .path { font-family: 'Monaco', 'Menlo', monospace; color: #d7dadc; flex: 1; }
    .auth-badge { font-size: 12px; color: #ff4500; }
    .expand-icon { color: #818384; transition: transform 0.2s; }
    .endpoint.expanded .expand-icon { transform: rotate(90deg); }
    .endpoint-body { display: none; padding: 15px; border-top: 1px solid #343536; }
    .endpoint.expanded .endpoint-body { display: block; }
    
    /* Try It Panel */
    .try-it { background: #1a1a1b; border-radius: 4px; padding: 15px; margin-top: 15px; }
    .try-it h4 { color: #ff4500; margin-bottom: 10px; font-size: 14px; }
    .try-it-form { display: flex; flex-direction: column; gap: 10px; }
    .try-it-row { display: flex; gap: 10px; align-items: center; }
    .try-it-row label { min-width: 100px; font-size: 13px; color: #818384; }
    .try-it-row input, .try-it-row textarea, .try-it-row select { flex: 1; background: #272729; border: 1px solid #343536; color: #d7dadc; padding: 8px; border-radius: 4px; font-family: inherit; font-size: 13px; }
    .try-it-row textarea { min-height: 80px; resize: vertical; font-family: monospace; }
    .try-it-row input[type="file"] { padding: 5px; }
    .response-panel { margin-top: 15px; }
    .response-panel h5 { font-size: 13px; color: #818384; margin-bottom: 5px; }
    .response-output { background: #272729; border: 1px solid #343536; border-radius: 4px; padding: 10px; font-family: monospace; font-size: 12px; max-height: 300px; overflow: auto; white-space: pre-wrap; word-break: break-all; }
    .response-output.success { border-color: #2e7d32; }
    .response-output.error { border-color: #c62828; }
    .response-status { font-size: 12px; margin-bottom: 5px; }
    .response-status.success { color: #4caf50; }
    .response-status.error { color: #f44336; }
    
    code { background: #343536; padding: 2px 6px; border-radius: 3px; font-family: 'Monaco', 'Menlo', monospace; font-size: 13px; }
    pre { background: #343536; padding: 15px; border-radius: 4px; overflow-x: auto; margin: 10px 0; }
    pre code { background: none; padding: 0; }
    .params { margin-top: 10px; }
    .param { display: flex; gap: 10px; margin: 5px 0; font-size: 14px; }
    .param-name { color: #ff4500; min-width: 120px; }
    .note { background: #343536; border-left: 3px solid #ff4500; padding: 10px 15px; margin: 15px 0; font-size: 14px; }
    .endpoint-desc { color: #818384; font-size: 14px; margin-bottom: 10px; }
    
    /* Tabs */
    .tabs { display: flex; gap: 5px; margin-bottom: 10px; }
    .tab { padding: 8px 16px; background: #343536; border: none; color: #818384; cursor: pointer; border-radius: 4px 4px 0 0; font-size: 13px; }
    .tab.active { background: #1a1a1b; color: #ff4500; }
    .tab-content { display: none; }
    .tab-content.active { display: block; }
    
    /* Loading */
    .loading { display: inline-block; width: 16px; height: 16px; border: 2px solid #343536; border-top-color: #ff4500; border-radius: 50%; animation: spin 1s linear infinite; }
    @keyframes spin { to { transform: rotate(360deg); } }
    
    /* Image Preview */
    .image-preview { max-width: 200px; max-height: 150px; margin-top: 10px; border-radius: 4px; }
  </style>
</head>
<body>
  <div class="container">
    <h1>🔥 Flutter Blog API</h1>
    <p class="description">Interactive API documentation - Login to test authenticated endpoints</p>

    <!-- Auth Panel -->
    <div class="auth-panel">
      <h3>🔐 Authentication</h3>
      <div class="auth-status">
        <span id="statusBadge" class="status-badge status-logged-out">Not Logged In</span>
        <span id="userInfo" class="user-info"></span>
      </div>
      
      <div class="tabs">
        <button class="tab active" onclick="showAuthTab('login')">Login</button>
        <button class="tab" onclick="showAuthTab('register')">Register</button>
        <button class="tab" onclick="showAuthTab('token')">Token</button>
      </div>
      
      <div id="loginTab" class="tab-content active">
        <div class="auth-form">
          <div class="form-group">
            <label>Phone</label>
            <input type="text" id="loginPhone" placeholder="0987654321" value="0987654321">
          </div>
          <div class="form-group">
            <label>Password</label>
            <input type="password" id="loginPassword" placeholder="Password" value="user123">
          </div>
          <button class="btn btn-primary" onclick="doLogin()">Login</button>
          <button class="btn btn-danger" onclick="doLogout()" id="logoutBtn" style="display:none;">Logout</button>
        </div>
      </div>
      
      <div id="registerTab" class="tab-content">
        <div class="auth-form">
          <div class="form-group">
            <label>Name</label>
            <input type="text" id="regName" placeholder="John Doe">
          </div>
          <div class="form-group">
            <label>Phone</label>
            <input type="text" id="regPhone" placeholder="1234567890">
          </div>
          <div class="form-group">
            <label>Password</label>
            <input type="password" id="regPassword" placeholder="Password">
          </div>
          <button class="btn btn-primary" onclick="doRegister()">Register</button>
        </div>
      </div>
      
      <div id="tokenTab" class="tab-content">
        <div class="form-group" style="width: 100%;">
          <label>Current Token (click to copy)</label>
          <div id="tokenDisplay" class="token-display" onclick="copyToken()" style="cursor: pointer;">No token - please login</div>
        </div>
        <div style="margin-top: 10px;">
          <button class="btn btn-secondary" onclick="copyToken()">📋 Copy Token</button>
        </div>
      </div>
    </div>

    <h2>🔐 Auth Endpoints</h2>
    
    <div class="endpoint" data-method="POST" data-path="/api/auth/login">
      <div class="endpoint-header" onclick="toggleEndpoint(this.parentElement)">
        <span class="method post">POST</span>
        <span class="path">/api/auth/login</span>
        <span class="expand-icon">▶</span>
      </div>
      <div class="endpoint-body">
        <p class="endpoint-desc">Login with phone and password. Returns JWT token.</p>
        <div class="try-it">
          <h4>▶ Try It</h4>
          <div class="try-it-form">
            <div class="try-it-row">
              <label>Body (JSON)</label>
              <textarea id="body-login">{"phone": "0987654321", "password": "user123"}</textarea>
            </div>
            <button class="btn btn-primary" onclick="tryRequest('POST', '/api/auth/login', 'body-login', 'response-login', false)">Send Request</button>
          </div>
          <div class="response-panel">
            <h5>Response</h5>
            <div id="response-login" class="response-output">Click "Send Request" to see response</div>
          </div>
        </div>
      </div>
    </div>

    <div class="endpoint" data-method="GET" data-path="/api/auth/me">
      <div class="endpoint-header" onclick="toggleEndpoint(this.parentElement)">
        <span class="method get">GET</span>
        <span class="path">/api/auth/me</span>
        <span class="auth-badge">🔒 Auth</span>
        <span class="expand-icon">▶</span>
      </div>
      <div class="endpoint-body">
        <p class="endpoint-desc">Get current user profile.</p>
        <div class="try-it">
          <h4>▶ Try It</h4>
          <button class="btn btn-primary" onclick="tryRequest('GET', '/api/auth/me', null, 'response-me', true)">Send Request</button>
          <div class="response-panel">
            <h5>Response</h5>
            <div id="response-me" class="response-output">Click "Send Request" to see response</div>
          </div>
        </div>
      </div>
    </div>

    <h2>📝 Posts</h2>
    
    <div class="endpoint">
      <div class="endpoint-header" onclick="toggleEndpoint(this.parentElement)">
        <span class="method get">GET</span>
        <span class="path">/api/posts</span>
        <span class="expand-icon">▶</span>
      </div>
      <div class="endpoint-body">
        <p class="endpoint-desc">Get all posts with pagination.</p>
        <div class="params">
          <div class="param"><span class="param-name">page</span> Page number (default: 1)</div>
          <div class="param"><span class="param-name">limit</span> Items per page (default: 20)</div>
        </div>
        <div class="try-it">
          <h4>▶ Try It</h4>
          <div class="try-it-form">
            <div class="try-it-row">
              <label>Query Params</label>
              <input type="text" id="query-posts" placeholder="page=1&limit=5" value="page=1&limit=5">
            </div>
            <button class="btn btn-primary" onclick="tryRequestWithQuery('GET', '/api/posts', 'query-posts', 'response-posts')">Send Request</button>
          </div>
          <div class="response-panel">
            <h5>Response</h5>
            <div id="response-posts" class="response-output">Click "Send Request" to see response</div>
          </div>
        </div>
      </div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header" onclick="toggleEndpoint(this.parentElement)">
        <span class="method get">GET</span>
        <span class="path">/api/posts/:id</span>
        <span class="expand-icon">▶</span>
      </div>
      <div class="endpoint-body">
        <p class="endpoint-desc">Get a single post by ID.</p>
        <div class="try-it">
          <h4>▶ Try It</h4>
          <div class="try-it-form">
            <div class="try-it-row">
              <label>Post ID</label>
              <input type="text" id="param-post-id" placeholder="1" value="1">
            </div>
            <button class="btn btn-primary" onclick="tryRequestWithParam('GET', '/api/posts/{id}', 'param-post-id', 'response-post-single')">Send Request</button>
          </div>
          <div class="response-panel">
            <h5>Response</h5>
            <div id="response-post-single" class="response-output">Click "Send Request" to see response</div>
          </div>
        </div>
      </div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header" onclick="toggleEndpoint(this.parentElement)">
        <span class="method post">POST</span>
        <span class="path">/api/posts</span>
        <span class="auth-badge">🔒 Auth</span>
        <span class="expand-icon">▶</span>
      </div>
      <div class="endpoint-body">
        <p class="endpoint-desc">Create a new post.</p>
        <div class="try-it">
          <h4>▶ Try It</h4>
          <div class="try-it-form">
            <div class="try-it-row">
              <label>Body (JSON)</label>
              <textarea id="body-create-post">{
  "title": "Test Post",
  "description": "A test post from the API docs",
  "body": "This is the full content of my test post."
}</textarea>
            </div>
            <button class="btn btn-primary" onclick="tryRequest('POST', '/api/posts', 'body-create-post', 'response-create-post', true)">Send Request</button>
          </div>
          <div class="response-panel">
            <h5>Response</h5>
            <div id="response-create-post" class="response-output">Click "Send Request" to see response</div>
          </div>
        </div>
      </div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header" onclick="toggleEndpoint(this.parentElement)">
        <span class="method post">POST</span>
        <span class="path">/api/posts/:id/upvote</span>
        <span class="auth-badge">🔒 Auth</span>
        <span class="expand-icon">▶</span>
      </div>
      <div class="endpoint-body">
        <p class="endpoint-desc">Upvote a post.</p>
        <div class="try-it">
          <h4>▶ Try It</h4>
          <div class="try-it-form">
            <div class="try-it-row">
              <label>Post ID</label>
              <input type="text" id="param-upvote-id" placeholder="1" value="1">
            </div>
            <button class="btn btn-primary" onclick="tryRequestWithParam('POST', '/api/posts/{id}/upvote', 'param-upvote-id', 'response-upvote', true)">Send Request</button>
          </div>
          <div class="response-panel">
            <h5>Response</h5>
            <div id="response-upvote" class="response-output">Click "Send Request" to see response</div>
          </div>
        </div>
      </div>
    </div>

    <h2>💬 Comments</h2>
    
    <div class="endpoint">
      <div class="endpoint-header" onclick="toggleEndpoint(this.parentElement)">
        <span class="method get">GET</span>
        <span class="path">/api/posts/:postId/comments</span>
        <span class="expand-icon">▶</span>
      </div>
      <div class="endpoint-body">
        <p class="endpoint-desc">Get all comments for a post.</p>
        <div class="try-it">
          <h4>▶ Try It</h4>
          <div class="try-it-form">
            <div class="try-it-row">
              <label>Post ID</label>
              <input type="text" id="param-comments-post-id" placeholder="1" value="1">
            </div>
            <button class="btn btn-primary" onclick="tryRequestWithParam('GET', '/api/posts/{id}/comments', 'param-comments-post-id', 'response-comments')">Send Request</button>
          </div>
          <div class="response-panel">
            <h5>Response</h5>
            <div id="response-comments" class="response-output">Click "Send Request" to see response</div>
          </div>
        </div>
      </div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header" onclick="toggleEndpoint(this.parentElement)">
        <span class="method post">POST</span>
        <span class="path">/api/posts/:postId/comments</span>
        <span class="auth-badge">🔒 Auth</span>
        <span class="expand-icon">▶</span>
      </div>
      <div class="endpoint-body">
        <p class="endpoint-desc">Add a comment to a post.</p>
        <div class="try-it">
          <h4>▶ Try It</h4>
          <div class="try-it-form">
            <div class="try-it-row">
              <label>Post ID</label>
              <input type="text" id="param-add-comment-id" placeholder="1" value="1">
            </div>
            <div class="try-it-row">
              <label>Body (JSON)</label>
              <textarea id="body-add-comment">{"comment": "Great post! 🎉"}</textarea>
            </div>
            <button class="btn btn-primary" onclick="tryCommentRequest()">Send Request</button>
          </div>
          <div class="response-panel">
            <h5>Response</h5>
            <div id="response-add-comment" class="response-output">Click "Send Request" to see response</div>
          </div>
        </div>
      </div>
    </div>

    <h2>📁 Storage (File Upload)</h2>
    
    <div class="endpoint">
      <div class="endpoint-header" onclick="toggleEndpoint(this.parentElement)">
        <span class="method post">POST</span>
        <span class="path">/api/storage/upload</span>
        <span class="auth-badge">🔒 Auth</span>
        <span class="expand-icon">▶</span>
      </div>
      <div class="endpoint-body">
        <p class="endpoint-desc">Upload a file. Supports images (JPEG, PNG, GIF, WebP), PDFs, and other files.</p>
        <div class="try-it">
          <h4>▶ Try It</h4>
          <div class="try-it-form">
            <div class="try-it-row">
              <label>Select File</label>
              <input type="file" id="upload-file" accept="image/*,.pdf,.txt" onchange="previewFile()">
            </div>
            <div id="file-preview-container" style="display:none;">
              <img id="file-preview" class="image-preview">
            </div>
            <button class="btn btn-primary" onclick="uploadFile()">Upload File</button>
          </div>
          <div class="response-panel">
            <h5>Response</h5>
            <div id="response-upload" class="response-output">Select a file and click "Upload File"</div>
          </div>
        </div>
      </div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header" onclick="toggleEndpoint(this.parentElement)">
        <span class="method get">GET</span>
        <span class="path">/api/storage/my</span>
        <span class="auth-badge">🔒 Auth</span>
        <span class="expand-icon">▶</span>
      </div>
      <div class="endpoint-body">
        <p class="endpoint-desc">List all files uploaded by current user.</p>
        <div class="try-it">
          <h4>▶ Try It</h4>
          <button class="btn btn-primary" onclick="tryRequest('GET', '/api/storage/my', null, 'response-my-files', true)">Send Request</button>
          <div class="response-panel">
            <h5>Response</h5>
            <div id="response-my-files" class="response-output">Click "Send Request" to see response</div>
          </div>
        </div>
      </div>
    </div>

    <div class="endpoint">
      <div class="endpoint-header" onclick="toggleEndpoint(this.parentElement)">
        <span class="method delete">DELETE</span>
        <span class="path">/api/storage/:id</span>
        <span class="auth-badge">🔒 Auth</span>
        <span class="expand-icon">▶</span>
      </div>
      <div class="endpoint-body">
        <p class="endpoint-desc">Delete a file by its ID.</p>
        <div class="try-it">
          <h4>▶ Try It</h4>
          <div class="try-it-form">
            <div class="try-it-row">
              <label>File ID</label>
              <input type="text" id="param-delete-file-id" placeholder="1">
            </div>
            <button class="btn btn-danger" onclick="tryRequestWithParam('DELETE', '/api/storage/{id}', 'param-delete-file-id', 'response-delete-file', true)">Delete File</button>
          </div>
          <div class="response-panel">
            <h5>Response</h5>
            <div id="response-delete-file" class="response-output">Enter file ID and click "Delete File"</div>
          </div>
        </div>
      </div>
    </div>

    <h2>👥 Users (Admin Only)</h2>
    
    <div class="endpoint">
      <div class="endpoint-header" onclick="toggleEndpoint(this.parentElement)">
        <span class="method get">GET</span>
        <span class="path">/api/users</span>
        <span class="auth-badge">🔒 Admin</span>
        <span class="expand-icon">▶</span>
      </div>
      <div class="endpoint-body">
        <p class="endpoint-desc">Get all users (admin only).</p>
        <div class="try-it">
          <h4>▶ Try It</h4>
          <button class="btn btn-primary" onclick="tryRequest('GET', '/api/users', null, 'response-users', true)">Send Request</button>
          <div class="response-panel">
            <h5>Response</h5>
            <div id="response-users" class="response-output">Click "Send Request" to see response</div>
          </div>
        </div>
      </div>
    </div>

    <div class="note">
      <strong>💡 Tips:</strong><br>
      • Login first to test authenticated endpoints<br>
      • Default test user: phone <code>0987654321</code>, password <code>user123</code><br>
      • Admin user: phone <code>1234567890</code>, password <code>admin123</code><br>
      • Click on any endpoint to expand and try it
    </div>

  </div>

  <script>
    let authToken = localStorage.getItem('apiToken') || '';
    let currentUser = JSON.parse(localStorage.getItem('apiUser') || 'null');
    
    // Initialize UI on load
    document.addEventListener('DOMContentLoaded', () => {
      updateAuthUI();
    });
    
    function updateAuthUI() {
      const badge = document.getElementById('statusBadge');
      const userInfo = document.getElementById('userInfo');
      const tokenDisplay = document.getElementById('tokenDisplay');
      const logoutBtn = document.getElementById('logoutBtn');
      
      if (authToken && currentUser) {
        badge.className = 'status-badge status-logged-in';
        badge.textContent = 'Logged In';
        userInfo.textContent = currentUser.name + ' (' + currentUser.role + ')';
        tokenDisplay.textContent = authToken;
        logoutBtn.style.display = 'inline-block';
      } else {
        badge.className = 'status-badge status-logged-out';
        badge.textContent = 'Not Logged In';
        userInfo.textContent = '';
        tokenDisplay.textContent = 'No token - please login';
        logoutBtn.style.display = 'none';
      }
    }
    
    function showAuthTab(tab) {
      document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
      document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
      document.querySelector('.tab[onclick*="' + tab + '"]').classList.add('active');
      document.getElementById(tab + 'Tab').classList.add('active');
    }
    
    async function doLogin() {
      const phone = document.getElementById('loginPhone').value;
      const password = document.getElementById('loginPassword').value;
      
      try {
        const res = await fetch('/api/auth/login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ phone, password })
        });
        const data = await res.json();
        
        if (res.ok && data.token) {
          authToken = data.token;
          currentUser = data.user;
          localStorage.setItem('apiToken', authToken);
          localStorage.setItem('apiUser', JSON.stringify(currentUser));
          updateAuthUI();
          alert('✅ Login successful!');
        } else {
          alert('❌ Login failed: ' + (data.error || 'Unknown error'));
        }
      } catch (e) {
        alert('❌ Error: ' + e.message);
      }
    }
    
    async function doRegister() {
      const name = document.getElementById('regName').value;
      const phone = document.getElementById('regPhone').value;
      const password = document.getElementById('regPassword').value;
      
      try {
        const res = await fetch('/api/auth/register', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ name, phone, password })
        });
        const data = await res.json();
        
        if (res.ok) {
          alert('✅ Registration successful! You can now login.');
          showAuthTab('login');
          document.getElementById('loginPhone').value = phone;
        } else {
          alert('❌ Registration failed: ' + (data.error || 'Unknown error'));
        }
      } catch (e) {
        alert('❌ Error: ' + e.message);
      }
    }
    
    function doLogout() {
      authToken = '';
      currentUser = null;
      localStorage.removeItem('apiToken');
      localStorage.removeItem('apiUser');
      updateAuthUI();
    }
    
    function copyToken() {
      if (authToken) {
        navigator.clipboard.writeText(authToken);
        alert('📋 Token copied to clipboard!');
      }
    }
    
    function toggleEndpoint(el) {
      el.classList.toggle('expanded');
    }
    
    async function tryRequest(method, path, bodyInputId, responseId, requireAuth) {
      const responseEl = document.getElementById(responseId);
      responseEl.innerHTML = '<span class="loading"></span> Loading...';
      responseEl.className = 'response-output';
      
      const headers = { 'Content-Type': 'application/json' };
      if (requireAuth && authToken) {
        headers['Authorization'] = 'Bearer ' + authToken;
      }
      
      const options = { method, headers };
      if (bodyInputId) {
        const bodyEl = document.getElementById(bodyInputId);
        if (bodyEl) options.body = bodyEl.value;
      }
      
      try {
        const res = await fetch(path, options);
        const text = await res.text();
        let formatted = text;
        try {
          formatted = JSON.stringify(JSON.parse(text), null, 2);
        } catch {}
        
        responseEl.innerHTML = '<div class="response-status ' + (res.ok ? 'success' : 'error') + '">' + res.status + ' ' + res.statusText + '</div>' + formatted;
        responseEl.className = 'response-output ' + (res.ok ? 'success' : 'error');
      } catch (e) {
        responseEl.innerHTML = 'Error: ' + e.message;
        responseEl.className = 'response-output error';
      }
    }
    
    async function tryRequestWithQuery(method, basePath, queryInputId, responseId, requireAuth) {
      const query = document.getElementById(queryInputId).value;
      const path = query ? basePath + '?' + query : basePath;
      await tryRequest(method, path, null, responseId, requireAuth);
    }
    
    async function tryRequestWithParam(method, pathTemplate, paramInputId, responseId, requireAuth) {
      const paramValue = document.getElementById(paramInputId).value;
      const path = pathTemplate.replace('{id}', paramValue);
      await tryRequest(method, path, null, responseId, requireAuth);
    }
    
    async function tryCommentRequest() {
      const postId = document.getElementById('param-add-comment-id').value;
      const path = '/api/posts/' + postId + '/comments';
      await tryRequest('POST', path, 'body-add-comment', 'response-add-comment', true);
    }
    
    function previewFile() {
      const input = document.getElementById('upload-file');
      const preview = document.getElementById('file-preview');
      const container = document.getElementById('file-preview-container');
      
      if (input.files && input.files[0]) {
        const file = input.files[0];
        if (file.type.startsWith('image/')) {
          const reader = new FileReader();
          reader.onload = e => {
            preview.src = e.target.result;
            container.style.display = 'block';
          };
          reader.readAsDataURL(file);
        } else {
          container.style.display = 'none';
        }
      }
    }
    
    async function uploadFile() {
      const input = document.getElementById('upload-file');
      const responseEl = document.getElementById('response-upload');
      
      if (!input.files || !input.files[0]) {
        alert('Please select a file first');
        return;
      }
      
      if (!authToken) {
        alert('Please login first to upload files');
        return;
      }
      
      responseEl.innerHTML = '<span class="loading"></span> Uploading...';
      responseEl.className = 'response-output';
      
      const formData = new FormData();
      formData.append('file', input.files[0]);
      
      try {
        const res = await fetch('/api/storage/upload', {
          method: 'POST',
          headers: { 'Authorization': 'Bearer ' + authToken },
          body: formData
        });
        const text = await res.text();
        let formatted = text;
        try {
          const json = JSON.parse(text);
          formatted = JSON.stringify(json, null, 2);
          if (json.url && json.content_type && json.content_type.startsWith('image/')) {
            formatted += '\\n\\n<img src="' + json.url + '" style="max-width:300px;margin-top:10px;border-radius:4px;">';
          }
        } catch {}
        
        responseEl.innerHTML = '<div class="response-status ' + (res.ok ? 'success' : 'error') + '">' + res.status + ' ' + res.statusText + '</div>' + formatted;
        responseEl.className = 'response-output ' + (res.ok ? 'success' : 'error');
      } catch (e) {
        responseEl.innerHTML = 'Error: ' + e.message;
        responseEl.className = 'response-output error';
      }
    }
  </script>
</body>
</html>
''';

