import 'package:flutter_one/domain/entities/order.dart';

class OrderModel extends Order {
  OrderModel({
    required super.id,
    required super.userId,
    required super.phone,
    required super.dishId,
    required super.latitude,
    required super.longitude,
    required super.address,
    required super.completed,
  });

  // fromJson
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['userId'],
      phone: json['phone'],
      dishId: json['dishId'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      completed: json['completed'],
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'phone': phone,
      'dishId': dishId,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'completed': completed,
    };
  }
}