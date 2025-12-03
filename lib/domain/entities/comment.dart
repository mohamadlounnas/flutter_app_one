import 'user.dart';

/// Comment entity - pure business object
class CommentEntity {
  final int? id;
  final int postId;
  final int userId;
  final String comment;
  final List<int> mentions;
  final DateTime? createdAt;
  final UserEntity? author;

  const CommentEntity({
    this.id,
    required this.postId,
    required this.userId,
    required this.comment,
    this.mentions = const [],
    this.createdAt,
    this.author,
  });

  CommentEntity copyWith({
    int? id,
    int? postId,
    int? userId,
    String? comment,
    List<int>? mentions,
    DateTime? createdAt,
    UserEntity? author,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      comment: comment ?? this.comment,
      mentions: mentions ?? this.mentions,
      createdAt: createdAt ?? this.createdAt,
      author: author ?? this.author,
    );
  }

  @override
  String toString() => 'CommentEntity(id: $id, postId: $postId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
