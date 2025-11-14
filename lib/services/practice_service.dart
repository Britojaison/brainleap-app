import 'api_service.dart';

class PracticeSubmissionException implements Exception {
  PracticeSubmissionException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class PracticeService {
  PracticeService({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<void> submit({
    required String question,
    required Map<String, dynamic> canvas,
    String? userId,
    String? authToken,
  }) async {
    try {
      final response = await _api.submitPractice(
        question: question,
        canvas: canvas,
        userId: userId,
        authToken: authToken,
      );
      if (response['success'] != true) {
        throw PracticeSubmissionException(
          response['message'] as String? ?? 'Practice submission failed.',
        );
      }
    } catch (error) {
      if (error is PracticeSubmissionException) {
        rethrow;
      }
      throw PracticeSubmissionException('Failed to submit practice: $error');
    }
  }
}
