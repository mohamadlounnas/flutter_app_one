# Use official Dart image
# Updated for Railway deployment with stable SDK
FROM dart:stable AS build

# Set working directory
WORKDIR /app

# Copy server pubspec files first
COPY server/pubspec.yaml server/pubspec.lock ./server/

# Copy only the lib directory (models) from parent project
# We don't need Flutter dependencies, just the model files
COPY lib ./lib/

# Copy server source files
COPY server/lib ./server/lib/
COPY server/bin ./server/bin/

# Get dependencies for server only
# The server's pubspec.yaml has path dependency to parent, but we only need lib files
WORKDIR /app/server
RUN dart pub get --no-example

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

