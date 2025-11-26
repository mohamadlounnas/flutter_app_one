abstract class Order {
  final int id;
  final int? userId;
  final String phone;
  final String dishId;
  final double latitude;
  final double longitude;
  final String address;
  final bool completed;

  Order({
    required this.id,
    this.userId,
    required this.phone,
    required this.dishId,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.completed,
  });
}