# Plan: Refactor to Clean Architecture Blog Platform

Transform the existing food ordering app into a blog/social platform with users, posts, comments, and file storage. Implement clean architecture in Flutter with `InheritedNotifier` / `ChangeNotifier` state management, and organize the server with matching models, well-structured handlers, and OpenAPI documentation.

This plan documents the structure for the Flutter client and the server, and lists every file referenced in the architecture so you can scaffold or implement step-by-step.

---

## Goals
- Convert app to a blog platform (users, posts, comments, file uploads)
- Use Clean Architecture: domain / data / presentation / core
- Use `ChangeNotifier` + `InheritedNotifier` as the state management approach with a simple DI composition root
- Decouple domain logic from network and storage by using repository interfaces and data sources
- Keep server models aligned with client DTOs and share schema definitions wherever feasible
- Add OpenAPI docs and tests

---

## Flutter Client - Clean Architecture (single-page reference)

Structure (lib/):

```
lib/
  core/
    api/
      api_client.dart              # http client & headers/token
      network_exceptions.dart      # network exception mapping
    storage/
      storage_service.dart         # local
    errors/
      exceptions.dart
      failures.dart
    utils/
      date_time_utils.dart
      validators.dart
    constants.dart                 # App constants
  domain/
    entities/
      user.dart
      post.dart
      comment.dart
    repositories/
      auth_repository.dart
      posts_repository.dart
      comments_repository.dart
  data/
    models/
      user_model.dart
      post_model.dart
      comment_model.dart
    datasources/
      remote/
        auth_remote_data_source.dart
        posts_remote_data_source.dart
        comments_remote_data_source.dart
      local/
        cache_data_source.dart
    repositories/
      auth_repository_impl.dart
      posts_repository_impl.dart
      comments_repository_impl.dart
  presentation/
    providers/
      app_providers.dart            # composition root for providers
    controllers/
      auth_controller.dart          # ChangeNotifier for auth flows
      posts_controller.dart         # ChangeNotifier for posts flows
      comments_controller.dart      # ChangeNotifier for comments
    pages/
      auth/
        login_page.dart
        register_page.dart
        profile_page.dart
      posts/
        posts_list_page.dart
        post_detail_page.dart
        post_create_page.dart
      comments/
        comments_page.dart
    widgets/
      post_card.dart
      comment_tile.dart
      avatar_widget.dart
  main.dart
```

### Notes & Responsibilities
- `domain/entities`: contain pure business objects with no JSON or IO logic
- `domain/repositories`: abstract interfaces used by domain & presentation
- `domain/usecases`: orchestrate business operations (optional but recommended)
- `data/dtos`: JSON / network models (snake_case JSON mapping)
- `data/mappers`: convert DTO <-> domain entities
- `data/datasources/remote`: low-level API calls using `api_client`
- `data/repositories/*_impl.dart`: implement `domain/repositories` using datasources and mappers
- `presentation/controllers`: `ChangeNotifier`s used by UI pages and wrapped in `InheritedNotifier` providers

---

## Server (shelf + sqlite) - Clean Architecture

Structure (server/lib/):

```
server/lib/
  core/
    errors.dart
    validators.dart
  domain/
    entities/
      user.dart
      post.dart
      comment.dart
    repositories/
      posts_repository.dart
      comments_repository.dart
  data/
    models/                          # DTOs / DB mapping
      user_model.dart
      post_model.dart
      comment_model.dart
    repositories/
      posts_repository_impl.dart
      comments_repository_impl.dart
    datasources/
      database_datasource.dart       # raw SQL layer
      storage_datasource.dart        # local or S3
  services/
    auth_service.dart
    posts_service.dart
    comments_service.dart
  presentation/
    handlers/
      auth_handler.dart
      post_handler.dart
      comment_handler.dart
      storage_handler.dart
    middlewares/
      auth_middleware.dart
      role_middleware.dart
  database/
    database.dart
    migrations/
      0001_create_tables.sql
  routes.dart
  docs/
    openapi.dart
  test/
    // unit & integration test files
```

### DB Schema (SQL) - snippet (migration files)
`0001_create_tables.sql`: idempotent schema creation

```sql
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT NOT NULL UNIQUE,
  password TEXT,
  image_url TEXT,
  role TEXT NOT NULL DEFAULT 'user',
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT
);

CREATE TABLE IF NOT EXISTS posts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  body TEXT NOT NULL,
  image_url TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT,
  deleted_at TEXT,
  FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS comments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  post_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  comment TEXT NOT NULL,
  mentions TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY(post_id) REFERENCES posts(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS storage (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  owner_id INTEGER,
  file_name TEXT NOT NULL,
  content_type TEXT,
  size INTEGER,
  url TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY(owner_id) REFERENCES users(id)
);
```

### Handlers & Endpoints (summary)
- `/api/auth/register` — POST (register user) — `auth_handler.dart`
- `/api/auth/login` — POST (login user) — `auth_handler.dart`
- `/api/auth/me` — GET/PUT (fetch & update current user)
- `/api/posts` — GET (list, filter), POST (create), PUT (update), DELETE (soft delete), PATCH /restore
- `/api/posts/{id}/comments` — GET/POST
- `/api/comments/{id}` — PUT/DELETE
- `/api/storage/upload` — POST (file upload)
- `/docs` & `/openapi.json` — OpenAPI UI and file

---

## Conversions & Mapping Rules
- DTO/Network JSON uses snake_case (example: `image_url`) and maps to Dart DTOs with `fromJson` / `toJson`.
- DTOs map to domain Entities via `mappers/*` classes (DTO -> Entity and Entity -> DTO).
- Domain Entities have no `toJson/fromJson` - they are used purely inside the domain & controllers.

---

## Notifier / Provider Wiring Example (client)
- Use `ChangeNotifier` classes under `presentation/controllers/`.
- Add `lib/presentation/providers/app_providers.dart` to instantiate and wire notifiers using `InheritedNotifier` wrappers.

Example usage in `main.dart`:
```dart
final apiClient = ApiClient(baseUrl: ApiConstants.baseUrl);
final postsRemote = PostsRemoteDataSourceImpl(apiClient);
final postsRepo = PostsRepositoryImpl(remote: postsRemote);
final fetchPostsUsecase = FetchPostsUsecase(postsRepo);
final postsController = PostsController(fetchPostsUsecase, ...);

runApp(AppProviders(postsController: postsController, child: MyApp()));
```

---

## Test & Migration Plan (summary)
- Add SQL migrations in `server/lib/database/migrations/` and apply them on server start.
- Preserve `dishes` / `orders` as `legacy` tables until migration validation completes.
- Write server unit tests and integration tests for handlers in `server/test/`.
- Add client unit tests for mappers, use cases, and controllers in `test/`.

---

## Security & Operational Considerations
- Replace SHA-256 hashing with `bcrypt` or `argon2` via `password_service.dart`.
- File uploads: local storage for dev (`/uploads`) and S3 for production (implement `StorageService`).
- Soft-deletes: `deleted_at` on `posts` — default queries should exclude `deleted_at` unless query param passed.
- Input validation & rate limiting on auth endpoints.

---

## Suggested Implementation Order (milestones)
1. Scaffold `domain` + `data` folder structure + mappers and DTOs.
2. Implement `api_client.dart` and remote data sources; build and test API calls.
3. Create `posts` & `comments` server tables and handlers with migration scripts.
4. Implement `posts_controller`, `posts_repository_impl`, and `posts_page` on client; wire full create / list flow.
5. Add `auth` flow (register/login/me) and secure private endpoints.
6. Add `storage` server & client flows for file uploads.
7. Add OpenAPI docs, tests, and CI.

---

If you want, I can scaffold the files (skeletons with TODOs) now or implement a working example for a single flow (e.g., posts list/create pipeline), which is usually the best way to validate the architecture. Tell me which one you prefer.
# Plan: Refactor to Clean Architecture Blog Platform

Transform the existing food ordering app into a blog/social platform with users, posts, comments, and file storage. Implement clean architecture in Flutter with `InheritedNotifier`/`ChangeNotifier` state management, and organize the server with shared models and OpenAPI documentation.

## Steps

1. **undersand the project** read in mind each detial.

2. **Restructure Flutter app** to clean architecture in `lib/`:
   - `domain/` — Entities and repository interfaces
   - `data/` — Repository implementations, data sources, models Create `user.dart` (id, name, phone, password, imageUrl), `post.dart` (id, title, description, body, imageUrl, createdAt, updatedAt, deletedAt), `comment.dart` (id, postId, userId, comment, mentions, createdAt) with JSON serialization., API client in datasource
   - `presentation/` — Pages, widgets, state (`ChangeNotifier` providers with `InheritedNotifier`)
   - `core/` — Constants, utils, errors

3. **Implement Flutter state management** — Create `AuthNotifier`, `PostsNotifier`, `CommentsNotifier` extending `ChangeNotifier`, wrap with custom `InheritedNotifier` widgets for dependency injection.

4. **Refactor server database** in `server/lib/database/database.dart` — Replace dishes/orders tables with `users` (add imageUrl), `posts`, `comments`, `storage` tables; update schema initialization.

5. **Create server handlers** in `server/lib/handlers/`:
   - `auth_handler.dart` — Update for imageUrl field, signin/signup/me/update
   - `post_handler.dart` — Full CRUD with soft delete support
   - `comment_handler.dart` — CRUD with mentions parsing
   - `storage_handler.dart` — File upload returning public URL

6. **Add OpenAPI/Swagger docs** — Create `server/lib/docs/openapi.dart` with OpenAPI 3.1 spec, serve at `/docs` and `/openapi.json`; update `server/lib/routes.dart` with Swagger UI HTML.

7. **Update test data** in `server/lib/test_data.dart` — Inject sample users (with imageUrl), posts, and comments for development testing.

## tests

1. **server?** test all apis with real test then wipe sqlite db after each test.
2. **frontend** — check desing is curreect and clean and simple like reddit style exacly

## Write conclusion and last verification