import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/environment.dart';
import '../utils/constants.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration _timeout = const Duration(seconds: AppConfig.apiTimeout);
  String? _resolvedBaseUrl;
  Future<void>? _baseResolutionFuture;

  Future<void> _ensureBaseUrl() async {
    if (_resolvedBaseUrl != null) return;
    _baseResolutionFuture ??= _resolveBaseUrl();
    await _baseResolutionFuture;
  }

  Future<void> _resolveBaseUrl() async {
    final candidates = Environment.backendBaseUrls;
    print('🔍 ApiService: Testing backend URLs: ${candidates.join(', ')}');

    for (final base in candidates) {
      try {
        print('🔗 ApiService: Trying $base/health');
        final uri = Uri.parse(base);
        final healthUri = uri.replace(path: '${uri.path}/health');
        final response = await _client
            .get(healthUri)
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          print('✅ ApiService: Found working backend at $base');
          _resolvedBaseUrl = base;
          return;
        } else {
          print('⚠️ ApiService: $base/health returned status ${response.statusCode}');
        }
      } catch (e) {
        print('❌ ApiService: Failed to connect to $base: $e');
        // ignore and try next candidate
      }
    }
    throw Exception('Unable to reach backend at any configured address (${candidates.join(', ')}). Please check your network connection and ensure the backend server is running.');
  }

  Uri _buildUri(String path, [Map<String, dynamic>? query]) {
    final base = _resolvedBaseUrl ?? Environment.backendBaseUrl;
    final uri = Uri.parse(base);
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return uri.replace(
      path: normalizedPath,
      queryParameters: query,
    );
  }

  String _parseErrorResponse(int statusCode, String body) {
    try {
      final parsed = jsonDecode(body);
      if (parsed is Map<String, dynamic>) {
        final message = parsed['message'] ?? parsed['error'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    } catch (_) {
      // ignore parsing failures
    }
    return 'Request failed with status $statusCode.';
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    await _ensureBaseUrl();
    try {
      final response = await _client
          .post(
            _buildUri(path),
            headers: {
              'Content-Type': 'application/json',
              if (headers != null) ...headers,
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      throw Exception(_parseErrorResponse(response.statusCode, response.body));
    } on TimeoutException {
      throw Exception('Request to $path timed out. Please check your connection.');
    }
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    await _ensureBaseUrl();
    try {
      final response = await _client
          .get(
            _buildUri(path, query),
            headers: headers,
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      throw Exception(_parseErrorResponse(response.statusCode, response.body));
    } on TimeoutException {
      throw Exception('Request to $path timed out. Please check your connection.');
    }
  }

  Future<Map<String, dynamic>> uploadImage(
    String path,
    Uint8List bytes,
    String fileName, {
    Map<String, String>? headers,
  }) async {
    await _ensureBaseUrl();
    try {
      final request = http.MultipartRequest('POST', _buildUri(path));
      if (headers != null) {
        request.headers.addAll(headers);
      }
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      final streamed = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception(_parseErrorResponse(response.statusCode, response.body));
    } on TimeoutException {
      throw Exception('Upload to $path timed out. Please check your connection.');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return postJson('/api/auth/login', {
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    return postJson('/api/auth/register', {
      'email': email,
      'password': password,
    });
  }

  Future<String> extractQuestion(Uint8List bytes) async {
    final response = await postJson(
      '/api/vision/extract',
      {
        'imageBase64': base64Encode(bytes),
        'mimeType': 'image/jpeg',
      },
    );
    final data = response['data'] as Map<String, dynamic>?;
    return (data?['text'] as String? ?? '').trim();
  }

  Future<Map<String, dynamic>> submitPractice({
    required String question,
    required Map<String, dynamic> canvas,
    String? userId,
    String? authToken,
  }) async {
    return postJson(
      '/api/practice',
      {
        if (userId != null) 'userId': userId,
        'question': question,
        'canvas': canvas,
      },
      headers: {
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      },
    );
  }

  Future<Map<String, dynamic>> requestAiHint({
    required String questionId,
    required String canvasState,
  }) async {
    final response = await postJson('/api/ai/hints', {
      'questionId': questionId,
      'canvasState': canvasState,
    });
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    throw Exception(response['message'] ?? 'AI hint request failed');
  }

  Future<Map<String, dynamic>> evaluateCanvasAnswer({
    required String questionId,
    required String canvasState,
  }) async {
    final response = await postJson('/api/ai/evaluate', {
      'questionId': questionId,
      'canvasState': canvasState,
    });
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    throw Exception(response['message'] ?? 'AI evaluation failed');
  }
}
