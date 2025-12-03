import '../../domain/entities/comment.dart';
import 'user_model.dart';

/// Comment data model for JSON serialization
class CommentModel {
  final int? id;
  final int postId;
  final int userId;
  final String comment;
  final List<int> mentions;
  final DateTime? createdAt;
  final UserModel? author;

  const CommentModel({
    this.id,
    required this.postId,
    required this.userId,
    required this.comment,
    this.mentions = const [],
    this.createdAt,
    this.author,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as int?,
      postId: json['post_id'] as int,
      userId: json['user_id'] as int,
      comment: json['comment'] as String,
      mentions: _parseMentions(json['mentions']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      author: json['author'] != null
          ? UserModel.fromJson(json['author'] as Map<String, dynamic>)
          : null,
    );
  }

  static List<int> _parseMentions(dynamic mentions) {
    if (mentions == null) return [];
    if (mentions is String) {
      if (mentions.isEmpty) return [];
      return mentions.split(',').map((e) => int.parse(e.trim())).toList();
    }
    if (mentions is List) {
      return mentions.map((e) => e is int ? e : int.parse(e.toString())).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'post_id': postId,
      'user_id': userId,
      'comment': comment,
      'mentions': mentions,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  /// Convert to domain entity
  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      postId: postId,
      userId: userId,
      comment: comment,
      mentions: mentions,
      createdAt: createdAt,
      author: author?.toEntity(),
    );
  }

  /// Create from domain entity
  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      postId: entity.postId,
      userId: entity.userId,
      comment: entity.comment,
      mentions: entity.mentions,
      createdAt: entity.createdAt,
    );
  }

  CommentModel copyWith({
    int? id,
    int? postId,
    int? userId,
    String? comment,
    List<int>? mentions,
    DateTime? createdAt,
    UserModel? author,
  }) {
    return CommentModel(
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
  String toString() => 'CommentModel(id: $id, postId: $postId)';
}
