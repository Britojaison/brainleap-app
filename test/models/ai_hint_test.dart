import 'package:flutter_test/flutter_test.dart';
import 'package:brainleap/models/ai_hint.dart';

void main() {
  group('AiHint Model Tests', () {
    test('should create AiHint from JSON with all fields', () {
      // Arrange
      final json = {
        'title': 'Test Hint',
        'explanation': 'This is a test explanation',
        'nextSteps': ['Step 1', 'Step 2', 'Step 3'],
      };

      // Act
      final hint = AiHint.fromJson(json);

      // Assert
      expect(hint.title, 'Test Hint');
      expect(hint.explanation, 'This is a test explanation');
      expect(hint.nextSteps, ['Step 1', 'Step 2', 'Step 3']);
    });

    test('should handle missing title with default value', () {
      // Arrange
      final json = {
        'explanation': 'Explanation without title',
      };

      // Act
      final hint = AiHint.fromJson(json);

      // Assert
      expect(hint.title, 'Hint');
      expect(hint.explanation, 'Explanation without title');
    });

    test('should handle missing explanation with default value', () {
      // Arrange
      final json = {
        'title': 'Title Only',
      };

      // Act
      final hint = AiHint.fromJson(json);

      // Assert
      expect(hint.title, 'Title Only');
      expect(hint.explanation, 'No explanation provided.');
    });

    test('should handle null nextSteps with empty list', () {
      // Arrange
      final json = {
        'title': 'No Steps',
        'explanation': 'No next steps provided',
        'nextSteps': null,
      };

      // Act
      final hint = AiHint.fromJson(json);

      // Assert
      expect(hint.nextSteps, isEmpty);
    });

    test('should filter out non-string items from nextSteps', () {
      // Arrange
      final json = {
        'title': 'Mixed Steps',
        'explanation': 'Steps with mixed types',
        'nextSteps': ['Valid Step', 123, 'Another Valid', null, 'Last Valid'],
      };

      // Act
      final hint = AiHint.fromJson(json);

      // Assert
      expect(hint.nextSteps.length, 3);
      expect(hint.nextSteps, ['Valid Step', 'Another Valid', 'Last Valid']);
    });

    test('should create AiHint with const constructor', () {
      // Arrange & Act
      const hint = AiHint(
        title: 'Const Hint',
        explanation: 'Const explanation',
        nextSteps: ['Step 1', 'Step 2'],
      );

      // Assert
      expect(hint.title, 'Const Hint');
      expect(hint.explanation, 'Const explanation');
      expect(hint.nextSteps, ['Step 1', 'Step 2']);
    });

    test('should create AiHint with default empty nextSteps', () {
      // Arrange & Act
      const hint = AiHint(
        title: 'No Steps',
        explanation: 'Explanation only',
      );

      // Assert
      expect(hint.nextSteps, isEmpty);
    });
  });
}

