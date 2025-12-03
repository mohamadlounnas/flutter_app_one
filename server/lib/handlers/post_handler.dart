import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../database/database.dart';

class PostHandler {
  final AppDatabase _db = AppDatabase.instance;

  /// GET /api/posts
  /// Get all posts with optional filters
  Future<Response> getAll(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final page = int.tryParse(queryParams['page'] ?? '') ?? 1;
      final limit = int.tryParse(queryParams['limit'] ?? '') ?? 20;
      final includeDeleted = queryParams['include_deleted'] == 'true';
      final userId = int.tryParse(queryParams['user_id'] ?? '');
      final search = queryParams['search'];

      final offset = (page - 1) * limit;

      // Build query
      var whereClause = includeDeleted ? '' : 'WHERE p.deleted_at IS NULL';
      final params = <Object>[];

      if (userId != null) {
        whereClause += whereClause.isEmpty ? 'WHERE ' : ' AND ';
        whereClause += 'p.user_id = ?';
        params.add(userId);
      }

      if (search != null && search.isNotEmpty) {
        whereClause += whereClause.isEmpty ? 'WHERE ' : ' AND ';
        whereClause += '(p.title LIKE ? OR p.description LIKE ? OR p.body LIKE ?)';
        params.addAll(['%$search%', '%$search%', '%$search%']);
      }

      params.addAll([limit, offset]);

      final result = _db.db.select('''
        SELECT p.*, u.id as author_id, u.name as author_name, 
               u.phone as author_phone, u.image_url as author_image_url,
               u.role as author_role
        FROM posts p
        LEFT JOIN users u ON p.user_id = u.id
        $whereClause
        ORDER BY p.created_at DESC
        LIMIT ? OFFSET ?
      ''', params);

      final posts = result.map((row) {
        final post = <String, dynamic>{
          'id': row['id'],
          'user_id': row['user_id'],
          'title': row['title'],
          'description': row['description'] ?? '',
          'body': row['body'],
          'image_url': row['image_url'],
          'created_at': row['created_at'],
          'updated_at': row['updated_at'],
          'deleted_at': row['deleted_at'],
        };

        if (row['author_id'] != null) {
          post['author'] = {
            'id': row['author_id'],
            'name': row['author_name'],
            'phone': row['author_phone'],
            'image_url': row['author_image_url'],
            'role': row['author_role'],
          };
        }

        return post;
      }).toList();

      return Response.ok(
        jsonEncode(posts),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// GET /api/posts/:id
  /// Get a single post by ID
  Future<Response> getById(Request request, String id) async {
    try {
      final postId = int.tryParse(id);
      if (postId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid post ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = _db.db.select('''
        SELECT p.*, u.id as author_id, u.name as author_name, 
               u.phone as author_phone, u.image_url as author_image_url,
               u.role as author_role
        FROM posts p
        LEFT JOIN users u ON p.user_id = u.id
        WHERE p.id = ?
      ''', [postId]);

      if (result.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Post not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final row = result.first;
      final post = <String, dynamic>{
        'id': row['id'],
        'user_id': row['user_id'],
        'title': row['title'],
        'description': row['description'] ?? '',
        'body': row['body'],
        'image_url': row['image_url'],
        'created_at': row['created_at'],
        'updated_at': row['updated_at'],
        'deleted_at': row['deleted_at'],
      };

      if (row['author_id'] != null) {
        post['author'] = {
          'id': row['author_id'],
          'name': row['author_name'],
          'phone': row['author_phone'],
          'image_url': row['author_image_url'],
          'role': row['author_role'],
        };
      }

      return Response.ok(
        jsonEncode(post),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST /api/posts
  /// Create a new post (requires authentication)
  Future<Response> create(Request request) async {
    try {
      final userId = request.context['userId'] as int?;
      if (userId == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Not authenticated'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      // Validate required fields
      if (json['title'] == null || (json['title'] as String).isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Title is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (json['body'] == null || (json['body'] as String).isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Body is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final title = json['title'] as String;
      final description = json['description'] as String? ?? '';
      final postBody = json['body'] as String;
      final imageUrl = json['image_url'] as String?;

      _db.db.execute(
        '''INSERT INTO posts (user_id, title, description, body, image_url) 
           VALUES (?, ?, ?, ?, ?)''',
        [userId, title, description, postBody, imageUrl],
      );

      final postId = _db.db.lastInsertRowId;

      // Fetch created post with author
      return getById(request, postId.toString());
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// PUT /api/posts/:id
  /// Update a post (requires authentication & ownership)
  Future<Response> update(Request request, String id) async {
    try {
      final userId = request.context['userId'] as int?;
      final role = request.context['role'] as String?;

      if (userId == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Not authenticated'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final postId = int.tryParse(id);
      if (postId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid post ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check ownership or admin
      final existing = _db.db.select(
        'SELECT user_id FROM posts WHERE id = ?',
        [postId],
      );

      if (existing.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Post not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final ownerId = existing.first['user_id'] as int;
      if (ownerId != userId && role != 'admin') {
        return Response.forbidden(
          jsonEncode({'error': 'You can only edit your own posts'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      final updates = <String>[];
      final params = <Object?>[];

      if (json.containsKey('title')) {
        updates.add('title = ?');
        params.add(json['title'] as String);
      }
      if (json.containsKey('description')) {
        updates.add('description = ?');
        params.add(json['description'] as String? ?? '');
      }
      if (json.containsKey('body')) {
        updates.add('body = ?');
        params.add(json['body'] as String);
      }
      if (json.containsKey('image_url')) {
        updates.add('image_url = ?');
        params.add(json['image_url'] as String?);
      }

      if (updates.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Nothing to update'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      updates.add("updated_at = datetime('now')");
      params.add(postId);

      _db.db.execute(
        'UPDATE posts SET ${updates.join(', ')} WHERE id = ?',
        params,
      );

      return getById(request, id);
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// DELETE /api/posts/:id
  /// Soft delete a post (requires authentication & ownership)
  Future<Response> delete(Request request, String id) async {
    try {
      final userId = request.context['userId'] as int?;
      final role = request.context['role'] as String?;
      final queryParams = request.url.queryParameters;
      final hardDelete = queryParams['hard'] == 'true';

      if (userId == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Not authenticated'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final postId = int.tryParse(id);
      if (postId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid post ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check ownership or admin
      final existing = _db.db.select(
        'SELECT user_id FROM posts WHERE id = ?',
        [postId],
      );

      if (existing.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Post not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final ownerId = existing.first['user_id'] as int;
      if (ownerId != userId && role != 'admin') {
        return Response.forbidden(
          jsonEncode({'error': 'You can only delete your own posts'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (hardDelete && role == 'admin') {
        // Hard delete (admin only)
        _db.db.execute('DELETE FROM comments WHERE post_id = ?', [postId]);
        _db.db.execute('DELETE FROM posts WHERE id = ?', [postId]);
      } else {
        // Soft delete
        _db.db.execute(
          "UPDATE posts SET deleted_at = datetime('now') WHERE id = ?",
          [postId],
        );
      }

      return Response.ok(
        jsonEncode({'message': 'Post deleted successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// PATCH /api/posts/:id/restore
  /// Restore a soft-deleted post (requires authentication & ownership)
  Future<Response> restore(Request request, String id) async {
    try {
      final userId = request.context['userId'] as int?;
      final role = request.context['role'] as String?;

      if (userId == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Not authenticated'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final postId = int.tryParse(id);
      if (postId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid post ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check ownership or admin
      final existing = _db.db.select(
        'SELECT user_id, deleted_at FROM posts WHERE id = ?',
        [postId],
      );

      if (existing.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Post not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final row = existing.first;
      if (row['deleted_at'] == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Post is not deleted'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final ownerId = row['user_id'] as int;
      if (ownerId != userId && role != 'admin') {
        return Response.forbidden(
          jsonEncode({'error': 'You can only restore your own posts'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      _db.db.execute(
        'UPDATE posts SET deleted_at = NULL WHERE id = ?',
        [postId],
      );

      return getById(request, id);
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// GET /api/posts/user/:userId
  /// Get all posts by a specific user
  Future<Response> getByUser(Request request, String userId) async {
    try {
      final uid = int.tryParse(userId);
      if (uid == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid user ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = _db.db.select('''
        SELECT p.*, u.id as author_id, u.name as author_name, 
               u.phone as author_phone, u.image_url as author_image_url,
               u.role as author_role
        FROM posts p
        LEFT JOIN users u ON p.user_id = u.id
        WHERE p.user_id = ? AND p.deleted_at IS NULL
        ORDER BY p.created_at DESC
      ''', [uid]);

      final posts = result.map((row) {
        final post = <String, dynamic>{
          'id': row['id'],
          'user_id': row['user_id'],
          'title': row['title'],
          'description': row['description'] ?? '',
          'body': row['body'],
          'image_url': row['image_url'],
          'created_at': row['created_at'],
          'updated_at': row['updated_at'],
          'deleted_at': row['deleted_at'],
        };

        if (row['author_id'] != null) {
          post['author'] = {
            'id': row['author_id'],
            'name': row['author_name'],
            'phone': row['author_phone'],
            'image_url': row['author_image_url'],
            'role': row['author_role'],
          };
        }

        return post;
      }).toList();

      return Response.ok(
        jsonEncode(posts),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST /api/posts/:id/upvote
  /// Upvote a post (requires authentication)
  Future<Response> upvote(Request request, String id) async {
    try {
      final userId = request.context['userId'] as int?;
      if (userId == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Not authenticated'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final postId = int.tryParse(id);
      if (postId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid post ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check if post exists
      final existing = _db.db.select(
        'SELECT id FROM posts WHERE id = ? AND deleted_at IS NULL',
        [postId],
      );

      if (existing.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Post not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Note: In a real app, you'd track who voted and prevent duplicate votes
      // For simplicity, we just increment the counter
      _db.db.execute(
        'UPDATE posts SET upvotes = COALESCE(upvotes, 0) + 1 WHERE id = ?',
        [postId],
      );

      return Response.ok(
        jsonEncode({'message': 'Upvoted successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST /api/posts/:id/downvote
  /// Downvote a post (requires authentication)
  Future<Response> downvote(Request request, String id) async {
    try {
      final userId = request.context['userId'] as int?;
      if (userId == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Not authenticated'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final postId = int.tryParse(id);
      if (postId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid post ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check if post exists
      final existing = _db.db.select(
        'SELECT id FROM posts WHERE id = ? AND deleted_at IS NULL',
        [postId],
      );

      if (existing.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Post not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Note: In a real app, you'd track who voted and prevent duplicate votes
      _db.db.execute(
        'UPDATE posts SET downvotes = COALESCE(downvotes, 0) + 1 WHERE id = ?',
        [postId],
      );

      return Response.ok(
        jsonEncode({'message': 'Downvoted successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
