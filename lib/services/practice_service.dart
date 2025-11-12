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

  /// Generate a question based on user selections
  Future<Map<String, dynamic>> generateQuestion({
    required String classLevel,
    required String subject,
    required String curriculum,
    required String topic,
    required String subtopic,
    String? authToken,
  }) async {
    final uri =
        Uri.parse('${Environment.backendBaseUrl}/practice/generate-question');
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
              'classLevel': classLevel,
              'subject': subject,
              'curriculum': curriculum,
              'topic': topic,
              'subtopic': subtopic,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      }

      throw PracticeSubmissionException(
        'Question generation failed with status ${response.statusCode}',
        response.statusCode,
      );
    } on PracticeSubmissionException {
      rethrow;
    } on http.ClientException catch (e) {
      throw PracticeSubmissionException('Network error: ${e.message}');
    } on FormatException {
      throw PracticeSubmissionException('Invalid response from server.');
    } on Exception catch (e) {
      throw PracticeSubmissionException('Failed to generate question: $e');
    }
  }

  /// Submit answer to a generated question
  Future<Map<String, dynamic>> submitAnswer({
    required String questionId,
    required String answerData,
    String? authToken,
  }) async {
    final uri = Uri.parse('${Environment.backendBaseUrl}/practice/submit-answer');
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
              'questionId': questionId,
              'answerData': answerData,
              'submittedAt': DateTime.now().toUtc().toIso8601String(),
            }),
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      }

      throw PracticeSubmissionException(
        'Answer submission failed with status ${response.statusCode}',
        response.statusCode,
      );
    } on PracticeSubmissionException {
      rethrow;
    } on http.ClientException catch (e) {
      throw PracticeSubmissionException('Network error: ${e.message}');
    } on FormatException {
      throw PracticeSubmissionException('Invalid response from server.');
    } on Exception catch (e) {
      throw PracticeSubmissionException('Failed to submit answer: $e');
    }
  }
}
