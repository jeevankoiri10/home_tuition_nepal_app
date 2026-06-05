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
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  // Cloudinary — non-secret values (cloud name + unsigned upload preset) are
  // safe to ship in the client. The API secret is never embedded; uploads use
  // the unsigned preset only.
  static const String cloudinaryCloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
  );
  static const String cloudinaryUploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
  );

  static bool get hasCloudinary =>
      cloudinaryCloudName.isNotEmpty && cloudinaryUploadPreset.isNotEmpty;

  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');
  static const String sentryEnvironment = String.fromEnvironment(
    'SENTRY_ENVIRONMENT',
    defaultValue: 'dev',
  );
  static const String sentryRelease = String.fromEnvironment('SENTRY_RELEASE');

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  static bool get hasSentry => sentryDsn.isNotEmpty;

  // Remote push (FCM). Requires Firebase set up for the app (google-services.json
  // / GoogleService-Info.plist + firebase_options.dart) AND the `push_dispatcher`
  // Edge Function deployed. Until then leave false: the app uses
  // FakePushNotificationService and still shows notifications live in-app via
  // Supabase Realtime. Flip with --dart-define=PUSH_NOTIFICATIONS_CONFIGURED=true.
  static const bool pushNotificationsConfigured = bool.fromEnvironment(
    'PUSH_NOTIFICATIONS_CONFIGURED',
  );

  // Google sign-in. Real Google OAuth needs a Google Cloud OAuth client and the
  // provider enabled in the Supabase dashboard (with the Android SHA-1). That
  // config is now in place, so this defaults to true and signInWithGoogle drives
  // the real OAuth handshake (system browser + Google account chooser). The
  // anonymous-stub path is kept only as an explicit opt-out for local testing:
  // override with --dart-define=GOOGLE_OAUTH_CONFIGURED=false to use it.
  static const bool googleOAuthConfigured = bool.fromEnvironment(
    'GOOGLE_OAUTH_CONFIGURED',
    defaultValue: true,
  );

  // Deep link the Google OAuth flow redirects back to once the browser
  // completes. It must match, exactly, BOTH:
  //   • the custom scheme registered in AndroidManifest.xml (and iOS
  //     Info.plist CFBundleURLSchemes), and
  //   • the Redirect URL allow-list in the Supabase dashboard
  //     (Authentication → URL Configuration).
  // Override per build with --dart-define=GOOGLE_OAUTH_REDIRECT=...
  static const String googleOAuthRedirect = String.fromEnvironment(
    'GOOGLE_OAUTH_REDIRECT',
    defaultValue: 'com.ktmacademy.hometuitionnepal://login-callback',
  );
}
