import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../database/database.dart';

class CommentHandler {
  final AppDatabase _db = AppDatabase.instance;

  /// GET /api/posts/:postId/comments
  /// Get all comments for a post
  Future<Response> getByPost(Request request, String postId) async {
    try {
      final id = int.tryParse(postId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid post ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check if post exists
      final post = _db.db.select('SELECT id FROM posts WHERE id = ?', [id]);
      if (post.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Post not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = _db.db.select('''
        SELECT c.*, u.id as author_id, u.name as author_name,
               u.phone as author_phone, u.image_url as author_image_url,
               u.role as author_role
        FROM comments c
        LEFT JOIN users u ON c.user_id = u.id
        WHERE c.post_id = ?
        ORDER BY c.created_at ASC
      ''', [id]);

      final comments = result.map((row) {
        final comment = <String, dynamic>{
          'id': row['id'],
          'post_id': row['post_id'],
          'user_id': row['user_id'],
          'comment': row['comment'],
          'mentions': row['mentions'],
          'created_at': row['created_at'],
        };

        if (row['author_id'] != null) {
          comment['author'] = {
            'id': row['author_id'],
            'name': row['author_name'],
            'phone': row['author_phone'],
            'image_url': row['author_image_url'],
            'role': row['author_role'],
          };
        }

        return comment;
      }).toList();

      return Response.ok(
        jsonEncode(comments),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// GET /api/comments/:id
  /// Get a single comment by ID
  Future<Response> getById(Request request, String id) async {
    try {
      final commentId = int.tryParse(id);
      if (commentId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid comment ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = _db.db.select('''
        SELECT c.*, u.id as author_id, u.name as author_name,
               u.phone as author_phone, u.image_url as author_image_url,
               u.role as author_role
        FROM comments c
        LEFT JOIN users u ON c.user_id = u.id
        WHERE c.id = ?
      ''', [commentId]);

      if (result.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Comment not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final row = result.first;
      final comment = <String, dynamic>{
        'id': row['id'],
        'post_id': row['post_id'],
        'user_id': row['user_id'],
        'comment': row['comment'],
        'mentions': row['mentions'],
        'created_at': row['created_at'],
      };

      if (row['author_id'] != null) {
        comment['author'] = {
          'id': row['author_id'],
          'name': row['author_name'],
          'phone': row['author_phone'],
          'image_url': row['author_image_url'],
          'role': row['author_role'],
        };
      }

      return Response.ok(
        jsonEncode(comment),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST /api/posts/:postId/comments
  /// Create a new comment (requires authentication)
  Future<Response> create(Request request, String postId) async {
    try {
      final userId = request.context['userId'] as int?;
      if (userId == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Not authenticated'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final id = int.tryParse(postId);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid post ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check if post exists and is not deleted
      final post = _db.db.select(
        'SELECT id FROM posts WHERE id = ? AND deleted_at IS NULL',
        [id],
      );
      if (post.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Post not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      if (json['comment'] == null || (json['comment'] as String).isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Comment is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final comment = json['comment'] as String;
      final mentions = json['mentions'];
      String? mentionsStr;

      if (mentions != null) {
        if (mentions is List) {
          mentionsStr = mentions.map((e) => e.toString()).join(',');
        } else if (mentions is String) {
          mentionsStr = mentions;
        }
      }

      _db.db.execute(
        'INSERT INTO comments (post_id, user_id, comment, mentions) VALUES (?, ?, ?, ?)',
        [id, userId, comment, mentionsStr],
      );

      final commentId = _db.db.lastInsertRowId;
      return getById(request, commentId.toString());
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// PUT /api/comments/:id
  /// Update a comment (requires authentication & ownership)
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

      final commentId = int.tryParse(id);
      if (commentId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid comment ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check ownership or admin
      final existing = _db.db.select(
        'SELECT user_id FROM comments WHERE id = ?',
        [commentId],
      );

      if (existing.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Comment not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final ownerId = existing.first['user_id'] as int;
      if (ownerId != userId && role != 'admin') {
        return Response.forbidden(
          jsonEncode({'error': 'You can only edit your own comments'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      final updates = <String>[];
      final params = <Object?>[];

      if (json.containsKey('comment')) {
        updates.add('comment = ?');
        params.add(json['comment'] as String);
      }

      if (json.containsKey('mentions')) {
        updates.add('mentions = ?');
        final mentions = json['mentions'];
        if (mentions is List) {
          params.add(mentions.map((e) => e.toString()).join(','));
        } else {
          params.add(mentions as String?);
        }
      }

      if (updates.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Nothing to update'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      params.add(commentId);

      _db.db.execute(
        'UPDATE comments SET ${updates.join(', ')} WHERE id = ?',
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

  /// DELETE /api/comments/:id
  /// Delete a comment (requires authentication & ownership)
  Future<Response> delete(Request request, String id) async {
    try {
      final userId = request.context['userId'] as int?;
      final role = request.context['role'] as String?;

      if (userId == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Not authenticated'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final commentId = int.tryParse(id);
      if (commentId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid comment ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check ownership or admin
      final existing = _db.db.select(
        'SELECT user_id FROM comments WHERE id = ?',
        [commentId],
      );

      if (existing.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Comment not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final ownerId = existing.first['user_id'] as int;
      if (ownerId != userId && role != 'admin') {
        return Response.forbidden(
          jsonEncode({'error': 'You can only delete your own comments'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      _db.db.execute('DELETE FROM comments WHERE id = ?', [commentId]);

      return Response.ok(
        jsonEncode({'message': 'Comment deleted successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST /api/comments/:id/upvote
  /// Upvote a comment (requires authentication)
  Future<Response> upvote(Request request, String id) async {
    try {
      final userId = request.context['userId'] as int?;
      if (userId == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Not authenticated'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final commentId = int.tryParse(id);
      if (commentId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid comment ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check if comment exists
      final existing = _db.db.select(
        'SELECT id FROM comments WHERE id = ?',
        [commentId],
      );

      if (existing.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Comment not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Note: In a real app, you'd track who voted and prevent duplicate votes
      _db.db.execute(
        'UPDATE comments SET upvotes = COALESCE(upvotes, 0) + 1 WHERE id = ?',
        [commentId],
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

  /// POST /api/comments/:id/downvote
  /// Downvote a comment (requires authentication)
  Future<Response> downvote(Request request, String id) async {
    try {
      final userId = request.context['userId'] as int?;
      if (userId == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Not authenticated'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final commentId = int.tryParse(id);
      if (commentId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid comment ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check if comment exists
      final existing = _db.db.select(
        'SELECT id FROM comments WHERE id = ?',
        [commentId],
      );

      if (existing.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Comment not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Note: In a real app, you'd track who voted and prevent duplicate votes
      _db.db.execute(
        'UPDATE comments SET downvotes = COALESCE(downvotes, 0) + 1 WHERE id = ?',
        [commentId],
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
