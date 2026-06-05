class AppConstants {
  AppConstants._();

  static const String appName = 'Home Tuition Nepal';
  static const String publisher = 'KTM academy';

  /// Brand logo assets. The white mark is for the indigo app bar; the black
  /// mark is for light surfaces.
  static const String appLogoWhiteAsset = 'assets/images/logo-white.png';
  static const String appLogoBlackAsset = 'assets/images/logo-black.png';

  static const String prefsLocaleKey = 'app.locale';
  static const String prefsThemeModeKey = 'app.themeMode';

  static const String localeEn = 'en';
  static const String localeNe = 'ne';

  static const String defaultAdminWhatsapp = 'https://wa.me/9779807590455';

  static const int defaultSignupCoinGrant = 1000;
  static const int defaultApplyCoinCost = 1;
  static const int defaultUnlockCoinCost = 5;
  static const int referralCoinReward = 25;

  /// Percentage-based connect (apply) cost. The coins a tutor spends to apply
  /// to a vacancy scale with the job's salary: `cost = ceil(salary × percent%)`,
  /// clamped to `[min, max]`. Hourly salaries are normalized to a monthly
  /// equivalent first using [applyCostHourlyMonthlyHours]. These are defaults —
  /// the server (`platform_settings`) is authoritative and can override each.
  static const int defaultApplyCostPercent = 10;
  static const int defaultApplyCostMin = 1;
  static const int defaultApplyCostMax = 25;

  /// Assumed working hours per month used to convert an hourly salary into a
  /// monthly equivalent before applying [defaultApplyCostPercent].
  static const int applyCostHourlyMonthlyHours = 30;

  /// Assumed working days per month used to convert a daily salary/budget into
  /// a monthly equivalent before applying [defaultApplyCostPercent].
  static const int applyCostDayMonthlyDays = 26;

  /// Hard cap on the tutor CV PDF size (Phase 19). Mirrored server-side by
  /// the `tutor-cvs` storage bucket's policy.
  static const int tutorCvMaxBytes = 300 * 1024;

  /// eSewa destination shown on the in-app payment QR (Phase 20). Hard-coded
  /// to the platform owner's account so receipts and QR payloads stay
  /// consistent across builds.
  static const String esewaPayeeName = 'Jeevan Koiri';
  static const String esewaPayeeNumber = '9779807590455';

  /// The platform owner's real eSewa/Fonepay merchant QR, bundled as an asset
  /// and displayed in the top-up sheet. Replace the file at this path to update
  /// the QR (a fresh app build picks it up). Users scan it, pay the exact pack
  /// price, then upload a receipt for admin verification.
  static const String esewaQrAsset = 'assets/images/QR-payment.jpeg';

  /// 5 MB cap for the topup receipt image/PDF the user uploads after paying.
  static const int topUpReceiptMaxBytes = 5 * 1024 * 1024;
}
