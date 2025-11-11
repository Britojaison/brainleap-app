import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brainleap/providers/auth_provider.dart';
import 'package:brainleap/services/api_service.dart';

@GenerateMocks([ApiService])
import 'auth_provider_test.mocks.dart';

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider provider;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      provider = AuthProvider(apiService: mockApiService);
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      provider.dispose();
    });

    test('initial state should have default values', () {
      // Assert
      expect(provider.isLoading, false);
      expect(provider.isAuthenticated, false);
      expect(provider.user, null);
      expect(provider.token, null);
      expect(provider.errorMessage, null);
    });

    test('login should update state with user and token on success', () async {
      // Arrange
      final mockResponse = http.Response(
        '{"token": "test-token", "user": {"id": "user123", "email": "test@example.com", "displayName": "Test User"}}',
        200,
      );
      when(mockApiService.login(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockResponse);

      // Act
      await provider.login('test@example.com', 'password123');

      // Assert
      expect(provider.isLoading, false);
      expect(provider.isAuthenticated, true);
      expect(provider.token, 'test-token');
      expect(provider.user, isNotNull);
      expect(provider.user!.email, 'test@example.com');
      expect(provider.errorMessage, null);
    });

    test('login should update state with error on failure', () async {
      // Arrange
      final mockResponse = http.Response(
        '{"message": "Invalid credentials"}',
        401,
      );
      when(mockApiService.login(
        email: 'wrong@example.com',
        password: 'wrongpass',
      )).thenAnswer((_) async => mockResponse);

      // Act & Assert
      expect(
        () => provider.login('wrong@example.com', 'wrongpass'),
        throwsException,
      );
    });

    test('login should handle network errors', () async {
      // Arrange
      when(mockApiService.login(
        email: 'test@example.com',
        password: 'password123',
      )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => provider.login('test@example.com', 'password123'),
        throwsException,
      );
    });

    test('logout should clear user and token', () async {
      // Arrange - login first
      final mockResponse = http.Response(
        '{"token": "test-token", "user": {"id": "user123", "email": "test@example.com"}}',
        200,
      );
      when(mockApiService.login(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockResponse);
      await provider.login('test@example.com', 'password123');

      // Act
      await provider.logout();

      // Assert
      expect(provider.isAuthenticated, false);
      expect(provider.token, null);
      expect(provider.user, null);
    });

    test('clearError should reset error message', () async {
      // Arrange - trigger an error first
      when(mockApiService.login(
        email: 'test@example.com',
        password: 'wrong',
      )).thenThrow(Exception('Test error'));
      
      try {
        await provider.login('test@example.com', 'wrong');
      } catch (_) {
        // Expected error
      }

      // Act
      provider.clearError();

      // Assert
      expect(provider.errorMessage, null);
    });

    test('should notify listeners when state changes', () async {
      // Arrange
      final mockResponse = http.Response(
        '{"token": "test-token", "user": {"id": "user123", "email": "test@example.com"}}',
        200,
      );
      when(mockApiService.login(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockResponse);

      var notificationCount = 0;
      provider.addListener(() {
        notificationCount++;
      });

      // Act
      await provider.login('test@example.com', 'password123');

      // Assert
      expect(notificationCount, greaterThan(0));
    });

    test('initialize should load saved token and user', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        'auth-token': 'saved-token',
        'user-profile': '{"id": "user123", "email": "saved@example.com", "displayName": "Saved User"}',
      });

      // Act
      await provider.initialize();

      // Assert
      expect(provider.isAuthenticated, true);
      expect(provider.token, 'saved-token');
      expect(provider.user, isNotNull);
      expect(provider.user!.email, 'saved@example.com');
    });
  });
}

