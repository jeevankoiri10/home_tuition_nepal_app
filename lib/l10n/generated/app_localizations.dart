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

  /// No description provided for @walletTitle.
  ///
  /// In en, this message translates to:
  /// **'Coin Wallet'**
  String get walletTitle;

  /// No description provided for @walletBuyCoins.
  ///
  /// In en, this message translates to:
  /// **'Buy Coins'**
  String get walletBuyCoins;

  /// No description provided for @walletTransactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get walletTransactionHistory;

  /// No description provided for @walletNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet.'**
  String get walletNoTransactions;

  /// No description provided for @ledgerColDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get ledgerColDate;

  /// No description provided for @ledgerColDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get ledgerColDetails;

  /// No description provided for @ledgerColCoins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get ledgerColCoins;

  /// No description provided for @unlockNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Please sign in first.'**
  String get unlockNotSignedIn;

  /// No description provided for @unlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock contact for {cost} coins'**
  String unlockTitle(int cost);

  /// No description provided for @unlockBody.
  ///
  /// In en, this message translates to:
  /// **'You can contact the tutor over phone or WhatsApp once unlocked. This is a one-time cost — repeat unlocks for the same tutor are free.'**
  String get unlockBody;

  /// No description provided for @unlockNeedMoreCoins.
  ///
  /// In en, this message translates to:
  /// **'You need more coins. Top up to continue.'**
  String get unlockNeedMoreCoins;

  /// No description provided for @unlockFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not unlock contact.'**
  String get unlockFailedGeneric;

  /// No description provided for @workingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get workingEllipsis;

  /// No description provided for @unlockConfirmCta.
  ///
  /// In en, this message translates to:
  /// **'Confirm — {cost} coins'**
  String unlockConfirmCta(int cost);

  /// No description provided for @buyCoinsLink.
  ///
  /// In en, this message translates to:
  /// **'Buy coins'**
  String get buyCoinsLink;

  /// No description provided for @unlockSuccess.
  ///
  /// In en, this message translates to:
  /// **'Contact unlocked'**
  String get unlockSuccess;

  /// No description provided for @unlockNewBalance.
  ///
  /// In en, this message translates to:
  /// **'New balance: {balance} coins'**
  String unlockNewBalance(int balance);

  /// No description provided for @openChat.
  ///
  /// In en, this message translates to:
  /// **'Open chat'**
  String get openChat;

  /// No description provided for @callLabel.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callLabel;

  /// No description provided for @whatsAppLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsAppLabel;

  /// No description provided for @unlockCallPhase7Hint.
  ///
  /// In en, this message translates to:
  /// **'Phone-number reveal lands when admin matches go live (Phase 7).'**
  String get unlockCallPhase7Hint;

  /// No description provided for @unlockWhatsAppPhase7Hint.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp launch wires in Phase 7.'**
  String get unlockWhatsAppPhase7Hint;

  /// No description provided for @leaveReview.
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get leaveReview;

  /// No description provided for @doneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneLabel;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notificationsTabAll;

  /// No description provided for @notificationsTabAllCount.
  ///
  /// In en, this message translates to:
  /// **'All ({count})'**
  String notificationsTabAllCount(int count);

  /// No description provided for @notificationsTabUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get notificationsTabUnread;

  /// No description provided for @notificationsTabUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'Unread ({count})'**
  String notificationsTabUnreadCount(int count);

  /// No description provided for @notificationsTabRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get notificationsTabRead;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get notificationsEmpty;

  /// No description provided for @notificationsEmptyUnread.
  ///
  /// In en, this message translates to:
  /// **'No unread notifications.'**
  String get notificationsEmptyUnread;

  /// No description provided for @notificationsEmptyRead.
  ///
  /// In en, this message translates to:
  /// **'No read notifications.'**
  String get notificationsEmptyRead;

  /// No description provided for @relativeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get relativeJustNow;

  /// No description provided for @relativeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String relativeMinutesAgo(int count);

  /// No description provided for @relativeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String relativeHoursAgo(int count);

  /// No description provided for @relativeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String relativeDaysAgo(int count);

  /// No description provided for @notifKindNewJobPosted.
  ///
  /// In en, this message translates to:
  /// **'New job posted'**
  String get notifKindNewJobPosted;

  /// No description provided for @notifKindApplicationShortlisted.
  ///
  /// In en, this message translates to:
  /// **'Application shortlisted'**
  String get notifKindApplicationShortlisted;

  /// No description provided for @notifKindApplicationHired.
  ///
  /// In en, this message translates to:
  /// **'You were hired'**
  String get notifKindApplicationHired;

  /// No description provided for @notifKindContactRevealed.
  ///
  /// In en, this message translates to:
  /// **'Contact revealed'**
  String get notifKindContactRevealed;

  /// No description provided for @notifKindIdentityApproved.
  ///
  /// In en, this message translates to:
  /// **'Identity Verification Approved'**
  String get notifKindIdentityApproved;

  /// No description provided for @notifKindIdentityRejected.
  ///
  /// In en, this message translates to:
  /// **'Verification needs attention'**
  String get notifKindIdentityRejected;

  /// No description provided for @notifKindCoinCredited.
  ///
  /// In en, this message translates to:
  /// **'Coins credited'**
  String get notifKindCoinCredited;

  /// No description provided for @notifKindCoinDebited.
  ///
  /// In en, this message translates to:
  /// **'Coins debited'**
  String get notifKindCoinDebited;

  /// No description provided for @notifKindNewReview.
  ///
  /// In en, this message translates to:
  /// **'New review'**
  String get notifKindNewReview;

  /// No description provided for @notifKindSystem.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get notifKindSystem;

  /// No description provided for @chatTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitleFallback;

  /// No description provided for @chatOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open chat.'**
  String get chatOpenError;

  /// No description provided for @chatComposerHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get chatComposerHint;

  /// No description provided for @chatEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Say hello — and remember: do not share phone numbers or emails here.'**
  String get chatEmptyHint;

  /// No description provided for @reviewRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate {name}'**
  String reviewRateTitle(String name);

  /// No description provided for @reviewPhoneBanWarning.
  ///
  /// In en, this message translates to:
  /// **'Do not include phone numbers or contact details in your review.'**
  String get reviewPhoneBanWarning;

  /// No description provided for @reviewTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Tell other students about this tutor'**
  String get reviewTextLabel;

  /// No description provided for @reviewTextHint.
  ///
  /// In en, this message translates to:
  /// **'Optional. Stay specific and respectful.'**
  String get reviewTextHint;

  /// No description provided for @reviewSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get reviewSubmit;

  /// No description provided for @reviewSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get reviewSending;

  /// No description provided for @reviewThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your review!'**
  String get reviewThanks;

  /// No description provided for @reviewGateNotMet.
  ///
  /// In en, this message translates to:
  /// **'You need to unlock this tutor first.'**
  String get reviewGateNotMet;

  /// No description provided for @reviewPhoneRejected.
  ///
  /// In en, this message translates to:
  /// **'Phone numbers and contact details are not allowed.'**
  String get reviewPhoneRejected;

  /// No description provided for @reviewFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not submit review.'**
  String get reviewFailedGeneric;

  /// No description provided for @notRated.
  ///
  /// In en, this message translates to:
  /// **'Not rated'**
  String get notRated;

  /// No description provided for @filterVerifiedOnly.
  ///
  /// In en, this message translates to:
  /// **'Verified only'**
  String get filterVerifiedOnly;

  /// No description provided for @filterAvailableNow.
  ///
  /// In en, this message translates to:
  /// **'Available now'**
  String get filterAvailableNow;

  /// No description provided for @filterLevelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Student level'**
  String get filterLevelTooltip;

  /// No description provided for @filterAllLevels.
  ///
  /// In en, this message translates to:
  /// **'All levels'**
  String get filterAllLevels;

  /// No description provided for @filterTeachingModeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Teaching mode'**
  String get filterTeachingModeTooltip;

  /// No description provided for @filterAnyMode.
  ///
  /// In en, this message translates to:
  /// **'Any mode'**
  String get filterAnyMode;

  /// No description provided for @filterRadiusTooltip.
  ///
  /// In en, this message translates to:
  /// **'Radius'**
  String get filterRadiusTooltip;

  /// No description provided for @filterRadiusWithinKm.
  ///
  /// In en, this message translates to:
  /// **'Within {km} km'**
  String filterRadiusWithinKm(int km);

  /// No description provided for @filterRadiusKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String filterRadiusKm(int km);

  /// No description provided for @tutorAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get tutorAvailable;

  /// No description provided for @contactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactLabel;

  /// No description provided for @teachingModeOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get teachingModeOnline;

  /// No description provided for @teachingModeOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline (in-person)'**
  String get teachingModeOffline;

  /// No description provided for @teachingModeBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get teachingModeBoth;

  /// No description provided for @studentLevelBelowClass9.
  ///
  /// In en, this message translates to:
  /// **'Below Class 9'**
  String get studentLevelBelowClass9;

  /// No description provided for @studentLevelSee.
  ///
  /// In en, this message translates to:
  /// **'SEE'**
  String get studentLevelSee;

  /// No description provided for @studentLevelPlus2.
  ///
  /// In en, this message translates to:
  /// **'+2'**
  String get studentLevelPlus2;

  /// No description provided for @studentLevelALevel.
  ///
  /// In en, this message translates to:
  /// **'A Level'**
  String get studentLevelALevel;

  /// No description provided for @vacanciesTitle.
  ///
  /// In en, this message translates to:
  /// **'Vacancies'**
  String get vacanciesTitle;

  /// No description provided for @refreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshTooltip;

  /// No description provided for @vacanciesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load vacancies.'**
  String get vacanciesLoadError;

  /// No description provided for @vacanciesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No open vacancies right now. Pull to refresh.'**
  String get vacanciesEmpty;

  /// No description provided for @vacancyApplyLabel.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get vacancyApplyLabel;

  /// No description provided for @vacancyAppliedLabel.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get vacancyAppliedLabel;

  /// No description provided for @vacancyAlreadyApplied.
  ///
  /// In en, this message translates to:
  /// **'Already applied'**
  String get vacancyAlreadyApplied;

  /// No description provided for @vacancyGradePrefix.
  ///
  /// In en, this message translates to:
  /// **'Grade: {grade}'**
  String vacancyGradePrefix(String grade);

  /// No description provided for @vacancySubjectsPrefix.
  ///
  /// In en, this message translates to:
  /// **'Subjects: {subjects}'**
  String vacancySubjectsPrefix(String subjects);

  /// No description provided for @vacancyNumStudentsPrefix.
  ///
  /// In en, this message translates to:
  /// **'No. of students: {count}'**
  String vacancyNumStudentsPrefix(int count);

  /// No description provided for @vacancyTimePrefix.
  ///
  /// In en, this message translates to:
  /// **'Time: {text}'**
  String vacancyTimePrefix(String text);

  /// No description provided for @vacancyGenderPrefPrefix.
  ///
  /// In en, this message translates to:
  /// **'Gender preference: {label}'**
  String vacancyGenderPrefPrefix(String label);

  /// No description provided for @vacancyModePrefix.
  ///
  /// In en, this message translates to:
  /// **'Mode: {label}'**
  String vacancyModePrefix(String label);

  /// No description provided for @vacancyNotesHeader.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get vacancyNotesHeader;

  /// No description provided for @vacancyPostedByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Posted by Home Tuition Nepal admin.'**
  String get vacancyPostedByAdmin;

  /// No description provided for @vacancyTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Vacancy'**
  String get vacancyTitleFallback;

  /// No description provided for @vacancyNotFound.
  ///
  /// In en, this message translates to:
  /// **'Vacancy not found.'**
  String get vacancyNotFound;

  /// No description provided for @applySheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply to {label}'**
  String applySheetTitle(String label);

  /// No description provided for @applyPhoneBanWarning.
  ///
  /// In en, this message translates to:
  /// **'Do not include phone numbers or contact details in your cover note. Accounts that do will be blocked.'**
  String get applyPhoneBanWarning;

  /// No description provided for @applyCoverLabel.
  ///
  /// In en, this message translates to:
  /// **'Cover note'**
  String get applyCoverLabel;

  /// No description provided for @applyCoverHint.
  ///
  /// In en, this message translates to:
  /// **'Why are you a good fit?'**
  String get applyCoverHint;

  /// No description provided for @applyCoverRequired.
  ///
  /// In en, this message translates to:
  /// **'Please write a short cover note.'**
  String get applyCoverRequired;

  /// No description provided for @applyCoverPhoneViolation.
  ///
  /// In en, this message translates to:
  /// **'Remove phone numbers or contact details.'**
  String get applyCoverPhoneViolation;

  /// No description provided for @applyRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected rate (NPR, optional)'**
  String get applyRateLabel;

  /// No description provided for @applySending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get applySending;

  /// No description provided for @applyButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'{cost, plural, one{Apply — {cost} coin} other{Apply — {cost} coins}}'**
  String applyButtonLabel(int cost);

  /// No description provided for @applySuccessSnack.
  ///
  /// In en, this message translates to:
  /// **'Application sent. Admin will review it.'**
  String get applySuccessSnack;

  /// No description provided for @jobModeInPerson.
  ///
  /// In en, this message translates to:
  /// **'In-person'**
  String get jobModeInPerson;

  /// No description provided for @jobModeOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get jobModeOnline;

  /// No description provided for @jobModeEither.
  ///
  /// In en, this message translates to:
  /// **'Either'**
  String get jobModeEither;

  /// No description provided for @genderPrefAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get genderPrefAny;

  /// No description provided for @genderPrefMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderPrefMale;

  /// No description provided for @genderPrefFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderPrefFemale;
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
