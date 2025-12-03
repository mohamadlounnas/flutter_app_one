import '../entities/post.dart';

/// Posts repository interface
abstract class PostsRepository {
  /// Get all posts with optional filters
  Future<List<PostEntity>> getPosts({
    int? page,
    int? limit,
    bool includeDeleted = false,
    int? userId,
    String? search,
  });

  /// Get a single post by ID
  Future<PostEntity> getPostById(int id);

  /// Create a new post
  Future<PostEntity> createPost({
    required String title,
    required String description,
    required String body,
    String? imageUrl,
  });

  /// Update an existing post
  Future<PostEntity> updatePost({
    required int id,
    String? title,
    String? description,
    String? body,
    String? imageUrl,
  });

  /// Soft delete a post
  Future<void> deletePost(int id);

  /// Restore a soft-deleted post
  Future<PostEntity> restorePost(int id);

  /// Permanently delete a post (admin only)
  Future<void> hardDeletePost(int id);
}
