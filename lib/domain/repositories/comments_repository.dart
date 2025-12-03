import '../entities/comment.dart';

/// Comments repository interface
abstract class CommentsRepository {
  /// Get comments for a post
  Future<List<CommentEntity>> getCommentsByPost(int postId);

  /// Get a single comment by ID
  Future<CommentEntity> getCommentById(int id);

  /// Create a new comment
  Future<CommentEntity> createComment({
    required int postId,
    required String comment,
    List<int> mentions = const [],
  });

  /// Update an existing comment
  Future<CommentEntity> updateComment({
    required int id,
    required String comment,
    List<int>? mentions,
  });

  /// Delete a comment
  Future<void> deleteComment(int id);
}
