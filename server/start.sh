#!/bin/bash

# Navigate to server directory
cd "$(dirname "$0")"

# Install dependencies if needed
if [ ! -d ".dart_tool" ]; then
  echo "Installing dependencies..."
  dart pub get
fi

# Run the server
echo "Starting server..."
dart run bin/server.dart

