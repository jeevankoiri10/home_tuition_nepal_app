// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Home Tuition Nepal';

  @override
  String get appTagline => 'Search tutors in your locality.';

  @override
  String get publisher => 'by KTM academy';

  @override
  String get languagePickerTitle => 'Choose your language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageNepali => 'नेपाली';

  @override
  String get continueLabel => 'Continue';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to find tutors in your locality.';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle => 'Fill in your details to get started.';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';
}
