# Flutter One Server

A simple SQLite-based REST API server for the Flutter One app, built with Shelf.

## Features

- ✅ SQLite database
- ✅ CRUD operations for Dishes, Orders, and Users
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

### Dishes
- `GET /api/dishes` - Get all dishes
- `GET /api/dishes/<id>` - Get dish by ID
- `POST /api/dishes` - Create a new dish
- `PUT /api/dishes/<id>` - Update a dish
- `DELETE /api/dishes/<id>` - Delete a dish

### Orders
- `GET /api/orders` - Get all orders
- `GET /api/orders/<id>` - Get order by ID
- `POST /api/orders` - Create a new order
- `PUT /api/orders/<id>` - Update an order
- `DELETE /api/orders/<id>` - Delete an order

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
- 3 users (1 admin, 2 regular users)
- 5 dishes
- 3 orders

## Database

The SQLite database is stored in `server/data/app.db`. The database is automatically created on first run.

## Configuration

Set the `PORT` environment variable to change the server port:
```bash
PORT=3000 dart run bin/server.dart
```

