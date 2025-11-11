import 'package:flutter_test/flutter_test.dart';
import 'package:brainleap/models/topic.dart';

void main() {
  group('Topic Model Tests', () {
    test('should create Topic from JSON with all fields', () {
      // Arrange
      final json = {
        'id': 'topic123',
        'name': 'Algebra',
        'category': 'Mathematics',
        'description': 'Learn algebra basics',
        'iconName': 'math_icon',
        'questionsCount': 10,
        'completedCount': 5,
      };

      // Act
      final topic = Topic.fromJson(json);

      // Assert
      expect(topic.id, 'topic123');
      expect(topic.name, 'Algebra');
      expect(topic.category, 'Mathematics');
      expect(topic.description, 'Learn algebra basics');
      expect(topic.iconName, 'math_icon');
      expect(topic.questionsCount, 10);
      expect(topic.completedCount, 5);
    });

    test('should handle missing optional fields', () {
      // Arrange
      final json = {
        'id': 'topic456',
        'name': 'Geometry',
        'category': 'Mathematics',
      };

      // Act
      final topic = Topic.fromJson(json);

      // Assert
      expect(topic.id, 'topic456');
      expect(topic.name, 'Geometry');
      expect(topic.category, 'Mathematics');
      expect(topic.description, null);
      expect(topic.iconName, null);
      expect(topic.questionsCount, 0);
      expect(topic.completedCount, 0);
    });

    test('should convert Topic to JSON', () {
      // Arrange
      const topic = Topic(
        id: 'topic789',
        name: 'Physics',
        category: 'Science',
        description: 'Learn physics',
        iconName: 'physics_icon',
        questionsCount: 15,
        completedCount: 8,
      );

      // Act
      final json = topic.toJson();

      // Assert
      expect(json['id'], 'topic789');
      expect(json['name'], 'Physics');
      expect(json['category'], 'Science');
      expect(json['description'], 'Learn physics');
      expect(json['iconName'], 'physics_icon');
      expect(json['questionsCount'], 15);
      expect(json['completedCount'], 8);
    });

    test('should calculate progress percentage correctly', () {
      // Arrange
      const topic = Topic(
        id: 'topic1',
        name: 'Test',
        category: 'Test',
        questionsCount: 20,
        completedCount: 10,
      );

      // Act
      final progress = topic.progressPercentage;

      // Assert
      expect(progress, 50.0);
    });

    test('should return 0% progress when no questions', () {
      // Arrange
      const topic = Topic(
        id: 'topic2',
        name: 'Test',
        category: 'Test',
        questionsCount: 0,
        completedCount: 0,
      );

      // Act
      final progress = topic.progressPercentage;

      // Assert
      expect(progress, 0.0);
    });

    test('should calculate 100% progress when all complete', () {
      // Arrange
      const topic = Topic(
        id: 'topic3',
        name: 'Test',
        category: 'Test',
        questionsCount: 10,
        completedCount: 10,
      );

      // Act
      final progress = topic.progressPercentage;

      // Assert
      expect(progress, 100.0);
    });

    test('should calculate partial progress correctly', () {
      // Arrange
      const topic = Topic(
        id: 'topic4',
        name: 'Test',
        category: 'Test',
        questionsCount: 8,
        completedCount: 3,
      );

      // Act
      final progress = topic.progressPercentage;

      // Assert
      expect(progress, 37.5);
    });
  });
}

