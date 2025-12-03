import 'package:flutter/material.dart';
import 'presentation/presentation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: MaterialApp(
        title: 'Blog Platform',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            scrolledUnderElevation: 1,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade900,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade800),
            ),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            scrolledUnderElevation: 1,
          ),
        ),
        themeMode: ThemeMode.system,
        initialRoute: '/posts',
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    // Parse route name
    final uri = Uri.parse(settings.name ?? '/');
    final pathSegments = uri.pathSegments;

    // Auth routes
    if (settings.name == '/login') {
      return MaterialPageRoute(
        builder: (_) => const LoginPage(),
        settings: settings,
      );
    }

    if (settings.name == '/register') {
      return MaterialPageRoute(
        builder: (_) => const RegisterPage(),
        settings: settings,
      );
    }

    if (settings.name == '/profile') {
      return MaterialPageRoute(
        builder: (_) => const ProfilePage(),
        settings: settings,
      );
    }

    // Posts routes
    if (settings.name == '/posts') {
      return MaterialPageRoute(
        builder: (_) => const PostsListPage(),
        settings: settings,
      );
    }

    if (settings.name == '/posts/create') {
      return MaterialPageRoute(
        builder: (_) => const PostCreatePage(),
        settings: settings,
      );
    }

    // /posts/:id
    if (pathSegments.length == 2 && pathSegments[0] == 'posts') {
      final postId = int.tryParse(pathSegments[1]);
      if (postId != null) {
        return MaterialPageRoute(
          builder: (_) => PostDetailPage(postId: postId),
          settings: settings,
        );
      }
    }

    // /posts/:id/edit
    if (pathSegments.length == 3 &&
        pathSegments[0] == 'posts' &&
        pathSegments[2] == 'edit') {
      final postId = int.tryParse(pathSegments[1]);
      if (postId != null) {
        return MaterialPageRoute(
          builder: (_) => PostCreatePage(postId: postId),
          settings: settings,
        );
      }
    }

    // Default: posts list
    return MaterialPageRoute(
      builder: (_) => const PostsListPage(),
      settings: settings,
    );
  }
}
