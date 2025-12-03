import '../../domain/entities/user.dart';

/// User data model for JSON serialization
class UserModel {
  final int? id;
  final String name;
  final String phone;
  final String? password;
  final String? imageUrl;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    this.id,
    required this.name,
    required this.phone,
    this.password,
    this.imageUrl,
    this.role = 'user',
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      phone: json['phone'] as String,
      password: json['password'] as String?,
      imageUrl: json['image_url'] as String?,
      role: json['role'] as String? ?? 'user',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      if (password != null) 'password': password,
      if (imageUrl != null) 'image_url': imageUrl,
      'role': role,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Convert to domain entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      phone: phone,
      imageUrl: imageUrl,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      imageUrl: entity.imageUrl,
      role: entity.role,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? password,
    String? imageUrl,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, name: $name, phone: $phone)';
}
