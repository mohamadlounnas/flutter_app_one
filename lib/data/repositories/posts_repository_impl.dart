import '../../domain/entities/post.dart';
import '../../domain/repositories/posts_repository.dart';
import '../datasources/remote/posts_remote_data_source.dart';
import '../datasources/local/cache_data_source.dart';

/// Implementation of PostsRepository
class PostsRepositoryImpl implements PostsRepository {
  final PostsRemoteDataSource _remoteDataSource;
  final CacheDataSource _cacheDataSource;

  PostsRepositoryImpl({
    required PostsRemoteDataSource remoteDataSource,
    required CacheDataSource cacheDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _cacheDataSource = cacheDataSource;

  @override
  Future<List<PostEntity>> getPosts({
    int? page,
    int? limit,
    bool includeDeleted = false,
    int? userId,
    String? search,
  }) async {
    final posts = await _remoteDataSource.getPosts(
      page: page,
      limit: limit,
      includeDeleted: includeDeleted,
      userId: userId,
      search: search,
    );

    // Cache posts if it's the first page with no filters
    if (page == null && userId == null && search == null && !includeDeleted) {
      await _cacheDataSource.cachePosts(posts);
    }

    return posts.map((model) => model.toEntity()).toList();
  }

  @override
  Future<PostEntity> getPostById(int id) async {
    final post = await _remoteDataSource.getPostById(id);
    await _cacheDataSource.cachePost(post);
    return post.toEntity();
  }

  @override
  Future<PostEntity> createPost({
    required String title,
    required String description,
    required String body,
    String? imageUrl,
  }) async {
    final post = await _remoteDataSource.createPost(
      title: title,
      description: description,
      body: body,
      imageUrl: imageUrl,
    );

    await _cacheDataSource.cachePost(post);
    return post.toEntity();
  }

  @override
  Future<PostEntity> updatePost({
    required int id,
    String? title,
    String? description,
    String? body,
    String? imageUrl,
  }) async {
    final post = await _remoteDataSource.updatePost(
      id: id,
      title: title,
      description: description,
      body: body,
      imageUrl: imageUrl,
    );

    await _cacheDataSource.cachePost(post);
    return post.toEntity();
  }

  @override
  Future<void> deletePost(int id) async {
    await _remoteDataSource.deletePost(id);
    await _cacheDataSource.clearPostCache(id);
  }

  @override
  Future<PostEntity> restorePost(int id) async {
    final post = await _remoteDataSource.restorePost(id);
    await _cacheDataSource.cachePost(post);
    return post.toEntity();
  }

  @override
  Future<void> hardDeletePost(int id) async {
    await _remoteDataSource.hardDeletePost(id);
    await _cacheDataSource.clearPostCache(id);
  }
}
