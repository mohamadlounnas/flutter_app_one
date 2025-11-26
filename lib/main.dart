import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_one/data/datasource/dishes.dart';
import 'package:flutter_one/data/repositories/dishes.dart';
import 'package:flutter_one/domain/repositories/dishes.dart';
import 'package:flutter_one/presontation/home.dart';

void main() async {

  var client = Dio();
  client.options.baseUrl = 'https://flutter-one-server-production.up.railway.app';

  // dishes
  var datasource = RemoteDishesDataSource(client: client);
  var dishesRepository = DishesRepositoryImpl(remoteDishesDataSource: datasource);

  
  runApp(App(
    dishesRepository: dishesRepository,
    // ordersRepository: ordersRepository,
    // usersRepository: usersRepository,
  ));
}

class App extends StatelessWidget {
  final DishesRepository dishesRepository;

  const App({super.key, required this.dishesRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(dishesRepository: dishesRepository),
    );
  }
}
