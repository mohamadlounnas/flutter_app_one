import 'package:flutter/foundation.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comments_repository.dart';
import '../../core/api/network_exceptions.dart';

/// Comments state
enum CommentsState { initial, loading, loaded, error }

/// Comments controller using ChangeNotifier
class CommentsController extends ChangeNotifier {
  final CommentsRepository _commentsRepository;

  CommentsController(this._commentsRepository);

  CommentsState _state = CommentsState.initial;
  List<CommentEntity> _comments = [];
  String? _error;
  int? _currentPostId;

  CommentsState get state => _state;
  List<CommentEntity> get comments => _comments;
  String? get error => _error;
  int? get currentPostId => _currentPostId;
  bool get isLoading => _state == CommentsState.loading;

  /// Fetch comments for a post
  Future<void> fetchComments(int postId) async {
    _currentPostId = postId;
    _state = CommentsState.loading;
    _error = null;
    notifyListeners();

    try {
      _comments = await _commentsRepository.getCommentsByPost(postId);
      _state = CommentsState.loaded;
    } catch (e) {
      _error = NetworkExceptions.getMessage(e);
      _state = CommentsState.error;
    }
    notifyListeners();
  }

  /// Create a new comment
  Future<CommentEntity?> createComment({
    required int postId,
    required String comment,
    List<int> mentions = const [],
  }) async {
    _error = null;
    notifyListeners();

    try {
      final newComment = await _commentsRepository.createComment(
        postId: postId,
        comment: comment,
        mentions: mentions,
      );
      _comments = [..._comments, newComment];
      notifyListeners();
      return newComment;
    } catch (e) {
      _error = NetworkExceptions.getMessage(e);
      notifyListeners();
      return null;
    }
  }

  /// Update a comment
  Future<CommentEntity?> updateComment({
    required int id,
    required String comment,
    List<int>? mentions,
  }) async {
    _error = null;
    notifyListeners();

    try {
      final updatedComment = await _commentsRepository.updateComment(
        id: id,
        comment: comment,
        mentions: mentions,
      );

      // Update in list
      final index = _comments.indexWhere((c) => c.id == id);
      if (index != -1) {
        _comments[index] = updatedComment;
      }

      notifyListeners();
      return updatedComment;
    } catch (e) {
      _error = NetworkExceptions.getMessage(e);
      notifyListeners();
      return null;
    }
  }

  /// Delete a comment
  Future<bool> deleteComment(int id) async {
    _error = null;
    notifyListeners();

    try {
      await _commentsRepository.deleteComment(id);
      _comments = _comments.where((c) => c.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = NetworkExceptions.getMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Clear comments
  void clearComments() {
    _comments = [];
    _currentPostId = null;
    _state = CommentsState.initial;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
