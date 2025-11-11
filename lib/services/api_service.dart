import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/environment.dart';
import '../utils/constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration _timeout = const Duration(seconds: AppConfig.apiTimeout);

  Map<String, String> _getHeaders({String? authToken}) {
    final headers = {'Content-Type': 'application/json'};
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  Future<http.Response> login({required String email, required String password}) async {
    final uri = Uri.parse('${Environment.backendBaseUrl}/auth/login');
    try {
      return await _client
          .post(
            uri,
            headers: _getHeaders(),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw ApiException('Request timeout. Please check your connection.');
    } on SocketException {
      throw ApiException('No internet connection.');
    } catch (e) {
      throw ApiException('Login failed: ${e.toString()}');
    }
  }

  Future<http.Response> register({required String email, required String password}) async {
    final uri = Uri.parse('${Environment.backendBaseUrl}/auth/register');
    try {
      return await _client
          .post(
            uri,
            headers: _getHeaders(),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw ApiException('Request timeout. Please check your connection.');
    } on SocketException {
      throw ApiException('No internet connection.');
    } catch (e) {
      throw ApiException('Registration failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> requestAiHint({
    required String questionId,
    required String canvasState,
    String? authToken,
  }) async {
    final uri = Uri.parse('${Environment.backendBaseUrl}/ai/hints/$questionId');
    try {
      final response = await _client
          .post(
            uri,
            headers: _getHeaders(authToken: authToken),
            body: jsonEncode({'canvasState': canvasState}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>? ?? data;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException(
          error['message'] as String? ?? 'Failed to fetch hint',
          response.statusCode,
        );
      }
    } on TimeoutException {
      throw ApiException('Request timeout. Please check your connection.');
    } on SocketException {
      throw ApiException('No internet connection.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch hint: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> evaluateCanvasAnswer({
    required String questionId,
    required String canvasState,
    String? authToken,
  }) async {
    final uri = Uri.parse('${Environment.backendBaseUrl}/ai/evaluate/$questionId');
    try {
      final response = await _client
          .post(
            uri,
            headers: _getHeaders(authToken: authToken),
            body: jsonEncode({'canvasState': canvasState}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>? ?? data;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException(
          error['message'] as String? ?? 'Failed to evaluate answer',
          response.statusCode,
        );
      }
    } on TimeoutException {
      throw ApiException('Request timeout. Please check your connection.');
    } on SocketException {
      throw ApiException('No internet connection.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to evaluate answer: ${e.toString()}');
    }
  }
}
