import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Home Tuition Nepal'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Search tutors in your locality.'**
  String get appTagline;

  /// No description provided for @publisher.
  ///
  /// In en, this message translates to:
  /// **'by KTM academy'**
  String get publisher;

  /// No description provided for @languagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languagePickerTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageNepali.
  ///
  /// In en, this message translates to:
  /// **'नेपाली'**
  String get languageNepali;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to find tutors in your locality.'**
  String get loginSubtitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in your details to get started.'**
  String get registerSubtitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get emailInvalid;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get passwordRequired;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSubmit;

  /// No description provided for @loginToRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Create one'**
  String get loginToRegister;

  /// No description provided for @loginErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get loginErrorInvalidCredentials;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @emailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddressLabel;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumberLabel;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'98XXXXXXXX'**
  String get phoneNumberHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @nameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Required (max 40).'**
  String get nameInvalid;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit Nepali mobile (98… / 97…).'**
  String get phoneInvalid;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters.'**
  String get passwordTooShort;

  /// No description provided for @passwordWeak.
  ///
  /// In en, this message translates to:
  /// **'Password must include letters and digits.'**
  String get passwordWeak;

  /// No description provided for @confirmPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get confirmPasswordMismatch;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @roleTutor.
  ///
  /// In en, this message translates to:
  /// **'I\'m a tutor'**
  String get roleTutor;

  /// No description provided for @roleTutorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I want to teach'**
  String get roleTutorSubtitle;

  /// No description provided for @roleStudent.
  ///
  /// In en, this message translates to:
  /// **'I\'m a student'**
  String get roleStudent;

  /// No description provided for @roleStudentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I\'m looking for a tutor'**
  String get roleStudentSubtitle;

  /// No description provided for @rolePermanentNote.
  ///
  /// In en, this message translates to:
  /// **'Your role is permanent for this account.'**
  String get rolePermanentNote;

  /// No description provided for @tosAcceptLabel.
  ///
  /// In en, this message translates to:
  /// **'I accept the Terms of Service & Privacy Policy.'**
  String get tosAcceptLabel;

  /// No description provided for @cocAcceptLabel.
  ///
  /// In en, this message translates to:
  /// **'I accept the Tutors\' Code of Conduct.'**
  String get cocAcceptLabel;

  /// No description provided for @pickRoleSnack.
  ///
  /// In en, this message translates to:
  /// **'Pick a role to continue.'**
  String get pickRoleSnack;

  /// No description provided for @tosRequiredSnack.
  ///
  /// In en, this message translates to:
  /// **'You must accept the Terms of Service.'**
  String get tosRequiredSnack;

  /// No description provided for @cocRequiredSnack.
  ///
  /// In en, this message translates to:
  /// **'Tutors must accept the Tutors\' Code of Conduct.'**
  String get cocRequiredSnack;

  /// No description provided for @registerSubmit.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerSubmit;

  /// No description provided for @registerToLogin.
  ///
  /// In en, this message translates to:
  /// **'Already registered? Sign in'**
  String get registerToLogin;

  /// No description provided for @registerErrorSignupFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the account. The email may already be in use.'**
  String get registerErrorSignupFailed;

  /// No description provided for @registerErrorCocRequired.
  ///
  /// In en, this message translates to:
  /// **'Tutors must accept the Code of Conduct.'**
  String get registerErrorCocRequired;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailInstruction.
  ///
  /// In en, this message translates to:
  /// **'We sent a confirmation link to {email}. Open it on this device, then come back and tap I\'ve verified.'**
  String verifyEmailInstruction(String email);

  /// No description provided for @verifyEmailRefresh.
  ///
  /// In en, this message translates to:
  /// **'I\'ve verified'**
  String get verifyEmailRefresh;

  /// No description provided for @verifyEmailResend.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get verifyEmailResend;

  /// No description provided for @verifyEmailResentSnack.
  ///
  /// In en, this message translates to:
  /// **'A new confirmation email was sent.'**
  String get verifyEmailResentSnack;

  /// No description provided for @verifyEmailNotYet.
  ///
  /// In en, this message translates to:
  /// **'We can\'t see the confirmation yet — open the email and click the link.'**
  String get verifyEmailNotYet;

  /// No description provided for @verifyEmailErrorNoSession.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get verifyEmailErrorNoSession;

  /// No description provided for @verifyEmailResendCooldown.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String verifyEmailResendCooldown(int seconds);

  /// No description provided for @studentHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Student home'**
  String get studentHomeTitle;

  /// No description provided for @tutorHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Tutor home'**
  String get tutorHomeTitle;

  /// No description provided for @signOutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutTooltip;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String homeWelcome(String name);

  /// No description provided for @homeHandle.
  ///
  /// In en, this message translates to:
  /// **'Handle: {handle}'**
  String homeHandle(String handle);

  /// No description provided for @studentMapPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'The locality-first map (the headline feature) ships in Phase 4.'**
  String get studentMapPlaceholder;

  /// No description provided for @previewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewLabel;

  /// No description provided for @currentBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'CURRENT BALANCE'**
  String get currentBalanceLabel;

  /// No description provided for @coinsSuffix.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} coin} other{{count} coins}}'**
  String coinsSuffix(int count);

  /// No description provided for @tutorActionCompleteProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get tutorActionCompleteProfileTitle;

  /// No description provided for @tutorActionCompleteProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Walk through the 7-step wizard to publish your tutor profile.'**
  String get tutorActionCompleteProfileSubtitle;

  /// No description provided for @tutorActionProfileSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile settings'**
  String get tutorActionProfileSettingsTitle;

  /// No description provided for @tutorActionProfileSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Edit subjects, prices, availability, About sections, credentials.'**
  String get tutorActionProfileSettingsSubtitle;

  /// No description provided for @tutorActionVacanciesTitle.
  ///
  /// In en, this message translates to:
  /// **'Vacancies'**
  String get tutorActionVacanciesTitle;

  /// No description provided for @tutorActionVacanciesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse open HTN-NNNNN vacancies and apply with 1 coin.'**
  String get tutorActionVacanciesSubtitle;

  /// No description provided for @tutorActionWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Coin wallet'**
  String get tutorActionWalletTitle;

  /// No description provided for @tutorActionWalletSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See balance, transaction history, and buy coins.'**
  String get tutorActionWalletSubtitle;

  /// No description provided for @tutorActionBoostTitle.
  ///
  /// In en, this message translates to:
  /// **'Boost listing (24h)'**
  String get tutorActionBoostTitle;

  /// No description provided for @tutorActionBoostSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get a highlighted pin and a top-of-feed slot.'**
  String get tutorActionBoostSubtitle;

  /// No description provided for @tutorBoostSuccessSnack.
  ///
  /// In en, this message translates to:
  /// **'Listing boosted for 24h · Balance: {balance}'**
  String tutorBoostSuccessSnack(int balance);

  /// No description provided for @tutorBoostFailedSnack.
  ///
  /// In en, this message translates to:
  /// **'Could not boost listing.'**
  String get tutorBoostFailedSnack;

  /// No description provided for @tutorBoostInsufficientSnack.
  ///
  /// In en, this message translates to:
  /// **'Insufficient coins for boost.'**
  String get tutorBoostInsufficientSnack;

  /// No description provided for @tutorPhasesNote.
  ///
  /// In en, this message translates to:
  /// **'Push notifications, in-app chat, and reviews ship in Phases 8–10.'**
  String get tutorPhasesNote;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Tutors near you'**
  String get mapTitle;

  /// No description provided for @mapMyPostsTooltip.
  ///
  /// In en, this message translates to:
  /// **'My posts'**
  String get mapMyPostsTooltip;

  /// No description provided for @mapRecenterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Re-center'**
  String get mapRecenterTooltip;

  /// No description provided for @mapRequestTutorFab.
  ///
  /// In en, this message translates to:
  /// **'Request a tutor'**
  String get mapRequestTutorFab;

  /// No description provided for @mapPostJobFab.
  ///
  /// In en, this message translates to:
  /// **'Post a job'**
  String get mapPostJobFab;

  /// No description provided for @mapTutorCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} tutor} other{{count} tutors}}'**
  String mapTutorCount(int count);

  /// No description provided for @mapAllMatchesHeader.
  ///
  /// In en, this message translates to:
  /// **'All matches'**
  String get mapAllMatchesHeader;

  /// No description provided for @mapEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No tutors match your filters'**
  String get mapEmptyTitle;

  /// No description provided for @mapEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Try widening the radius or loosening filters.'**
  String get mapEmptyHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
