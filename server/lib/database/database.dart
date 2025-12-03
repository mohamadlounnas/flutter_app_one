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
    // Create users table with imageUrl, createdAt, updatedAt
    _db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL UNIQUE,
        password TEXT,
        image_url TEXT,
        role TEXT NOT NULL DEFAULT 'user',
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT
      )
    ''');

    // Create posts table
    _db.execute('''
      CREATE TABLE IF NOT EXISTS posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        body TEXT NOT NULL,
        image_url TEXT,
        upvotes INTEGER DEFAULT 0,
        downvotes INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0,
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT,
        deleted_at TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    ''');

    // Create comments table
    _db.execute('''
      CREATE TABLE IF NOT EXISTS comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        post_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        comment TEXT NOT NULL,
        mentions TEXT,
        upvotes INTEGER DEFAULT 0,
        downvotes INTEGER DEFAULT 0,
        created_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY(post_id) REFERENCES posts(id),
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    ''');

    // Create storage table for file uploads
    _db.execute('''
      CREATE TABLE IF NOT EXISTS storage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner_id INTEGER,
        file_name TEXT NOT NULL,
        content_type TEXT,
        size INTEGER,
        url TEXT NOT NULL,
        created_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY(owner_id) REFERENCES users(id)
      )
    ''');

    print('Database tables created successfully');
  }

  void close() {
    _db.dispose();
  }

  /// Reset database for testing (drops all data)
  void reset() {
    _db.execute('DELETE FROM comments');
    _db.execute('DELETE FROM posts');
    _db.execute('DELETE FROM storage');
    _db.execute('DELETE FROM users');
    print('Database reset successfully');
  }
}

