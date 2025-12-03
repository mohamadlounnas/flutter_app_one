import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/pages.dart';
import '../../presentation/widgets/shell_scaffold.dart';

/// App router configuration using go_router with shell route
class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/posts',
      routes: [
        // Shell route with bottom navigation for main screens
        ShellRoute(
          builder: (context, state, child) {
            return ShellScaffold(child: child);
          },
          routes: [
            GoRoute(
              path: '/posts',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: PostsListPage(),
              ),
            ),
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfilePage(),
              ),
            ),
          ],
        ),
        // Routes outside shell (no bottom nav)
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/posts/create',
          builder: (context, state) => const PostCreatePage(),
        ),
        GoRoute(
          path: '/posts/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return PostDetailPage(postId: id);
          },
        ),
        GoRoute(
          path: '/posts/:id/edit',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return PostCreatePage(postId: id);
          },
        ),
      ],
    );
  }
}
