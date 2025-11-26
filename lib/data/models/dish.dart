import 'package:flutter_one/domain/entities/dish.dart';

class DishModel extends Dish {
  DishModel({
    required super.id,
    required super.name,
    required super.photoUrl,
    required super.price,
  });

  // fromJson
  factory DishModel.fromJson(Map<String, dynamic> json) {
    return DishModel(
      id: json['id'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      price: json['price'],
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'price': price,
    };
  }
}