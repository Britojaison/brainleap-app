import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/environment.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<http.Response> login({required String email, required String password}) async {
    final uri = Uri.parse('${Environment.backendBaseUrl}/auth/login');
    return _client.post(uri, body: {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>> requestAiHint({required String questionId, required String canvasState}) async {
    final uri = Uri.parse('${Environment.backendBaseUrl}/ai/hints/$questionId');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'canvasState': canvasState}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> evaluateCanvasAnswer({required String questionId, required String canvasState}) async {
    final uri = Uri.parse('${Environment.backendBaseUrl}/ai/evaluate/$questionId');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'canvasState': canvasState}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
