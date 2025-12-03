import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../constants.dart';
import '../errors/exceptions.dart';

/// HTTP client for API communication
class ApiClient {
  final String baseUrl;
  final http.Client _client;
  String? _token;

  ApiClient({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? ApiConstants.baseUrl,
        _client = client ?? http.Client();

  /// Set authentication token
  void setToken(String? token) {
    _token = token;
  }

  /// Get current token
  String? get token => _token;

  /// Clear token
  void clearToken() {
    _token = null;
  }

  /// Build headers with optional authentication
  Map<String, String> _headers({bool requireAuth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    } else if (requireAuth) {
      throw const AuthException('No authentication token available');
    }

    return headers;
  }

  /// Handle response and throw appropriate exceptions
  dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 400:
        throw ValidationException(
          body?['error'] ?? 'Bad request',
          fieldErrors: body?['errors'] != null
              ? Map<String, String>.from(body['errors'])
              : null,
        );
      case 401:
        throw AuthException(body?['error'] ?? 'Unauthorized');
      case 403:
        throw AuthException(body?['error'] ?? 'Forbidden');
      case 404:
        throw NotFoundException(body?['error'] ?? 'Not found');
      case 409:
        throw ValidationException(body?['error'] ?? 'Conflict');
      case 500:
      case 502:
      case 503:
        throw ServerException(body?['error'] ?? 'Server error');
      default:
        throw NetworkException(
          body?['error'] ?? 'Unknown error',
          statusCode: response.statusCode,
        );
    }
  }

  /// GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requireAuth = false,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await _client.get(
        uri,
        headers: _headers(requireAuth: requireAuth),
      );

      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error: ${e.toString()}', originalError: e);
    }
  }

  /// POST request
  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    bool requireAuth = false,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers(requireAuth: requireAuth),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error: ${e.toString()}', originalError: e);
    }
  }

  /// PUT request
  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    bool requireAuth = false,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers(requireAuth: requireAuth),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error: ${e.toString()}', originalError: e);
    }
  }

  /// PATCH request
  Future<dynamic> patch(
    String endpoint, {
    dynamic body,
    bool requireAuth = false,
  }) async {
    try {
      final response = await _client.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers(requireAuth: requireAuth),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error: ${e.toString()}', originalError: e);
    }
  }

  /// DELETE request
  Future<dynamic> delete(
    String endpoint, {
    bool requireAuth = false,
  }) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers(requireAuth: requireAuth),
      );

      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error: ${e.toString()}', originalError: e);
    }
  }

  /// Multipart POST for file uploads
  Future<dynamic> uploadFile(
    String endpoint, {
    required String field,
    required String filePath,
    required String fileName,
    Map<String, String>? fields,
    bool requireAuth = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      final headers = _headers(requireAuth: requireAuth);
      headers.remove('Content-Type'); // Let multipart set its own content type
      request.headers.addAll(headers);

      // Add file
      request.files.add(await http.MultipartFile.fromPath(field, filePath, filename: fileName));

      // Add additional fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Upload error: ${e.toString()}', originalError: e);
    }
  }

  /// Upload file from bytes
  Future<dynamic> uploadFileBytes(
    String endpoint, {
    required String field,
    required List<int> bytes,
    required String fileName,
    required String contentType,
    Map<String, String>? fields,
    bool requireAuth = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      final headers = _headers(requireAuth: requireAuth);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      // Add file from bytes
      request.files.add(http.MultipartFile.fromBytes(
        field,
        bytes,
        filename: fileName,
        contentType: MediaType.parse(contentType),
      ));

      // Add additional fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Upload error: ${e.toString()}', originalError: e);
    }
  }

  /// Close the client
  void dispose() {
    _client.close();
  }
}
