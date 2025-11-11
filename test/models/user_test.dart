import 'package:flutter_test/flutter_test.dart';
import 'package:brainleap/models/user.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('should create UserProfile from JSON with all fields', () {
      // Arrange
      final json = {
        'id': 'user123',
        'email': 'test@example.com',
        'displayName': 'Test User',
      };

      // Act
      final user = UserProfile.fromJson(json);

      // Assert
      expect(user.id, 'user123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
    });

    test('should create UserProfile from JSON with snake_case fields', () {
      // Arrange
      final json = {
        'id': 'user456',
        'email': 'snake@example.com',
        'display_name': 'Snake Case User',
      };

      // Act
      final user = UserProfile.fromJson(json);

      // Assert
      expect(user.id, 'user456');
      expect(user.email, 'snake@example.com');
      expect(user.displayName, 'Snake Case User');
    });

    test('should handle null displayName', () {
      // Arrange
      final json = {
        'id': 'user789',
        'email': 'nodisplay@example.com',
      };

      // Act
      final user = UserProfile.fromJson(json);

      // Assert
      expect(user.id, 'user789');
      expect(user.email, 'nodisplay@example.com');
      expect(user.displayName, null);
    });

    test('should convert UserProfile to JSON', () {
      // Arrange
      const user = UserProfile(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], 'user123');
      expect(json['email'], 'test@example.com');
      expect(json['displayName'], 'Test User');
    });

    test('should convert UserProfile to JSON with null displayName', () {
      // Arrange
      const user = UserProfile(
        id: 'user456',
        email: 'test@example.com',
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], 'user456');
      expect(json['email'], 'test@example.com');
      expect(json['displayName'], null);
    });
  });
}

