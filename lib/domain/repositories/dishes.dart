// Repository pattern for dishes

import 'package:flutter_one/data/models/dish.dart';
import 'package:flutter_one/domain/entities/dish.dart';

abstract class DishesRepository {
  Future<List<Dish>> all();
  Future<Dish>       get(int id);
  Future<DishModel> create(DishModel dish);
  Future<Dish>       update(Dish dish);
  Future<void>       delete(int id);
}