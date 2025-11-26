import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_one/data/datasource/dishes.dart';
import 'package:flutter_one/data/repositories/dishes.dart';
import 'package:flutter_one/domain/repositories/dishes.dart';
import 'package:flutter_one/presontation/home.dart';

void main() async {
  var client = Dio();
  
  // Auto-detect API URL based on current host
  // When served from /flutter, use the same host for API
  try {
    final baseUri = Uri.base;
    if (baseUri.host.isNotEmpty && baseUri.host != 'localhost' && baseUri.host != '127.0.0.1') {
      // Running on web (deployed) - use same origin for API
      final port = baseUri.hasPort ? ':${baseUri.port}' : '';
      client.options.baseUrl = '${baseUri.scheme}://${baseUri.host}$port';
    } else {
      // Local development
      client.options.baseUrl = 'http://localhost:8080';
    }
  } catch (e) {
    // Fallback to localhost if detection fails
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
