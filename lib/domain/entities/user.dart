abstract class User {
  final int id;
  final String name;
  final String phone;
  final String? password;
  final String role;

  User({
    required this.id,
    required this.name, 
    required this.phone,
    this.password,
    required this.role,
  });
}