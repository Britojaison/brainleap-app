import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static const String _productionBackendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://api.brainleap.com',
  );

  static bool get isProduction => kReleaseMode;
  static bool get isDevelopment => kDebugMode;
  static bool get isProfile => kProfileMode;
  
  static String get supabaseUrl => dotenv.get('SUPABASE_URL', fallback: 'https://example.supabase.co');
  static String get supabaseAnonKey => dotenv.get('SUPABASE_ANON_KEY', fallback: 'public-anon-key');

  static String get backendBaseUrl {
    if (isProduction) {
      return _productionBackendUrl;
    }

    final envValue = dotenv.env['BACKEND_BASE_URL'];
    if (envValue != null && envValue.isNotEmpty) {
      return envValue;
    }

    if (kIsWeb) {
      return 'http://localhost:4000';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:4000';
    }

    if (Platform.isIOS || Platform.isMacOS) {
      return 'http://localhost:4000';
    }

    return 'http://localhost:4000';
  }

  static Future<void> load() async {
    try {
      print('🔧 Environment: Loading .env file...');
      await dotenv.load(fileName: '.env');
      print('✅ Environment: .env loaded successfully');
      print('📡 Build Mode: ${isProduction ? 'PRODUCTION' : isDevelopment ? 'DEVELOPMENT' : 'PROFILE'}');
      print('🔗 Backend URL: $backendBaseUrl');
    } catch (e) {
      print('⚠️ Environment: .env file not found, using defaults');
      print('📡 Build Mode: ${isProduction ? 'PRODUCTION' : isDevelopment ? 'DEVELOPMENT' : 'PROFILE'}');
      print('🔗 Backend URL: $backendBaseUrl');
    }
  }
}
