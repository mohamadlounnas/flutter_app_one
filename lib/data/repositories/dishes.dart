// Implementation of the DishesRepository

import 'package:flutter_one/data/datasource/dishes.dart';
import 'package:flutter_one/data/models/dish.dart';
import 'package:flutter_one/domain/entities/dish.dart';
import 'package:flutter_one/domain/repositories/dishes.dart';

class DishesRepositoryImpl implements DishesRepository {

  final RemoteDishesDataSource remoteDishesDataSource;

  DishesRepositoryImpl({required this.remoteDishesDataSource});

  @override
  Future<List<Dish>> all() {
    return remoteDishesDataSource.all();
  }

  @override
  Future<DishModel> create(DishModel dish) {
    return remoteDishesDataSource.create(dish);
  }

  @override
  Future<void> delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<Dish> get(int id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<Dish> update(Dish dish) {
    // TODO: implement update
    throw UnimplementedError();
  }

}