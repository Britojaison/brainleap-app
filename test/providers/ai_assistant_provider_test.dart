import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:brainleap/providers/ai_assistant_provider.dart';
import 'package:brainleap/services/api_service.dart';
import 'package:brainleap/models/ai_hint.dart';

// Generate mocks
@GenerateMocks([ApiService])
import 'ai_assistant_provider_test.mocks.dart';

void main() {
  group('AiAssistantProvider Tests', () {
    late AiAssistantProvider provider;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      provider = AiAssistantProvider(apiService: mockApiService);
    });

    tearDown(() {
      provider.dispose();
    });

    test('initial state should have default values', () {
      // Assert
      expect(provider.isLoading, false);
      expect(provider.hint, null);
      expect(provider.errorMessage, null);
    });

    test('fetchHint should update state with hint on success', () async {
      // Arrange
      final mockResponse = {
        'title': 'Test Hint',
        'explanation': 'Test explanation',
        'nextSteps': ['Step 1', 'Step 2'],
      };
      when(mockApiService.requestAiHint(
        questionId: 'q123',
        canvasState: 'canvas-data',
      )).thenAnswer((_) async => mockResponse);

      // Act
      await provider.fetchHint(
        questionId: 'q123',
        canvasState: 'canvas-data',
      );

      // Assert
      expect(provider.isLoading, false);
      expect(provider.hint, isNotNull);
      expect(provider.hint!.title, 'Test Hint');
      expect(provider.hint!.explanation, 'Test explanation');
      expect(provider.errorMessage, null);
      verify(mockApiService.requestAiHint(
        questionId: 'q123',
        canvasState: 'canvas-data',
      )).called(1);
    });

    test('fetchHint should update state with error on failure', () async {
      // Arrange
      when(mockApiService.requestAiHint(
        questionId: 'q123',
        canvasState: 'canvas-data',
      )).thenThrow(Exception('Network error'));

      // Act
      await provider.fetchHint(
        questionId: 'q123',
        canvasState: 'canvas-data',
      );

      // Assert
      expect(provider.isLoading, false);
      expect(provider.hint, null);
      expect(provider.errorMessage, 'Unable to fetch hint. Please try again.');
    });

    test('evaluateAnswer should update state with evaluation on success', () async {
      // Arrange
      final mockResponse = {
        'title': 'Evaluation',
        'explanation': 'Your answer is correct',
        'nextSteps': [],
      };
      when(mockApiService.evaluateCanvasAnswer(
        questionId: 'q456',
        canvasState: 'answer-data',
      )).thenAnswer((_) async => mockResponse);

      // Act
      await provider.evaluateAnswer(
        questionId: 'q456',
        canvasState: 'answer-data',
      );

      // Assert
      expect(provider.isLoading, false);
      expect(provider.hint, isNotNull);
      expect(provider.hint!.title, 'Evaluation');
      expect(provider.hint!.explanation, 'Your answer is correct');
      expect(provider.errorMessage, null);
    });

    test('evaluateAnswer should update state with error on failure', () async {
      // Arrange
      when(mockApiService.evaluateCanvasAnswer(
        questionId: 'q456',
        canvasState: 'answer-data',
      )).thenThrow(Exception('Evaluation failed'));

      // Act
      await provider.evaluateAnswer(
        questionId: 'q456',
        canvasState: 'answer-data',
      );

      // Assert
      expect(provider.isLoading, false);
      expect(provider.hint, null);
      expect(provider.errorMessage, 'Evaluation failed. Please retry after saving your work.');
    });

    test('clearHint should reset hint and error', () async {
      // Arrange - set up some state first
      final mockResponse = {
        'title': 'Test',
        'explanation': 'Test',
      };
      when(mockApiService.requestAiHint(
        questionId: 'q1',
        canvasState: 'data',
      )).thenAnswer((_) async => mockResponse);
      await provider.fetchHint(questionId: 'q1', canvasState: 'data');

      // Act
      provider.clearHint();

      // Assert
      expect(provider.hint, null);
      expect(provider.errorMessage, null);
    });

    test('should notify listeners when state changes', () async {
      // Arrange
      final mockResponse = {'title': 'Test', 'explanation': 'Test'};
      when(mockApiService.requestAiHint(
        questionId: 'q1',
        canvasState: 'data',
      )).thenAnswer((_) async => mockResponse);

      var notificationCount = 0;
      provider.addListener(() {
        notificationCount++;
      });

      // Act
      await provider.fetchHint(questionId: 'q1', canvasState: 'data');

      // Assert
      expect(notificationCount, greaterThan(0));
    });
  });
}

