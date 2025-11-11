import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get supabaseUrl => dotenv.get('SUPABASE_URL', fallback: 'https://example.supabase.co');
  static String get supabaseAnonKey => dotenv.get('SUPABASE_ANON_KEY', fallback: 'public-anon-key');
  static String get backendBaseUrl => dotenv.get('BACKEND_BASE_URL', fallback: 'http://localhost:4000');

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
