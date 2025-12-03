import 'package:flutter/foundation.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/posts_repository.dart';
import '../../core/api/network_exceptions.dart';

/// Posts state
enum PostsState { initial, loading, loaded, error }

/// Posts controller using ChangeNotifier
class PostsController extends ChangeNotifier {
  final PostsRepository _postsRepository;

  PostsController(this._postsRepository);

  PostsState _state = PostsState.initial;
  List<PostEntity> _posts = [];
  PostEntity? _selectedPost;
  String? _error;
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _pageSize = 20;

  PostsState get state => _state;
  List<PostEntity> get posts => _posts;
  PostEntity? get selectedPost => _selectedPost;
  String? get error => _error;
  bool get hasMore => _hasMore;
  bool get isLoading => _state == PostsState.loading;

  /// Fetch posts with pagination
  Future<void> fetchPosts({
    bool refresh = false,
    String? search,
    int? userId,
  }) async {
    if (_state == PostsState.loading) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    _state = PostsState.loading;
    _error = null;
    notifyListeners();

    try {
      final newPosts = await _postsRepository.getPosts(
        page: _currentPage,
        limit: _pageSize,
        search: search,
        userId: userId,
      );

      if (refresh || _currentPage == 1) {
        _posts = newPosts;
      } else {
        _posts = [..._posts, ...newPosts];
      }

      _hasMore = newPosts.length >= _pageSize;
      _currentPage++;
      _state = PostsState.loaded;
    } catch (e) {
      _error = NetworkExceptions.getMessage(e);
      _state = PostsState.error;
    }
    notifyListeners();
  }

  /// Load more posts for infinite scroll
  Future<void> loadMore({String? search, int? userId}) async {
    if (_state != PostsState.loading && _hasMore) {
      await fetchPosts(search: search, userId: userId);
    }
  }

  /// Get a single post by ID
  Future<void> getPost(int id) async {
    _state = PostsState.loading;
    _error = null;
    notifyListeners();

    try {
      _selectedPost = await _postsRepository.getPostById(id);
      _state = PostsState.loaded;
    } catch (e) {
      _error = NetworkExceptions.getMessage(e);
      _state = PostsState.error;
    }
    notifyListeners();
  }

  /// Create a new post
  Future<PostEntity?> createPost({
    required String title,
    required String description,
    required String body,
    String? imageUrl,
  }) async {
    _error = null;
    notifyListeners();

    try {
      final post = await _postsRepository.createPost(
        title: title,
        description: description,
        body: body,
        imageUrl: imageUrl,
      );
      _posts = [post, ..._posts];
      notifyListeners();
      return post;
    } catch (e) {
      _error = NetworkExceptions.getMessage(e);
      notifyListeners();
      return null;
    }
  }

  /// Update an existing post
  Future<PostEntity?> updatePost({
    required int id,
    String? title,
    String? description,
    String? body,
    String? imageUrl,
  }) async {
    _error = null;
    notifyListeners();

    try {
      final post = await _postsRepository.updatePost(
        id: id,
        title: title,
        description: description,
        body: body,
        imageUrl: imageUrl,
      );

      // Update in list
      final index = _posts.indexWhere((p) => p.id == id);
      if (index != -1) {
        _posts[index] = post;
      }

      // Update selected post if same
      if (_selectedPost?.id == id) {
        _selectedPost = post;
      }

      notifyListeners();
      return post;
    } catch (e) {
      _error = NetworkExceptions.getMessage(e);
      notifyListeners();
      return null;
    }
  }

  /// Delete a post (soft delete)
  Future<bool> deletePost(int id) async {
    _error = null;
    notifyListeners();

    try {
      await _postsRepository.deletePost(id);
      _posts = _posts.where((p) => p.id != id).toList();
      if (_selectedPost?.id == id) {
        _selectedPost = null;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = NetworkExceptions.getMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Clear selected post
  void clearSelectedPost() {
    _selectedPost = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
