import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:brainleap/services/api_service.dart';

@GenerateMocks([http.Client])
import 'api_service_test.mocks.dart';

void main() {
  group('ApiService Tests', () {
    late ApiService apiService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      apiService = ApiService(client: mockClient);
    });

    group('login', () {
      test('should return response on successful login', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"token": "test-token", "user": {"id": "123", "email": "test@example.com"}}',
          200,
        );
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final response = await apiService.login(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(response.statusCode, 200);
        expect(response.body, contains('test-token'));
      });

      test('should throw ApiException on network error', () async {
        // Arrange
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => apiService.login(email: 'test@example.com', password: 'pass'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('register', () {
      test('should return response on successful registration', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"token": "new-token", "user": {"id": "456", "email": "new@example.com"}}',
          201,
        );
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final response = await apiService.register(
          email: 'new@example.com',
          password: 'password123',
        );

        // Assert
        expect(response.statusCode, 201);
        expect(response.body, contains('new-token'));
      });
    });

    group('requestAiHint', () {
      test('should return hint data on success', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"data": {"title": "Hint", "explanation": "Test hint"}}',
          200,
        );
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final hint = await apiService.requestAiHint(
          questionId: 'q123',
          canvasState: 'canvas-data',
        );

        // Assert
        expect(hint, isNotNull);
        expect(hint['title'], 'Hint');
        expect(hint['explanation'], 'Test hint');
      });

      test('should throw ApiException on 404', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"message": "Not found"}',
          404,
        );
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => apiService.requestAiHint(
            questionId: 'invalid',
            canvasState: 'data',
          ),
          throwsA(isA<ApiException>()),
        );
      });

      test('should include auth token in headers when provided', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"data": {"title": "Hint", "explanation": "Test"}}',
          200,
        );
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        await apiService.requestAiHint(
          questionId: 'q123',
          canvasState: 'data',
          authToken: 'test-token',
        );

        // Assert
        verify(mockClient.post(
          any,
          headers: argThat(
            contains('Authorization'),
            named: 'headers',
          ),
          body: anyNamed('body'),
        )).called(1);
      });
    });

    group('evaluateCanvasAnswer', () {
      test('should return evaluation data on success', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"data": {"title": "Evaluation", "explanation": "Correct answer"}}',
          200,
        );
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final evaluation = await apiService.evaluateCanvasAnswer(
          questionId: 'q456',
          canvasState: 'answer-data',
        );

        // Assert
        expect(evaluation, isNotNull);
        expect(evaluation['title'], 'Evaluation');
        expect(evaluation['explanation'], 'Correct answer');
      });

      test('should throw ApiException on server error', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"message": "Internal server error"}',
          500,
        );
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => apiService.evaluateCanvasAnswer(
            questionId: 'q456',
            canvasState: 'data',
          ),
          throwsA(isA<ApiException>()),
        );
      });
    });
  });
}

