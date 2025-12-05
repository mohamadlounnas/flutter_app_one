import '../../domain/entities/post.dart';
import 'user_model.dart';

/// Post data model for JSON serialization
class PostModel {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final String body;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final UserModel? author;
  final int upvotes;
  final int downvotes;

  const PostModel({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.body,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.author,
    this.upvotes = 0,
    this.downvotes = 0,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      body: json['body'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      author: json['author'] != null
          ? UserModel.fromJson(json['author'] as Map<String, dynamic>)
          : null,
        upvotes: json['upvotes'] is int
          ? json['upvotes'] as int
          : int.tryParse('${json['upvotes']}') ?? 0,
        downvotes: json['downvotes'] is int
          ? json['downvotes'] as int
          : int.tryParse('${json['downvotes']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'body': body,
      if (imageUrl != null) 'image_url': imageUrl,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
      'upvotes': upvotes,
      'downvotes': downvotes,
    };
  }

  /// Convert to domain entity
  PostEntity toEntity() {
    return PostEntity(
      id: id,
      userId: userId,
      title: title,
      description: description,
      body: body,
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      author: author?.toEntity(),
      upvotes: upvotes,
      downvotes: downvotes,
    );
  }

  /// Create from domain entity
  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      description: entity.description,
      body: entity.body,
      imageUrl: entity.imageUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
      upvotes: entity.upvotes,
      downvotes: entity.downvotes,
    );
  }

  bool get isDeleted => deletedAt != null;

  PostModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? body,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    UserModel? author,
    int? upvotes,
    int? downvotes,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      author: author ?? this.author,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
    );
  }

  @override
  String toString() => 'PostModel(id: $id, title: $title)';
}
