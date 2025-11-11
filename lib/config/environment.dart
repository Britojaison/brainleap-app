import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get supabaseUrl => dotenv.get('SUPABASE_URL', fallback: 'https://example.supabase.co');
  static String get supabaseAnonKey => dotenv.get('SUPABASE_ANON_KEY', fallback: 'public-anon-key');
  static String get backendBaseUrl => dotenv.get('BACKEND_BASE_URL', fallback: 'http://localhost:4000');

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // .env file not found, will use fallback values
    }
  }
}
