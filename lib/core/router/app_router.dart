import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/pages.dart';
import '../../presentation/widgets/shell_scaffold.dart';

/// App router configuration using go_router with shell route
class AppRouter {
  // Route paths as constants for type safety
  static const String postsPath = '/posts';
  static const String profilePath = '/profile';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String createPostPath = '/posts/create';
  static const String postDetailPath = '/posts/:id';
  static const String editPostPath = '/posts/:id/edit';
  static const String errorPath = '/error';

  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: postsPath,
      errorBuilder: (context, state) => const Scaffold(
        body: Center(child: Text('Page not found')),
      ),
      routes: [
        // Shell route with bottom navigation for main screens
        ShellRoute(
          builder: (context, state, child) {
            return ShellScaffold(child: child);
          },
          routes: [
            GoRoute(
              path: postsPath,
              // Use NoTransitionPage to prevent animations when switching between bottom nav tabs
              pageBuilder: (context, state) => const NoTransitionPage(
                child: PostsListPage(),
              ),
            ),
            GoRoute(
              path: profilePath,
              // Use NoTransitionPage to prevent animations when switching between bottom nav tabs
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfilePage(),
              ),
            ),
          ],
        ),
        // Routes outside shell (no bottom nav)
        GoRoute(
          path: loginPath,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: registerPath,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: createPostPath,
          builder: (context, state) => const PostCreatePage(),
        ),
        GoRoute(
          path: postDetailPath,
          redirect: (context, state) => _validatePostId(state),
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return PostDetailPage(postId: id);
          },
        ),
        GoRoute(
          path: editPostPath,
          redirect: (context, state) => _validatePostId(state),
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return PostCreatePage(postId: id);
          },
        ),
        GoRoute(
          path: errorPath,
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Invalid post ID')),
          ),
        ),
      ],
    );
  }

  /// Validates post ID parameter and redirects to error page if invalid
  static String? _validatePostId(GoRouterState state) {
    final id = int.tryParse(state.pathParameters['id'] ?? '');
    return id == null ? errorPath : null;
  }
}
