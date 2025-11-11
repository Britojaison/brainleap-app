import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get supabaseUrl => dotenv.get('SUPABASE_URL', fallback: 'https://example.supabase.co');
  static String get supabaseAnonKey => dotenv.get('SUPABASE_ANON_KEY', fallback: 'public-anon-key');

  static String get backendBaseUrl {
    final envValue = dotenv.env['BACKEND_BASE_URL'];
    if (envValue != null && envValue.isNotEmpty) {
      return envValue;
    }

    if (kIsWeb) {
      return 'http://localhost:4000';
    }

    if (Platform.isAndroid) {
      // Android emulators expose the host loopback via 10.0.2.2
      return 'http://10.0.2.2:4000';
    }

    if (Platform.isIOS || Platform.isMacOS) {
      // iOS simulators and macOS builds can talk to the host via localhost
      return 'http://localhost:4000';
    }

    return 'http://localhost:4000';
  }

  static Future<void> load() async {
    try {
      print('🔧 Environment: Loading .env file...');
      await dotenv.load(fileName: '.env');
      print('✅ Environment: .env loaded successfully');
      print('📡 BACKEND_BASE_URL: ${dotenv.env['BACKEND_BASE_URL'] ?? 'NOT SET'}');
      print('🔗 Using backend URL: $backendBaseUrl');
    } catch (e) {
      print('⚠️ Environment: .env file not found, using fallback values');
      print('❌ Error: $e');
      print('🔗 Fallback backend URL: $backendBaseUrl');
    }
  }
}
