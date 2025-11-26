import 'package:flutter/material.dart';
import 'package:flutter_one/domain/repositories/dishes.dart';
import 'package:flutter_one/data/models/dish.dart';
import 'package:flutter_one/domain/entities/dish.dart';

class HomePage extends StatefulWidget {
  final DishesRepository dishesRepository;
  const HomePage({super.key, required this.dishesRepository});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Dish> _dishes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  Future<void> _loadDishes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dishes = await widget.dishesRepository.all();
      setState(() {
        _dishes = dishes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showCreateDishDialog() async {
    final nameController = TextEditingController();
    final photoUrlController = TextEditingController();
    final priceController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Dish'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Dish Name',
                  hintText: 'Enter dish name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: photoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Photo URL',
                  hintText: 'https://example.com/image.jpg',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true) {
      final name = nameController.text.trim();
      final photoUrl = photoUrlController.text.trim();
      final priceText = priceController.text.trim();

      if (name.isEmpty || photoUrl.isEmpty || priceText.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill in all fields'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final price = double.tryParse(priceText);
      if (price == null || price < 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid price'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      try {
        final newDish = DishModel(
          id: 0, // Will be set by server
          name: name,
          photoUrl: photoUrl,
          price: price,
        );

        await widget.dishesRepository.create(newDish);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dish created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        _loadDishes();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating dish: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dishes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $_error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDishes,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _dishes.isEmpty
                  ? const Center(
                      child: Text(
                        'No dishes available',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadDishes,
                      child: ListView.builder(
                        itemCount: _dishes.length,
                        itemBuilder: (context, index) {
                          final dish = _dishes[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(dish.photoUrl),
                              onBackgroundImageError: (_, __) {},
                              child: dish.photoUrl.isEmpty
                                  ? const Icon(Icons.restaurant)
                                  : null,
                            ),
                            title: Text(
                              dish.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '\$${dish.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDishDialog,
        child: const Icon(Icons.add),
        tooltip: 'Create New Dish',
      ),
    );
  }
}