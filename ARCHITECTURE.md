# Architecture Overview

## Routing Structure

```
┌─────────────────────────────────────────────────────────┐
│                     MaterialApp.router                  │
│                   (AppRouter.createRouter)               │
└─────────────────────────────────────────────────────────┘
                            │
                            ├─ Shell Route (with bottom nav)
                            │  │
                            │  ├─ /posts → PostsListPage
                            │  │   └─ Shows: Home feed
                            │  │
                            │  └─ /profile → ProfilePage
                            │     └─ Shows: User profile
                            │
                            └─ Non-Shell Routes (no bottom nav)
                               │
                               ├─ /login → LoginPage
                               ├─ /register → RegisterPage
                               ├─ /posts/create → PostCreatePage
                               ├─ /posts/:id → PostDetailPage
                               └─ /posts/:id/edit → PostCreatePage(edit)
```

## Shell Route Pattern

The shell route provides a persistent scaffold that wraps certain pages:

```
┌──────────────────────────────────────────┐
│          AppBar (from page)              │
├──────────────────────────────────────────┤
│                                          │
│                                          │
│          Page Content (child)            │
│          (PostsListPage or ProfilePage)  │
│                                          │
│                                          │
├──────────────────────────────────────────┤
│      Bottom Navigation Bar               │
│   [Home]           [Profile]             │
└──────────────────────────────────────────┘
```

## Navigation Flow

### Shell Route Pages (with bottom nav)

```
   Posts List ←──────→ Profile
   (/posts)           (/profile)
      │                   │
      │ context.push()    │
      ↓                   ↓
   [Bottom Nav Persists]
```

### Non-Shell Route Pages (no bottom nav)

```
Shell Page → context.push() → Detail Page
(/posts)                      (/posts/:id)
   ↓                              ↓
[Has Bottom Nav]            [No Bottom Nav]
```

## File Organization

```
lib/
├── core/
│   ├── router/
│   │   └── app_router.dart          ← Router configuration
│   ├── api/
│   ├── storage/
│   ├── utils/
│   └── core.dart                     ← Exports router
│
├── presentation/
│   ├── pages/
│   │   ├── auth/
│   │   │   ├── login_page.dart      ← Uses context.go()
│   │   │   ├── register_page.dart   ← Uses context.pop()
│   │   │   └── profile_page.dart    ← In shell route
│   │   └── posts/
│   │       ├── posts_list_page.dart ← In shell route
│   │       ├── post_detail_page.dart
│   │       └── post_create_page.dart
│   │
│   ├── widgets/
│   │   ├── shell_scaffold.dart      ← Shell with bottom nav
│   │   ├── post_card.dart
│   │   └── ...
│   │
│   ├── controllers/
│   └── providers/
│
├── domain/
└── data/
```

## Theme Architecture

### Color Scheme

```
Light Theme:
┌─────────────────────────────────┐
│ Primary: #FF4500 (Reddit Orange)│
│ Background: #DAE0E6 (Light Grey)│
│ Surface: White                  │
│ Cards: Rounded, Subtle Border   │
└─────────────────────────────────┘

Dark Theme:
┌─────────────────────────────────┐
│ Primary: #FF4500 (Reddit Orange)│
│ Background: #1A1A1B (Dark Grey) │
│ Surface: Dark                   │
│ Cards: Rounded, Subtle Border   │
└─────────────────────────────────┘
```

### Component Style

```
Post Card:
┌────────────────────────────────┐
│ ◉ u/username · 2h ago          │
│                                │
│ Post Title in Bold             │
│ Post description text...       │
│                                │
│ [Image if present]             │
│                                │
│ ⬆ 42 ⬇  💬 5  ↗ Share         │
└────────────────────────────────┘
```

## Navigation Methods

### Context Extensions (go_router)

```dart
// Replace route (like pushReplacement)
context.go('/posts');

// Push new route (can go back)
context.push('/posts/123');

// Go back
context.pop();

// Get current location
GoRouterState.of(context).uri.path;
```

## Data Flow

```
User Action → Widget
     ↓
context.push('/posts/123')
     ↓
go_router (AppRouter)
     ↓
Route Resolution
     ↓
Page Builder
     ↓
PostDetailPage(postId: 123)
     ↓
UI Render
```

## Bottom Navigation State

The bottom nav tracks the current route:

```dart
if (currentPath.startsWith('/posts'))    → Home selected
if (currentPath.startsWith('/profile'))  → Profile selected
```

## Error Handling

```
Route: /posts/invalid
     ↓
int.tryParse('invalid') returns null
     ↓
Show error scaffold:
┌────────────────────────────────┐
│         Invalid post ID         │
└────────────────────────────────┘
```

## Benefits of This Architecture

1. **Separation of Concerns**
   - Routing logic in one place (AppRouter)
   - UI components focused on display
   - Navigation decoupled from widgets

2. **Type Safety**
   - Compile-time route checking
   - Parameter validation
   - Error handling

3. **Maintainability**
   - Easy to add new routes
   - Clear navigation patterns
   - Centralized configuration

4. **User Experience**
   - Persistent bottom nav on main screens
   - Smooth transitions
   - Intuitive navigation

5. **Scalability**
   - Easy to add more tabs
   - Support for nested navigation
   - Deep linking ready
