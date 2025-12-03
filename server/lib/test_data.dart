import 'database/database.dart';
import 'auth/jwt_service.dart';

void injectTestData() {
  final db = AppDatabase.instance;

  // Check if data already exists
  final existingPosts = db.db.select('SELECT COUNT(*) as count FROM posts');
  if (existingPosts.first['count'] as int > 0) {
    print('Test data already exists. Skipping injection.');
    return;
  }

  print('Injecting test data...');

  // Insert test users (passwords are hashed)
  db.db.execute(
    'INSERT INTO users (name, phone, password, role, image_url) VALUES (?, ?, ?, ?, ?)',
    ['Admin User', '1234567890', JwtService.hashPassword('admin123'), 'admin', 'https://i.pravatar.cc/150?u=admin'],
  );
  db.db.execute(
    'INSERT INTO users (name, phone, password, role, image_url) VALUES (?, ?, ?, ?, ?)',
    ['John Doe', '0987654321', JwtService.hashPassword('user123'), 'user', 'https://i.pravatar.cc/150?u=john'],
  );
  db.db.execute(
    'INSERT INTO users (name, phone, password, role, image_url) VALUES (?, ?, ?, ?, ?)',
    ['Jane Smith', '1122334455', JwtService.hashPassword('user456'), 'user', 'https://i.pravatar.cc/150?u=jane'],
  );
  db.db.execute(
    'INSERT INTO users (name, phone, password, role, image_url) VALUES (?, ?, ?, ?, ?)',
    ['Bob Wilson', '5566778899', JwtService.hashPassword('user789'), 'user', 'https://i.pravatar.cc/150?u=bob'],
  );

  // Insert test posts
  db.db.execute(
    '''INSERT INTO posts (user_id, title, description, body, image_url, upvotes, downvotes, is_deleted) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
    [
      2,
      'Getting Started with Flutter',
      'A beginner-friendly guide to Flutter development',
      '''Flutter is Google's UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.

## Why Flutter?

1. **Hot Reload** - See changes instantly without losing state
2. **Single Codebase** - Write once, run everywhere
3. **Beautiful UIs** - Create stunning interfaces with ease
4. **Fast Performance** - Compiles to native code

## Getting Started

To get started with Flutter, first install the SDK from flutter.dev. Then create your first project:

```
flutter create my_app
cd my_app
flutter run
```

Happy coding! 🚀''',
      'https://picsum.photos/seed/flutter/800/400',
      42,
      3,
      0,
    ],
  );

  db.db.execute(
    '''INSERT INTO posts (user_id, title, description, body, image_url, upvotes, downvotes, is_deleted) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
    [
      3,
      'Clean Architecture in Dart',
      'How to structure your Dart/Flutter projects using Clean Architecture',
      '''Clean Architecture is a software design philosophy that separates the elements of a design into ring levels.

## The Layers

### Domain Layer
The innermost layer containing business logic:
- Entities (business objects)
- Use cases (application-specific business rules)
- Repository interfaces

### Data Layer
Implementation of repositories:
- Models (data representations)
- Data sources (remote/local)
- Repository implementations

### Presentation Layer
UI and state management:
- Controllers/Blocs/Providers
- Widgets
- Pages

## Benefits

- **Testable** - Each layer can be tested in isolation
- **Maintainable** - Changes in one layer don't affect others
- **Scalable** - Easy to add new features

This architecture keeps your code organized and maintainable!''',
      'https://picsum.photos/seed/architecture/800/400',
      128,
      8,
      0,
    ],
  );

  db.db.execute(
    '''INSERT INTO posts (user_id, title, description, body, image_url, upvotes, downvotes, is_deleted) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
    [
      4,
      'State Management Comparison',
      'Comparing popular state management solutions in Flutter',
      '''Choosing the right state management solution is crucial for your Flutter app.

## Options

### Provider
- Simple and lightweight
- Good for small to medium apps
- Built on InheritedWidget

### Riverpod
- Evolution of Provider
- Compile-time safety
- No BuildContext dependency

### Bloc
- Predictable state changes
- Great for complex apps
- Excellent testing support

### GetX
- Minimal boilerplate
- Includes navigation and DI
- Performance focused

## My Recommendation

For beginners: Start with **Provider**
For complex apps: Use **Bloc** or **Riverpod**
For rapid development: Try **GetX**

What's your favorite? Let me know in the comments! 👇''',
      null,
      89,
      12,
      0,
    ],
  );

  db.db.execute(
    '''INSERT INTO posts (user_id, title, description, body, image_url, upvotes, downvotes, is_deleted) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
    [
      2,
      'API Integration Best Practices',
      'Tips for integrating REST APIs in your Flutter apps',
      '''Working with APIs is a fundamental skill for any Flutter developer.

## Best Practices

### 1. Use a HTTP Client Wrapper
Create an ApiClient class that handles:
- Base URL configuration
- Token injection
- Error handling
- Response parsing

### 2. Model Your Data
Always create model classes with:
- fromJson factory constructor
- toJson method
- Null safety handling

### 3. Handle Errors Gracefully
- Network errors
- Server errors
- Validation errors
- Timeout errors

### 4. Cache When Appropriate
- Use local storage for offline support
- Implement cache invalidation strategies

### 5. Use Interceptors
- Log requests and responses
- Add authentication headers
- Handle token refresh

Following these practices will make your code more robust! 💪''',
      'https://picsum.photos/seed/api/800/400',
      67,
      5,
      0,
    ],
  );

  db.db.execute(
    '''INSERT INTO posts (user_id, title, description, body, image_url, upvotes, downvotes, is_deleted) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
    [
      1,
      '[Announcement] Welcome to Flutter Blog!',
      'Welcome message from the admin',
      '''# Welcome to Flutter Blog! 🎉

We're excited to launch this platform for Flutter developers to share knowledge, ask questions, and connect with the community.

## What you can do here:

- 📝 **Create Posts** - Share your knowledge and experiences
- 💬 **Comment** - Discuss and ask questions
- ⬆️ **Vote** - Support helpful content
- 👤 **Follow** - Stay updated with your favorite authors

## Community Guidelines

1. Be respectful and constructive
2. Share original content
3. Give credit where due
4. Help beginners

Let's build something great together! 🚀

— The Flutter Blog Team''',
      'https://picsum.photos/seed/welcome/800/400',
      256,
      2,
      0,
    ],
  );

  // Insert test comments
  // Comments on "Getting Started with Flutter" post (id: 1)
  db.db.execute(
    '''INSERT INTO comments (post_id, user_id, comment, mentions, upvotes, downvotes) 
       VALUES (?, ?, ?, ?, ?, ?)''',
    [1, 3, 'Great introduction! This helped me a lot when I started.', null, 15, 1],
  );
  db.db.execute(
    '''INSERT INTO comments (post_id, user_id, comment, mentions, upvotes, downvotes) 
       VALUES (?, ?, ?, ?, ?, ?)''',
    [1, 4, '@Jane Smith Glad you found it helpful! Have you tried hot reload yet?', 'Jane Smith', 8, 0],
  );
  db.db.execute(
    '''INSERT INTO comments (post_id, user_id, comment, mentions, upvotes, downvotes) 
       VALUES (?, ?, ?, ?, ?, ?)''',
    [1, 3, '@Bob Wilson Yes! Hot reload is amazing. It makes development so much faster.', 'Bob Wilson', 12, 0],
  );

  // Comments on "Clean Architecture" post (id: 2)
  db.db.execute(
    '''INSERT INTO comments (post_id, user_id, comment, mentions, upvotes, downvotes) 
       VALUES (?, ?, ?, ?, ?, ?)''',
    [2, 2, 'This is exactly what I was looking for. Do you have a GitHub repo with an example?', null, 22, 0],
  );
  db.db.execute(
    '''INSERT INTO comments (post_id, user_id, comment, mentions, upvotes, downvotes) 
       VALUES (?, ?, ?, ?, ?, ?)''',
    [2, 4, 'Clean Architecture can feel like overkill for small projects, but it really shines as your app grows.', null, 18, 2],
  );
  db.db.execute(
    '''INSERT INTO comments (post_id, user_id, comment, mentions, upvotes, downvotes) 
       VALUES (?, ?, ?, ?, ?, ?)''',
    [2, 1, 'Excellent explanation @Jane Smith! Maybe add a section about dependency injection?', 'Jane Smith', 9, 0],
  );

  // Comments on "State Management" post (id: 3)
  db.db.execute(
    '''INSERT INTO comments (post_id, user_id, comment, mentions, upvotes, downvotes) 
       VALUES (?, ?, ?, ?, ?, ?)''',
    [3, 2, 'I started with Provider and recently moved to Riverpod. No regrets!', null, 14, 1],
  );
  db.db.execute(
    '''INSERT INTO comments (post_id, user_id, comment, mentions, upvotes, downvotes) 
       VALUES (?, ?, ?, ?, ?, ?)''',
    [3, 3, 'GetX is controversial but I love how fast I can build apps with it.', null, 7, 5],
  );
  db.db.execute(
    '''INSERT INTO comments (post_id, user_id, comment, mentions, upvotes, downvotes) 
       VALUES (?, ?, ?, ?, ?, ?)''',
    [3, 1, '@Jane Smith GetX is great for prototypes! For production, I prefer Bloc for its predictability.', 'Jane Smith', 11, 0],
  );

  // Comments on "API Integration" post (id: 4)
  db.db.execute(
    '''INSERT INTO comments (post_id, user_id, comment, mentions, upvotes, downvotes) 
       VALUES (?, ?, ?, ?, ?, ?)''',
    [4, 3, 'Would you recommend Dio or http package?', null, 6, 0],
  );
  db.db.execute(
    '''INSERT INTO comments (post_id, user_id, comment, mentions, upvotes, downvotes) 
       VALUES (?, ?, ?, ?, ?, ?)''',
    [4, 2, '@Jane Smith I personally prefer Dio for the interceptors and better error handling. But http works great for simple cases!', 'Jane Smith', 10, 0],
  );

  // Comments on "Welcome" post (id: 5)
  db.db.execute(
    '''INSERT INTO comments (post_id, user_id, comment, mentions, upvotes, downvotes) 
       VALUES (?, ?, ?, ?, ?, ?)''',
    [5, 2, 'Excited to be part of this community! 🎉', null, 25, 0],
  );
  db.db.execute(
    '''INSERT INTO comments (post_id, user_id, comment, mentions, upvotes, downvotes) 
       VALUES (?, ?, ?, ?, ?, ?)''',
    [5, 3, 'This looks amazing! Looking forward to learning and sharing.', null, 19, 0],
  );
  db.db.execute(
    '''INSERT INTO comments (post_id, user_id, comment, mentions, upvotes, downvotes) 
       VALUES (?, ?, ?, ?, ?, ?)''',
    [5, 4, 'Welcome everyone! Let\'s make this the best Flutter community out there!', null, 21, 0],
  );

  print('Test data injected successfully!');
  print('  - 4 users (1 admin, 3 regular)');
  print('  - 5 posts');
  print('  - 15 comments');
}


