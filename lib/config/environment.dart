class Environment {
  static String supabaseUrl = '';
  static String supabaseAnonKey = '';
  static String backendBaseUrl = '';

  static void load() {
    // TODO: Wire up runtime environment loading (e.g., flutter_dotenv).
    supabaseUrl = const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://example.supabase.co');
    supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'public-anon-key');
    backendBaseUrl = const String.fromEnvironment('BACKEND_BASE_URL', defaultValue: 'http://localhost:4000');
  }
}
