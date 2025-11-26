# Use Flutter image for building web app, then Dart for server
FROM ghcr.io/cirruslabs/flutter:stable AS flutter_build

WORKDIR /app

# Copy Flutter project files
COPY pubspec.yaml pubspec.lock ./
COPY lib ./lib/
COPY web ./web/

# Get Flutter dependencies
RUN flutter pub get

# Build Flutter web app with base href /flutter/
RUN flutter build web --base-href /flutter/ --release

# Use Dart image for server build
FROM dart:stable AS server_build

# Set working directory
WORKDIR /app

# Copy Flutter web build from previous stage
COPY --from=flutter_build /app/build/web ./flutter_web/

# Copy server pubspec files
COPY server/pubspec.yaml server/pubspec.lock ./server/

# Copy lib files from parent project (needed for server's path dependency)
COPY lib ./lib/

# Create a minimal pubspec.yaml for the parent project (without Flutter dependencies)
# This allows the server's path dependency to resolve correctly
# Must be created BEFORE running dart pub get
RUN cat > pubspec.yaml << 'EOF'
name: flutter_one
version: 0.1.0+1
publish_to: none
environment:
  sdk: ^3.10.0
EOF

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

# Install required runtime dependencies including SQLite dev package
# The dev package provides the unversioned libsqlite3.so symlink
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    libsqlite3-0 \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/* && \
    # Update library cache
    ldconfig && \
    # Verify SQLite library is accessible
    ls -la /usr/lib/x86_64-linux-gnu/libsqlite3.so* || \
    ls -la /lib/x86_64-linux-gnu/libsqlite3.so* || true

# Set working directory
WORKDIR /app

# Copy the compiled server executable
COPY --from=server_build /app/server/bin/server ./bin/

# Copy server lib files
COPY --from=server_build /app/server/lib ./lib/

# Copy parent lib files (for flutter_one package)
COPY --from=server_build /app/lib ./../lib/

# Copy Flutter web build
COPY --from=server_build /app/flutter_web ./flutter_web/

# Create data directory for SQLite database
RUN mkdir -p data

# Expose port
EXPOSE 8080

# Set environment variables
ENV PORT=8080
# Ensure SQLite library can be found
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

# Run the server
CMD ["./bin/server"]

