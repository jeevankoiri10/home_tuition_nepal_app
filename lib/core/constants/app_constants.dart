class AppConstants {
  AppConstants._();

  static const String appName = 'Home Tuition Nepal';
  static const String publisher = 'KTM academy';

  static const String prefsLocaleKey = 'app.locale';
  static const String prefsThemeModeKey = 'app.themeMode';

  static const String localeEn = 'en';
  static const String localeNe = 'ne';

  static const String defaultAdminWhatsapp = 'https://wa.me/9779807590455';

  static const int defaultSignupCoinGrant = 1000;
  static const int defaultApplyCoinCost = 1;
  static const int defaultUnlockCoinCost = 5;
  static const int referralCoinReward = 25;

  /// Hard cap on the tutor CV PDF size (Phase 19). Mirrored server-side by
  /// the `tutor-cvs` storage bucket's policy.
  static const int tutorCvMaxBytes = 300 * 1024;

  /// eSewa destination shown on the in-app payment QR (Phase 20). Hard-coded
  /// to the platform owner's account so receipts and QR payloads stay
  /// consistent across builds.
  static const String esewaPayeeName = 'Jeevan Koiri';
  static const String esewaPayeeNumber = '9779807590455';

  /// 5 MB cap for the topup receipt image/PDF the user uploads after paying.
  static const int topUpReceiptMaxBytes = 5 * 1024 * 1024;
}
