# Use official Dart image
# Updated for Railway deployment with stable SDK
FROM dart:stable AS build

# Set working directory
WORKDIR /app

# Copy pubspec files first for better caching
COPY pubspec.yaml pubspec.lock ./
COPY server/pubspec.yaml server/pubspec.lock ./server/

# Get dependencies for root project
RUN dart pub get

# Get dependencies for server (which depends on root)
WORKDIR /app/server
RUN dart pub get

# Copy the entire project (needed for server to import flutter_one package)
WORKDIR /app
COPY lib ./lib/
COPY server ./server/

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

