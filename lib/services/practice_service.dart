import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/environment.dart';
import '../utils/constants.dart';

class PracticeSubmissionException implements Exception {
  PracticeSubmissionException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class PracticeService {
  PracticeService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration _timeout = const Duration(seconds: AppConfig.apiTimeout);

  Future<void> submit(String workJson, {String? authToken}) async {
    final uri = Uri.parse('${Environment.backendBaseUrl}/practice/submit');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };

    try {
      final response = await _client
          .post(
            uri,
            headers: headers,
            body: jsonEncode({
              'work': jsonDecode(workJson),
              'submittedAt': DateTime.now().toUtc().toIso8601String(),
            }),
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }

      throw PracticeSubmissionException(
        'Practice submission failed with status ${response.statusCode}',
        response.statusCode,
      );
    } on PracticeSubmissionException {
      rethrow;
    } on http.ClientException catch (e) {
      throw PracticeSubmissionException('Network error: ${e.message}');
    } on FormatException {
      throw PracticeSubmissionException('Invalid canvas payload provided.');
    } on Exception catch (e) {
      throw PracticeSubmissionException('Failed to submit practice: $e');
    }
  }
}
