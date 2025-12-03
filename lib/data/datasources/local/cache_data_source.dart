import 'dart:convert';
import '../../../core/storage/storage_service.dart';
import '../../models/user_model.dart';
import '../../models/post_model.dart';

/// Local cache data source
class CacheDataSource {
  final StorageService _storageService;

  static const String _userCacheKey = 'cached_user';
  static const String _postsCacheKey = 'cached_posts';
  static const String _postCachePrefix = 'cached_post_';

  CacheDataSource(this._storageService);

  // User caching

  Future<void> cacheUser(UserModel user) async {
    await _storageService.setString(_userCacheKey, jsonEncode(user.toJson()));
  }

  UserModel? getCachedUser() {
    final userJson = _storageService.getString(_userCacheKey);
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  Future<void> clearUserCache() async {
    await _storageService.remove(_userCacheKey);
  }

  // Posts caching

  Future<void> cachePosts(List<PostModel> posts) async {
    final postsJson = posts.map((p) => p.toJson()).toList();
    await _storageService.setString(_postsCacheKey, jsonEncode(postsJson));
  }

  List<PostModel>? getCachedPosts() {
    final postsJson = _storageService.getString(_postsCacheKey);
    if (postsJson == null) return null;
    final List<dynamic> decoded = jsonDecode(postsJson);
    return decoded
        .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> clearPostsCache() async {
    await _storageService.remove(_postsCacheKey);
  }

  // Single post caching

  Future<void> cachePost(PostModel post) async {
    if (post.id == null) return;
    await _storageService.setString(
      '$_postCachePrefix${post.id}',
      jsonEncode(post.toJson()),
    );
  }

  PostModel? getCachedPost(int id) {
    final postJson = _storageService.getString('$_postCachePrefix$id');
    if (postJson == null) return null;
    return PostModel.fromJson(jsonDecode(postJson) as Map<String, dynamic>);
  }

  Future<void> clearPostCache(int id) async {
    await _storageService.remove('$_postCachePrefix$id');
  }

  // Clear all caches

  Future<void> clearAll() async {
    await clearUserCache();
    await clearPostsCache();
    // Note: individual post caches would need iteration to clear
  }
}
