# Routing Documentation

## Overview

This application uses `go_router` for declarative routing with a shell route pattern. The shell route provides persistent bottom navigation across main screens.

## Router Configuration

The router is configured in `lib/core/router/app_router.dart` using `go_router` package version ^14.6.2.

### Shell Route

The shell route wraps the main screens (Home and Profile) with a persistent bottom navigation bar:

```dart
ShellRoute(
  builder: (context, state, child) {
    return ShellScaffold(child: child);
  },
  routes: [
    GoRoute(path: '/posts', ...),
    GoRoute(path: '/profile', ...),
  ],
)
```

### Routes Outside Shell

Routes that don't need the bottom navigation (login, register, post details, etc.) are defined outside the shell route:

- `/login` - Login page
- `/register` - Register page
- `/posts/create` - Create new post
- `/posts/:id` - Post detail page
- `/posts/:id/edit` - Edit post page

## Navigation Methods

### Using go_router

Always use `go_router`'s context extension methods instead of Navigator:

```dart
// Replace current route (like pushReplacement)
context.go('/posts');

// Push a new route (can pop back)
context.push('/posts/create');

// Pop current route
context.pop();
```

### Navigation Examples

```dart
// Navigate to post detail
context.push('/posts/$postId');

// Navigate to edit post
context.push('/posts/$postId/edit');

// Navigate to login (replace)
context.go('/login');

// Go back
context.pop();
```

## Bottom Navigation

The `ShellScaffold` widget (in `lib/presentation/widgets/shell_scaffold.dart`) provides:

- Home tab (navigates to `/posts`)
- Profile tab (navigates to `/profile`)

The bottom navigation automatically highlights the current route and persists across the shell routes.

## Theme

The app uses a Reddit-inspired theme:

### Colors
- **Primary (Orange)**: `Color(0xFFFF4500)` - Reddit's iconic orange
- **Light Background**: `Color(0xFFDAE0E6)` - Light grey
- **Dark Background**: `Color(0xFF1A1A1B)` - Dark grey

### Design Principles
- Material Design 3
- Reddit-style card design with rounded corners
- Minimal elevation
- Clean, modern look with subtle borders

## Adding New Routes

1. Define the route in `lib/core/router/app_router.dart`
2. Choose whether it should be inside or outside the shell route:
   - **Inside shell** = needs bottom navigation (main screens)
   - **Outside shell** = full screen, no bottom nav (modals, detail pages, auth)
3. Use `context.go()`, `context.push()`, or `context.pop()` for navigation

Example:
```dart
GoRoute(
  path: '/new-feature',
  builder: (context, state) => const NewFeaturePage(),
)
```

## Migration Notes

All navigation has been migrated from `Navigator` to `go_router`:

- `Navigator.of(context).pushNamed(route)` → `context.push(route)`
- `Navigator.of(context).pushReplacementNamed(route)` → `context.go(route)`
- `Navigator.of(context).pop()` → `context.pop()`

## Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  go_router: ^14.6.2
```
