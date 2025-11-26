// Data source for dishes

import 'package:flutter_one/data/models/dish.dart';
import 'package:flutter_one/domain/entities/dish.dart';
import 'package:dio/dio.dart';

class RemoteDishesDataSource {
  final Dio client;

  RemoteDishesDataSource({required this.client});

  Future<List<Dish>> all() async {
    final response = await client.get<List<dynamic>>('/api/dishes');
    return response.data!
      .map((dish) => DishModel.fromJson(dish))
      .toList();
  }

  Future<DishModel> create(DishModel dish) async {
    final response = await client.post('/api/dishes', data: dish.toJson());
    return DishModel.fromJson(response.data!);
  }
}
