import 'database/database.dart';

void injectTestData() {
  final db = AppDatabase.instance;

  // Check if data already exists
  final existingDishes = db.db.select('SELECT COUNT(*) as count FROM dishes');
  if (existingDishes.first['count'] as int > 0) {
    print('Test data already exists. Skipping injection.');
    return;
  }

  print('Injecting test data...');

  // Insert test users
  db.db.execute(
    'INSERT INTO users (name, phone, password, role) VALUES (?, ?, ?, ?)',
    ['Admin User', '1234567890', 'admin123', 'admin'],
  );
  db.db.execute(
    'INSERT INTO users (name, phone, password, role) VALUES (?, ?, ?, ?)',
    ['John Doe', '0987654321', 'user123', 'user'],
  );
  db.db.execute(
    'INSERT INTO users (name, phone, password, role) VALUES (?, ?, ?, ?)',
    ['Jane Smith', '1122334455', 'user456', 'user'],
  );

  // Insert test dishes
  db.db.execute(
    'INSERT INTO dishes (name, photoUrl, price) VALUES (?, ?, ?)',
    ['Pizza Margherita', 'https://example.com/pizza.jpg', 12.99],
  );
  db.db.execute(
    'INSERT INTO dishes (name, photoUrl, price) VALUES (?, ?, ?)',
    ['Burger Deluxe', 'https://example.com/burger.jpg', 9.99],
  );
  db.db.execute(
    'INSERT INTO dishes (name, photoUrl, price) VALUES (?, ?, ?)',
    ['Caesar Salad', 'https://example.com/salad.jpg', 7.99],
  );
  db.db.execute(
    'INSERT INTO dishes (name, photoUrl, price) VALUES (?, ?, ?)',
    ['Pasta Carbonara', 'https://example.com/pasta.jpg', 11.99],
  );
  db.db.execute(
    'INSERT INTO dishes (name, photoUrl, price) VALUES (?, ?, ?)',
    ['Chicken Curry', 'https://example.com/curry.jpg', 13.99],
  );

  // Insert test orders
  db.db.execute(
    'INSERT INTO orders (userId, phone, dishId, latitude, longitude, address, completed) VALUES (?, ?, ?, ?, ?, ?, ?)',
    [2, '0987654321', '1', 40.7128, -74.0060, '123 Main St, New York, NY', 0],
  );
  db.db.execute(
    'INSERT INTO orders (userId, phone, dishId, latitude, longitude, address, completed) VALUES (?, ?, ?, ?, ?, ?, ?)',
    [3, '1122334455', '2', 34.0522, -118.2437, '456 Oak Ave, Los Angeles, CA', 1],
  );
  db.db.execute(
    'INSERT INTO orders (userId, phone, dishId, latitude, longitude, address, completed) VALUES (?, ?, ?, ?, ?, ?, ?)',
    [2, '0987654321', '3', 40.7128, -74.0060, '789 Pine Rd, New York, NY', 0],
  );

  print('Test data injected successfully!');
  print('  - 3 users');
  print('  - 5 dishes');
  print('  - 3 orders');
}

