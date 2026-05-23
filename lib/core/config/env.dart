// Environment configuration.
//
// Pass values at build time:
//   flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
//               --dart-define=SUPABASE_ANON_KEY=eyJh...
//
// When SUPABASE_URL is empty the app falls back to the in-memory FakeAuthRepository
// so the UI is fully usable locally without backend credentials.

class Env {
  Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');
  static const String sentryEnvironment =
      String.fromEnvironment('SENTRY_ENVIRONMENT', defaultValue: 'dev');
  static const String sentryRelease = String.fromEnvironment('SENTRY_RELEASE');

  static bool get hasSupabase => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  static bool get hasSentry => sentryDsn.isNotEmpty;
}
