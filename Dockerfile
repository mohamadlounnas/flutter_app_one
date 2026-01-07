# Server-only Dockerfile (no Flutter web build)
FROM dart:stable AS server_build

# Set working directory
WORKDIR /app

# Copy server pubspec files
COPY server/pubspec.yaml server/pubspec.lock ./server/

# Copy lib files from parent project (needed for server's path dependency)
COPY lib ./lib/

# Create a minimal pubspec.yaml for the parent project (without Flutter dependencies)
# This allows the server's path dependency to resolve correctly
RUN printf 'name: flutter_one\nversion: 0.1.0+1\npublish_to: none\nenvironment:\n  sdk: ^3.10.0\n' > pubspec.yaml

# Copy server source files
COPY server/lib ./server/lib/
COPY server/bin ./server/bin/

# Get dependencies for server (which depends on parent via path)
WORKDIR /app/server
RUN dart pub get

# Build the server executable
RUN dart compile exe bin/server.dart -o bin/server

# Create runtime image
FROM debian:bookworm-slim

# Install required runtime dependencies including SQLite
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    libsqlite3-0 \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/* && \
    ldconfig

# Set working directory
WORKDIR /app

# Copy the compiled server executable
COPY --from=server_build /app/server/bin/server ./bin/

# Create data directory for SQLite database
RUN mkdir -p data

# Expose port
EXPOSE 8080

# Set environment variables
ENV PORT=8080
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

# Run the server
CMD ["./bin/server"]

