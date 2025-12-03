import '../../domain/entities/comment.dart';
import '../../domain/repositories/comments_repository.dart';
import '../datasources/remote/comments_remote_data_source.dart';

/// Implementation of CommentsRepository
class CommentsRepositoryImpl implements CommentsRepository {
  final CommentsRemoteDataSource _remoteDataSource;

  CommentsRepositoryImpl({
    required CommentsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<CommentEntity>> getCommentsByPost(int postId) async {
    final comments = await _remoteDataSource.getCommentsByPost(postId);
    return comments.map((model) => model.toEntity()).toList();
  }

  @override
  Future<CommentEntity> getCommentById(int id) async {
    final comment = await _remoteDataSource.getCommentById(id);
    return comment.toEntity();
  }

  @override
  Future<CommentEntity> createComment({
    required int postId,
    required String comment,
    List<int> mentions = const [],
  }) async {
    final createdComment = await _remoteDataSource.createComment(
      postId: postId,
      comment: comment,
      mentions: mentions,
    );
    return createdComment.toEntity();
  }

  @override
  Future<CommentEntity> updateComment({
    required int id,
    required String comment,
    List<int>? mentions,
  }) async {
    final updatedComment = await _remoteDataSource.updateComment(
      id: id,
      comment: comment,
      mentions: mentions,
    );
    return updatedComment.toEntity();
  }

  @override
  Future<void> deleteComment(int id) async {
    await _remoteDataSource.deleteComment(id);
  }
}
