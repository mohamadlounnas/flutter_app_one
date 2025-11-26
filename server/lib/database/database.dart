import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

class AppDatabase {
  static AppDatabase? _instance;
  late Database _db;
  late String _dbPath;

  AppDatabase._();

  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  Database get db => _db;

  void initialize() {
    // Create database directory if it doesn't exist
    final dbDir = Directory('data');
    if (!dbDir.existsSync()) {
      dbDir.createSync(recursive: true);
    }

    _dbPath = path.join(dbDir.path, 'app.db');
    _db = sqlite3.open(_dbPath);

    _createTables();
    print('Database initialized at: $_dbPath');
  }

  void _createTables() {
    // Create users table
    _db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL UNIQUE,
        password TEXT,
        role TEXT NOT NULL
      )
    ''');

    // Create dishes table
    _db.execute('''
      CREATE TABLE IF NOT EXISTS dishes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        photoUrl TEXT NOT NULL,
        price REAL NOT NULL
      )
    ''');

    // Create orders table
    _db.execute('''
      CREATE TABLE IF NOT EXISTS orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        phone TEXT NOT NULL,
        dishId TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

    print('Database tables created successfully');
  }

  void close() {
    _db.dispose();
  }
}

