import 'user.dart';

/// Post entity - pure business object
class PostEntity {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final String body;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final UserEntity? author;

  const PostEntity({
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
  });

  bool get isDeleted => deletedAt != null;

  PostEntity copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? body,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    UserEntity? author,
  }) {
    return PostEntity(
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
    );
  }

  @override
  String toString() => 'PostEntity(id: $id, title: $title)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
