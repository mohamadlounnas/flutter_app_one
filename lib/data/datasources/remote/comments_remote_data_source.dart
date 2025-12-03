import '../../../core/api/api_client.dart';
import '../../../core/constants.dart';
import '../../models/comment_model.dart';

/// Remote data source for comments
abstract class CommentsRemoteDataSource {
  Future<List<CommentModel>> getCommentsByPost(int postId);

  Future<CommentModel> getCommentById(int id);

  Future<CommentModel> createComment({
    required int postId,
    required String comment,
    List<int> mentions,
  });

  Future<CommentModel> updateComment({
    required int id,
    required String comment,
    List<int>? mentions,
  });

  Future<void> deleteComment(int id);
}

/// Implementation of comments remote data source
class CommentsRemoteDataSourceImpl implements CommentsRemoteDataSource {
  final ApiClient _apiClient;

  CommentsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<CommentModel>> getCommentsByPost(int postId) async {
    final response = await _apiClient.get(ApiConstants.postComments(postId));

    final List<dynamic> commentsJson = response is List ? response : response['comments'] ?? [];
    return commentsJson
        .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CommentModel> getCommentById(int id) async {
    final response = await _apiClient.get(ApiConstants.commentById(id));
    return CommentModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<CommentModel> createComment({
    required int postId,
    required String comment,
    List<int> mentions = const [],
  }) async {
    final response = await _apiClient.post(
      ApiConstants.postComments(postId),
      body: {
        'comment': comment,
        if (mentions.isNotEmpty) 'mentions': mentions,
      },
      requireAuth: true,
    );

    return CommentModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<CommentModel> updateComment({
    required int id,
    required String comment,
    List<int>? mentions,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.commentById(id),
      body: {
        'comment': comment,
        if (mentions != null) 'mentions': mentions,
      },
      requireAuth: true,
    );

    return CommentModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deleteComment(int id) async {
    await _apiClient.delete(
      ApiConstants.commentById(id),
      requireAuth: true,
    );
  }
}
