class RoutePaths {
  static const String login = '/login';
  static const String home = '/home';
  static const String aiHint = '/ai-hint';
  static const String answerCanvas = '/answer-canvas';
  static const String topicSelection = '/topic-selection';
  static const String dashboard = '/dashboard';
}

class StorageKeys {
  static const String authToken = 'auth-token';
  static const String userProfile = 'user-profile';
  static const String recentSession = 'recent-session';
  static const String lastQuestionId = 'last-question-id';
}

class AppConfig {
  static const int apiTimeout = 30; // seconds
  static const int maxRetries = 3;
  static const String appVersion = '0.0.1';
}
