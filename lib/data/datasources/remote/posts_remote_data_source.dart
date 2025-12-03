import '../../../core/api/api_client.dart';
import '../../../core/constants.dart';
import '../../models/post_model.dart';

/// Remote data source for posts
abstract class PostsRemoteDataSource {
  Future<List<PostModel>> getPosts({
    int? page,
    int? limit,
    bool includeDeleted,
    int? userId,
    String? search,
  });

  Future<PostModel> getPostById(int id);

  Future<PostModel> createPost({
    required String title,
    required String description,
    required String body,
    String? imageUrl,
  });

  Future<PostModel> updatePost({
    required int id,
    String? title,
    String? description,
    String? body,
    String? imageUrl,
  });

  Future<void> deletePost(int id);

  Future<PostModel> restorePost(int id);

  Future<void> hardDeletePost(int id);
}

/// Implementation of posts remote data source
class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final ApiClient _apiClient;

  PostsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<PostModel>> getPosts({
    int? page,
    int? limit,
    bool includeDeleted = false,
    int? userId,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (includeDeleted) queryParams['include_deleted'] = 'true';
    if (userId != null) queryParams['user_id'] = userId.toString();
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _apiClient.get(
      ApiConstants.posts,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    final List<dynamic> postsJson = response is List ? response : response['posts'] ?? [];
    return postsJson
        .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PostModel> getPostById(int id) async {
    final response = await _apiClient.get(ApiConstants.postById(id));
    return PostModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<PostModel> createPost({
    required String title,
    required String description,
    required String body,
    String? imageUrl,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.posts,
      body: {
        'title': title,
        'description': description,
        'body': body,
        if (imageUrl != null) 'image_url': imageUrl,
      },
      requireAuth: true,
    );

    return PostModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<PostModel> updatePost({
    required int id,
    String? title,
    String? description,
    String? body,
    String? imageUrl,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.postById(id),
      body: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (body != null) 'body': body,
        if (imageUrl != null) 'image_url': imageUrl,
      },
      requireAuth: true,
    );

    return PostModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deletePost(int id) async {
    await _apiClient.delete(
      ApiConstants.postById(id),
      requireAuth: true,
    );
  }

  @override
  Future<PostModel> restorePost(int id) async {
    final response = await _apiClient.patch(
      ApiConstants.postRestore(id),
      requireAuth: true,
    );

    return PostModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> hardDeletePost(int id) async {
    await _apiClient.delete(
      '${ApiConstants.postById(id)}?hard=true',
      requireAuth: true,
    );
  }
}
