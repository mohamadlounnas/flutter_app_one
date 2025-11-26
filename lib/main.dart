import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_one/data/datasource/dishes.dart';
import 'package:flutter_one/data/repositories/dishes.dart';
import 'package:flutter_one/domain/repositories/dishes.dart';
import 'package:flutter_one/presontation/home.dart';

void main() async {
  var client = Dio();
  
  // Auto-detect API URL based on current host (works for both local and deployed)
  // When served from /flutter, use the same host for API
  if (Uri.base.host.isNotEmpty && Uri.base.host != 'localhost') {
    // Running on web - use same origin for API
    client.options.baseUrl = '${Uri.base.scheme}://${Uri.base.host}${Uri.base.hasPort ? ':${Uri.base.port}' : ''}';
  } else {
    // Local development fallback
    client.options.baseUrl = 'http://localhost:8080';
  }

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
