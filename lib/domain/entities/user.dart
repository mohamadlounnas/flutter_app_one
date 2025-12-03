/// User entity - pure business object
class UserEntity {
  final int? id;
  final String name;
  final String phone;
  final String? imageUrl;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    this.id,
    required this.name,
    required this.phone,
    this.imageUrl,
    this.role = 'user',
    this.createdAt,
    this.updatedAt,
  });

  UserEntity copyWith({
    int? id,
    String? name,
    String? phone,
    String? imageUrl,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'UserEntity(id: $id, name: $name, phone: $phone)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          phone == other.phone;

  @override
  int get hashCode => id.hashCode ^ phone.hashCode;
}
