// Embedded API documentation HTML
const String apiDocsHtml = r'''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Flutter One API Documentation</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }

        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px;
            text-align: center;
        }

        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }

        .header p {
            font-size: 1.1em;
            opacity: 0.9;
        }

        .content {
            padding: 40px;
        }

        .section {
            margin-bottom: 40px;
        }

        .section-title {
            font-size: 1.8em;
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 3px solid #667eea;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .endpoint {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 8px;
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .endpoint:hover {
            transform: translateX(5px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .endpoint.protected {
            border-left-color: #fca130;
        }

        .endpoint.admin-only {
            border-left-color: #f93e3e;
        }

        .method {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 4px;
            font-weight: bold;
            font-size: 0.9em;
            margin-right: 10px;
        }

        .method.get { background: #61affe; color: white; }
        .method.post { background: #49cc90; color: white; }
        .method.put { background: #fca130; color: white; }
        .method.delete { background: #f93e3e; color: white; }

        .badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 0.75em;
            font-weight: bold;
            margin-left: 10px;
            vertical-align: middle;
        }

        .badge.public { background: #49cc90; color: white; }
        .badge.protected { background: #fca130; color: white; }
        .badge.admin { background: #f93e3e; color: white; }

        .path {
            font-family: 'Courier New', monospace;
            font-size: 1.1em;
            color: #333;
            font-weight: 600;
        }

        .description {
            margin: 15px 0;
            color: #666;
            line-height: 1.6;
        }

        .example {
            background: #2d2d2d;
            color: #f8f8f2;
            padding: 15px;
            border-radius: 6px;
            margin: 10px 0;
            overflow-x: auto;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
        }

        .example-title {
            color: #888;
            font-size: 0.85em;
            margin-bottom: 8px;
            text-transform: uppercase;
        }

        .response {
            background: #1e1e1e;
            color: #d4d4d4;
            padding: 15px;
            border-radius: 6px;
            margin: 10px 0;
            overflow-x: auto;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
        }

        .params {
            margin: 15px 0;
        }

        .param {
            display: flex;
            gap: 15px;
            padding: 8px 0;
            border-bottom: 1px solid #e0e0e0;
        }

        .param-name {
            font-weight: 600;
            color: #667eea;
            min-width: 120px;
            font-family: 'Courier New', monospace;
        }

        .param-type {
            color: #999;
            font-size: 0.9em;
        }

        .param-desc {
            color: #666;
            flex: 1;
        }

        .info-box {
            background: #e3f2fd;
            border-left: 4px solid #2196f3;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
        }

        .info-box strong {
            color: #1976d2;
        }

        .warning-box {
            background: #fff3e0;
            border-left: 4px solid #ff9800;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
        }

        .warning-box strong {
            color: #e65100;
        }

        .legend {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            margin: 20px 0;
            padding: 15px;
            background: #f5f5f5;
            border-radius: 8px;
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: 8px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🍽️ Flutter One API</h1>
            <p>RESTful API Documentation with JWT Authentication</p>
        </div>

        <div class="content">
            <div class="info-box">
                <strong>Base URL:</strong> <code>http://localhost:8080</code><br>
                <strong>Content-Type:</strong> <code>application/json</code>
            </div>

            <div class="warning-box">
                <strong>🔐 Authentication:</strong> Protected endpoints require a JWT token in the Authorization header:<br>
                <code>Authorization: Bearer &lt;your_token&gt;</code>
            </div>

            <div class="legend">
                <div class="legend-item"><span class="badge public">Public</span> No authentication required</div>
                <div class="legend-item"><span class="badge protected">Protected</span> Requires valid JWT token</div>
                <div class="legend-item"><span class="badge admin">Admin</span> Requires admin role</div>
            </div>

            <!-- Auth Section -->
            <div class="section">
                <h2 class="section-title">🔐 Authentication API</h2>

                <div class="endpoint">
                    <div>
                        <span class="method post">POST</span>
                        <span class="path">/api/auth/register</span>
                        <span class="badge public">Public</span>
                    </div>
                    <div class="description">Register a new user account</div>
                    <div class="params">
                        <div class="param">
                            <span class="param-name">name</span>
                            <span class="param-type">string</span>
                            <span class="param-desc">User's full name (required)</span>
                        </div>
                        <div class="param">
                            <span class="param-name">phone</span>
                            <span class="param-type">string</span>
                            <span class="param-desc">Phone number, must be unique (required)</span>
                        </div>
                        <div class="param">
                            <span class="param-name">password</span>
                            <span class="param-type">string</span>
                            <span class="param-desc">Password (required)</span>
                        </div>
                        <div class="param">
                            <span class="param-name">role</span>
                            <span class="param-type">string</span>
                            <span class="param-desc">User role: "admin" or "customer" (default: "customer")</span>
                        </div>
                    </div>
                    <div class="example">
                        <div class="example-title">Request</div>
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "phone": "0555123456",
    "password": "secret123",
    "role": "customer"
  }'
                    </div>
                    <div class="response">
                        <div class="example-title">Response</div>
{
  "message": "User registered successfully",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "phone": "0555123456",
    "role": "customer"
  }
}
                    </div>
                </div>

                <div class="endpoint">
                    <div>
                        <span class="method post">POST</span>
                        <span class="path">/api/auth/login</span>
                        <span class="badge public">Public</span>
                    </div>
                    <div class="description">Login with phone and password</div>
                    <div class="params">
                        <div class="param">
                            <span class="param-name">phone</span>
                            <span class="param-type">string</span>
                            <span class="param-desc">Phone number (required)</span>
                        </div>
                        <div class="param">
                            <span class="param-name">password</span>
                            <span class="param-type">string</span>
                            <span class="param-desc">Password (required)</span>
                        </div>
                    </div>
                    <div class="example">
                        <div class="example-title">Request</div>
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "0555123456",
    "password": "secret123"
  }'
                    </div>
                    <div class="response">
                        <div class="example-title">Response</div>
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "phone": "0555123456",
    "role": "customer"
  }
}
                    </div>
                </div>

                <div class="endpoint protected">
                    <div>
                        <span class="method get">GET</span>
                        <span class="path">/api/auth/me</span>
                        <span class="badge protected">Protected</span>
                    </div>
                    <div class="description">Get current authenticated user's information</div>
                    <div class="example">
                        <div class="example-title">Request</div>
curl http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
                    </div>
                    <div class="response">
                        <div class="example-title">Response</div>
{
  "id": 1,
  "name": "John Doe",
  "phone": "0555123456",
  "role": "customer"
}
                    </div>
                </div>

                <div class="endpoint protected">
                    <div>
                        <span class="method post">POST</span>
                        <span class="path">/api/auth/refresh</span>
                        <span class="badge protected">Protected</span>
                    </div>
                    <div class="description">Refresh JWT token (get a new token before current one expires)</div>
                    <div class="example">
                        <div class="example-title">Request</div>
curl -X POST http://localhost:8080/api/auth/refresh \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
                    </div>
                    <div class="response">
                        <div class="example-title">Response</div>
{
  "message": "Token refreshed",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
                    </div>
                </div>

                <div class="endpoint protected">
                    <div>
                        <span class="method put">PUT</span>
                        <span class="path">/api/auth/change-password</span>
                        <span class="badge protected">Protected</span>
                    </div>
                    <div class="description">Change the current user's password</div>
                    <div class="params">
                        <div class="param">
                            <span class="param-name">currentPassword</span>
                            <span class="param-type">string</span>
                            <span class="param-desc">Current password (required)</span>
                        </div>
                        <div class="param">
                            <span class="param-name">newPassword</span>
                            <span class="param-type">string</span>
                            <span class="param-desc">New password (required)</span>
                        </div>
                    </div>
                    <div class="example">
                        <div class="example-title">Request</div>
curl -X PUT http://localhost:8080/api/auth/change-password \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "currentPassword": "secret123",
    "newPassword": "newSecret456"
  }'
                    </div>
                    <div class="response">
                        <div class="example-title">Response</div>
{
  "message": "Password changed successfully"
}
                    </div>
                </div>
            </div>

            <!-- Dishes Section -->
            <div class="section">
                <h2 class="section-title">🍕 Dishes API</h2>

                <div class="endpoint">
                    <div>
                        <span class="method get">GET</span>
                        <span class="path">/api/dishes</span>
                        <span class="badge public">Public</span>
                    </div>
                    <div class="description">Get all dishes</div>
                    <div class="example">
                        <div class="example-title">Request</div>
                        curl http://localhost:8080/api/dishes
                    </div>
                    <div class="response">
                        <div class="example-title">Response</div>
[
  {
    "id": 1,
    "name": "Pizza Margherita",
    "photoUrl": "https://example.com/pizza.jpg",
    "price": 12.99
  }
]
                    </div>
                </div>

                <div class="endpoint">
                    <div>
                        <span class="method get">GET</span>
                        <span class="path">/api/dishes/{id}</span>
                        <span class="badge public">Public</span>
                    </div>
                    <div class="description">Get a specific dish by ID</div>
                    <div class="params">
                        <div class="param">
                            <span class="param-name">id</span>
                            <span class="param-type">integer</span>
                            <span class="param-desc">Dish ID (path parameter)</span>
                        </div>
                    </div>
                    <div class="example">
                        <div class="example-title">Request</div>
                        curl http://localhost:8080/api/dishes/1
                    </div>
                </div>

                <div class="endpoint admin-only">
                    <div>
                        <span class="method post">POST</span>
                        <span class="path">/api/dishes</span>
                        <span class="badge admin">Admin</span>
                    </div>
                    <div class="description">Create a new dish (admin only)</div>
                    <div class="params">
                        <div class="param">
                            <span class="param-name">name</span>
                            <span class="param-type">string</span>
                            <span class="param-desc">Dish name (required)</span>
                        </div>
                        <div class="param">
                            <span class="param-name">photoUrl</span>
                            <span class="param-type">string</span>
                            <span class="param-desc">Photo URL (required)</span>
                        </div>
                        <div class="param">
                            <span class="param-name">price</span>
                            <span class="param-type">number</span>
                            <span class="param-desc">Price (required)</span>
                        </div>
                    </div>
                    <div class="example">
                        <div class="example-title">Request</div>
curl -X POST http://localhost:8080/api/dishes \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Burger",
    "photoUrl": "https://example.com/burger.jpg",
    "price": 9.99
  }'
                    </div>
                </div>

                <div class="endpoint admin-only">
                    <div>
                        <span class="method put">PUT</span>
                        <span class="path">/api/dishes/{id}</span>
                        <span class="badge admin">Admin</span>
                    </div>
                    <div class="description">Update an existing dish (admin only)</div>
                    <div class="params">
                        <div class="param">
                            <span class="param-name">id</span>
                            <span class="param-type">integer</span>
                            <span class="param-desc">Dish ID (path parameter)</span>
                        </div>
                        <div class="param">
                            <span class="param-name">name</span>
                            <span class="param-type">string</span>
                            <span class="param-desc">Dish name</span>
                        </div>
                        <div class="param">
                            <span class="param-name">photoUrl</span>
                            <span class="param-type">string</span>
                            <span class="param-desc">Photo URL</span>
                        </div>
                        <div class="param">
                            <span class="param-name">price</span>
                            <span class="param-type">number</span>
                            <span class="param-desc">Price</span>
                        </div>
                    </div>
                    <div class="example">
                        <div class="example-title">Request</div>
curl -X PUT http://localhost:8080/api/dishes/1 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Pizza",
    "photoUrl": "https://example.com/pizza2.jpg",
    "price": 14.99
  }'
                    </div>
                </div>

                <div class="endpoint admin-only">
                    <div>
                        <span class="method delete">DELETE</span>
                        <span class="path">/api/dishes/{id}</span>
                        <span class="badge admin">Admin</span>
                    </div>
                    <div class="description">Delete a dish (admin only)</div>
                    <div class="params">
                        <div class="param">
                            <span class="param-name">id</span>
                            <span class="param-type">integer</span>
                            <span class="param-desc">Dish ID (path parameter)</span>
                        </div>
                    </div>
                    <div class="example">
                        <div class="example-title">Request</div>
curl -X DELETE http://localhost:8080/api/dishes/1 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
                    </div>
                </div>
            </div>

            <!-- Orders Section -->
            <div class="section">
                <h2 class="section-title">📦 Orders API</h2>

                <div class="endpoint protected">
                    <div>
                        <span class="method get">GET</span>
                        <span class="path">/api/orders</span>
                        <span class="badge protected">Protected</span>
                    </div>
                    <div class="description">Get all orders (requires authentication)</div>
                    <div class="example">
                        <div class="example-title">Request</div>
curl http://localhost:8080/api/orders \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
                    </div>
                    <div class="response">
                        <div class="example-title">Response</div>
[
  {
    "id": 1,
    "userId": 2,
    "phone": "0987654321",
    "dishId": "1",
    "latitude": 40.7128,
    "longitude": -74.0060,
    "address": "123 Main St, New York, NY",
    "completed": false
  }
]
                    </div>
                </div>

                <div class="endpoint protected">
                    <div>
                        <span class="method get">GET</span>
                        <span class="path">/api/orders/{id}</span>
                        <span class="badge protected">Protected</span>
                    </div>
                    <div class="description">Get a specific order by ID</div>
                    <div class="params">
                        <div class="param">
                            <span class="param-name">id</span>
                            <span class="param-type">integer</span>
                            <span class="param-desc">Order ID (path parameter)</span>
                        </div>
                    </div>
                </div>

                <div class="endpoint protected">
                    <div>
                        <span class="method post">POST</span>
                        <span class="path">/api/orders</span>
                        <span class="badge protected">Protected</span>
                    </div>
                    <div class="description">Create a new order</div>
                    <div class="params">
                        <div class="param">
                            <span class="param-name">userId</span>
                            <span class="param-type">integer?</span>
                            <span class="param-desc">User ID (optional)</span>
                        </div>
                        <div class="param">
                            <span class="param-name">phone</span>
                            <span class="param-type">string</span>
                            <span class="param-desc">Phone number (required)</span>
                        </div>
                        <div class="param">
                            <span class="param-name">dishId</span>
                            <span class="param-type">string</span>
                            <span class="param-desc">Dish ID (required)</span>
                        </div>
                        <div class="param">
                            <span class="param-name">latitude</span>
                            <span class="param-type">number</span>
                            <span class="param-desc">Latitude (required)</span>
                        </div>
                        <div class="param">
                            <span class="param-name">longitude</span>
                            <span class="param-type">number</span>
                            <span class="param-desc">Longitude (required)</span>
                        </div>
                        <div class="param">
                            <span class="param-name">address</span>
                            <span class="param-type">string</span>
                            <span class="param-desc">Delivery address (required)</span>
                        </div>
                        <div class="param">
                            <span class="param-name">completed</span>
                            <span class="param-type">boolean</span>
                            <span class="param-desc">Completion status (default: false)</span>
                        </div>
                    </div>
                    <div class="example">
                        <div class="example-title">Request</div>
curl -X POST http://localhost:8080/api/orders \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "phone": "1234567890",
    "dishId": "1",
    "latitude": 40.7128,
    "longitude": -74.0060,
    "address": "123 Main St",
    "completed": false
  }'
                    </div>
                </div>

                <div class="endpoint protected">
                    <div>
                        <span class="method put">PUT</span>
                        <span class="path">/api/orders/{id}</span>
                        <span class="badge protected">Protected</span>
                    </div>
                    <div class="description">Update an existing order</div>
                </div>

                <div class="endpoint protected">
                    <div>
                        <span class="method delete">DELETE</span>
                        <span class="path">/api/orders/{id}</span>
                        <span class="badge protected">Protected</span>
                    </div>
                    <div class="description">Delete an order</div>
                </div>
            </div>

            <!-- Users Section -->
            <div class="section">
                <h2 class="section-title">👥 Users API</h2>

                <div class="endpoint admin-only">
                    <div>
                        <span class="method get">GET</span>
                        <span class="path">/api/users</span>
                        <span class="badge admin">Admin</span>
                    </div>
                    <div class="description">Get all users (admin only)</div>
                    <div class="example">
                        <div class="example-title">Request</div>
curl http://localhost:8080/api/users \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
                    </div>
                    <div class="response">
                        <div class="example-title">Response</div>
[
  {
    "id": 1,
    "name": "Admin User",
    "phone": "1234567890",
    "role": "admin"
  }
]
                    </div>
                </div>

                <div class="endpoint admin-only">
                    <div>
                        <span class="method get">GET</span>
                        <span class="path">/api/users/{id}</span>
                        <span class="badge admin">Admin</span>
                    </div>
                    <div class="description">Get a specific user by ID (admin only)</div>
                </div>

                <div class="endpoint admin-only">
                    <div>
                        <span class="method post">POST</span>
                        <span class="path">/api/users</span>
                        <span class="badge admin">Admin</span>
                    </div>
                    <div class="description">Create a new user (admin only)</div>
                    <div class="params">
                        <div class="param">
                            <span class="param-name">name</span>
                            <span class="param-type">string</span>
                            <span class="param-desc">User name (required)</span>
                        </div>
                        <div class="param">
                            <span class="param-name">phone</span>
                            <span class="param-type">string</span>
                            <span class="param-desc">Phone number, must be unique (required)</span>
                        </div>
                        <div class="param">
                            <span class="param-name">password</span>
                            <span class="param-type">string?</span>
                            <span class="param-desc">Password (optional)</span>
                        </div>
                        <div class="param">
                            <span class="param-name">role</span>
                            <span class="param-type">string</span>
                            <span class="param-desc">User role: "admin" or "customer" (required)</span>
                        </div>
                    </div>
                    <div class="example">
                        <div class="example-title">Request</div>
curl -X POST http://localhost:8080/api/users \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "phone": "5551234567",
    "password": "secret123",
    "role": "customer"
  }'
                    </div>
                </div>

                <div class="endpoint admin-only">
                    <div>
                        <span class="method put">PUT</span>
                        <span class="path">/api/users/{id}</span>
                        <span class="badge admin">Admin</span>
                    </div>
                    <div class="description">Update an existing user (admin only)</div>
                </div>

                <div class="endpoint admin-only">
                    <div>
                        <span class="method delete">DELETE</span>
                        <span class="path">/api/users/{id}</span>
                        <span class="badge admin">Admin</span>
                    </div>
                    <div class="description">Delete a user (admin only)</div>
                </div>
            </div>

            <!-- Health Check -->
            <div class="section">
                <h2 class="section-title">💚 Health Check</h2>

                <div class="endpoint">
                    <div>
                        <span class="method get">GET</span>
                        <span class="path">/health</span>
                        <span class="badge public">Public</span>
                    </div>
                    <div class="description">Check if the server is running</div>
                    <div class="example">
                        <div class="example-title">Request</div>
                        curl http://localhost:8080/health
                    </div>
                    <div class="response">
                        <div class="example-title">Response</div>
Server is running
                    </div>
                </div>
            </div>

            <!-- Token Info -->
            <div class="section">
                <h2 class="section-title">ℹ️ Token Information</h2>
                <div class="info-box">
                    <strong>Token Expiry:</strong> Tokens expire after 24 hours<br>
                    <strong>Algorithm:</strong> HS256<br>
                    <strong>Token Payload:</strong> Contains userId, phone, and role<br>
                    <strong>Refresh:</strong> Use /api/auth/refresh to get a new token before expiry
                </div>
            </div>
        </div>
    </div>
</body>
</html>
''';



