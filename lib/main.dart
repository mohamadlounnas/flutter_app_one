import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_one/data/datasource/dishes.dart';
import 'package:flutter_one/data/repositories/dishes.dart';
import 'package:flutter_one/domain/repositories/dishes.dart';
import 'package:flutter_one/manager.dart';
import 'package:flutter_one/presontation/home.dart';

void main() async {
  var client = Dio();
  client.options.baseUrl = 'https://flutter-one-server-production.up.railway.app';

  // dishes
  var datasource = RemoteDishesDataSource(client: client);
  var dishesRepository = DishesRepositoryImpl(remoteDishesDataSource: datasource);

  runApp(
    Manager(
      dishesRepository: dishesRepository,
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}
