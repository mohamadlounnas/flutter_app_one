import 'package:flutter/material.dart';
import 'package:flutter_one/domain/repositories/dishes.dart';

class Manager extends InheritedWidget {
  final DishesRepository dishesRepository;

  const Manager({super.key, required super.child, required this.dishesRepository});

  @override
  bool updateShouldNotify(Manager oldWidget) {
    return true;
  }

  static Manager? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Manager>();
  }
}