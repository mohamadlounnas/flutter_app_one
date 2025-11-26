# Use official Dart image
# Updated for Railway deployment with stable SDK
FROM dart:stable AS build

# Set working directory
WORKDIR /app

# Copy server pubspec files
COPY server/pubspec.yaml server/pubspec.lock ./server/

# Copy lib files from parent project (needed for server's path dependency)
COPY lib ./lib/

# Create a minimal pubspec.yaml for the parent project (without Flutter dependencies)
# This allows the server's path dependency to resolve correctly
RUN echo 'name: flutter_one\nversion: 0.1.0+1\npublish_to: none\nenvironment:\n  sdk: ^3.10.0' > pubspec.yaml

# Copy server source files
COPY server/lib ./server/lib/
COPY server/bin ./server/bin/

# Get dependencies for server (which depends on parent via path)
WORKDIR /app/server
RUN dart pub get

# Build the server executable
WORKDIR /app/server
RUN dart compile exe bin/server.dart -o bin/server

# Create runtime image
FROM debian:bookworm-slim

# Install required runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the compiled server executable
COPY --from=build /app/server/bin/server ./bin/

# Copy server lib files
COPY --from=build /app/server/lib ./lib/

# Copy parent lib files (for flutter_one package)
COPY --from=build /app/lib ./../lib/

# Create data directory for SQLite database
RUN mkdir -p data

# Expose port
EXPOSE 8080

# Set environment variable
ENV PORT=8080

# Run the server
CMD ["./bin/server"]

