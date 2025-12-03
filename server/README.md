# Flutter One Server

A simple SQLite-based REST API server for the Flutter One app, built with Shelf.

## Features

- ✅ SQLite database
- ✅ CRUD operations for Dishes, Orders, and Users
 - ✅ CRUD operations for Posts, Comments, Storage, and Users
- ✅ CORS enabled for local network access
- ✅ Test data injection
- ✅ Reuses existing Flutter models

## Setup

1. Install dependencies:
```bash
cd server
dart pub get
```

2. Run the server:
```bash
dart run bin/server.dart
```

The server will start on `http://0.0.0.0:8080` (accessible from your local network).

## API Endpoints

### Posts
- `GET /api/posts` - Get all posts
- `GET /api/posts/<id>` - Get post by ID
- `GET /api/posts/user/<userId>` - Get posts by a user
- `POST /api/posts` - Create a new post (authenticated)
- `PUT /api/posts/<id>` - Update a post (owner/admin)
- `DELETE /api/posts/<id>` - Delete a post (owner/admin, soft delete)

### Comments
- `GET /api/posts/<postId>/comments` - Get all comments for a post
- `GET /api/comments/<id>` - Get a comment by ID
- `POST /api/posts/<postId>/comments` - Create a new comment (authenticated)
- `PUT /api/comments/<id>` - Update a comment (owner/admin)
- `DELETE /api/comments/<id>` - Delete a comment (owner/admin)

### Storage
- `POST /api/storage/upload` - Upload a file (authenticated)
- `GET /api/storage/my` - List files for current user (authenticated)
- `GET /api/storage/<filename>` - Download a file by filename
- `DELETE /api/storage/<id>` - Delete a file (owner/admin)

### Users
- `GET /api/users` - Get all users
- `GET /api/users/<id>` - Get user by ID
- `POST /api/users` - Create a new user
- `PUT /api/users/<id>` - Update a user
- `DELETE /api/users/<id>` - Delete a user

### Health Check
- `GET /health` - Check if server is running

## Test Data

Test data is automatically injected on first run:
- 4 users (1 admin, 3 regular users)
- 5 posts
- 15 comments

## Database

The SQLite database is stored in `server/data/app.db`. The database is automatically created on first run.

## Configuration

Set the `PORT` environment variable to change the server port:
```bash
PORT=3000 dart run bin/server.dart
```

## Testing

Run integration tests (these will start the server if not already running):
```bash
dart test server/test/server_test.dart
```



