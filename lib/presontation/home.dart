import 'package:flutter/material.dart';
import 'package:flutter_one/data/models/dish.dart';
import 'package:flutter_one/domain/entities/dish.dart';
import 'package:flutter_one/domain/repositories/dishes.dart';
import 'package:flutter_one/manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Dish> _dishes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadDishes();
    });
  }

  Future<void> _loadDishes() async {
    final manager = Manager.of(context)!;
    _dishes = await manager.dishesRepository.all();
    setState(() {});
  }

  // Future<void> _createDish(String name, String photoUrl, double price) async {
  //   final manager = Manager.of(context)!;
  //   await manager.dishesRepository.create(
  //     DishModel(
  //       id: 0,
  //       name: name,
  //       photoUrl: photoUrl,
  //       price: price,
  //     ),
  //   );
  //   setState(() {});
  //   _loadDishes();
  // }

  Future<void> _showCreateDishDialog() async {
    final manager = Manager.of(context)!;
    var name = TextEditingController();
    var photoUrl = TextEditingController();
    var price = TextEditingController();

    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          content: Column(
            children: [
              TextField(controller: name),
              TextField(controller: photoUrl),
              TextField(controller: price),
              ElevatedButton(
                onPressed: () async {
                  final manager = Manager.of(context)!;
                  await manager.dishesRepository.create(
                    DishModel(
                      id: 1,
                      name: name.text,
                      photoUrl: photoUrl.text,
                      price: double.parse(price.text),
                    )
                  );
                  _loadDishes();
                  Navigator.pop(context);
                },
                child: Text('Create'),
              ),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dishes')),
      body: ListView(
        children: [
          for (var dish in _dishes)
            ListTile(
              title: Text(dish.name),
              subtitle: Text(dish.price.toString() + "xxx"),
              leading: Image.network(dish.photoUrl),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDishDialog,
        child: const Icon(Icons.add),
        tooltip: 'Create New Dish',
      ),
    );
  }
}
