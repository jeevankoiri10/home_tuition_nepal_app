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

  /// No description provided for @languageToggleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get languageToggleTooltip;

  /// No description provided for @noticeDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get noticeDetailsTitle;

  /// No description provided for @noticeDetailsNotFound.
  ///
  /// In en, this message translates to:
  /// **'This notice is no longer available.'**
  String get noticeDetailsNotFound;

  /// No description provided for @noticeDetailsReceivedAt.
  ///
  /// In en, this message translates to:
  /// **'Received {when}'**
  String noticeDetailsReceivedAt(String when);

  /// No description provided for @filterRadiusNoLimit.
  ///
  /// In en, this message translates to:
  /// **'Any distance'**
  String get filterRadiusNoLimit;

  /// No description provided for @filterRadiusOptionNoLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get filterRadiusOptionNoLimit;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Profile and settings'**
  String get settingsProfileTooltip;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Pick the language you prefer for the app.'**
  String get settingsLanguageHint;

  /// No description provided for @settingsLogoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogoutLabel;

  /// No description provided for @settingsReferralSection.
  ///
  /// In en, this message translates to:
  /// **'Refer a friend'**
  String get settingsReferralSection;

  /// No description provided for @settingsReferralHint.
  ///
  /// In en, this message translates to:
  /// **'Share your code with a friend. When they sign up, you both earn {coins} coins.'**
  String settingsReferralHint(int coins);

  /// No description provided for @settingsReferralCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Your referral code'**
  String get settingsReferralCodeLabel;

  /// No description provided for @settingsReferralCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get settingsReferralCopy;

  /// No description provided for @settingsReferralCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get settingsReferralCopied;

  /// No description provided for @tutorCardViewCv.
  ///
  /// In en, this message translates to:
  /// **'View CV'**
  String get tutorCardViewCv;

  /// No description provided for @tutorCardCvOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the CV.'**
  String get tutorCardCvOpenFailed;

  /// No description provided for @requestSubjectsCustomHint.
  ///
  /// In en, this message translates to:
  /// **'Add another subject'**
  String get requestSubjectsCustomHint;

  /// No description provided for @requestSubjectsCustomAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get requestSubjectsCustomAdd;

  /// No description provided for @postJobSectionMode.
  ///
  /// In en, this message translates to:
  /// **'Online or offline?'**
  String get postJobSectionMode;

  /// No description provided for @jobModeOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get jobModeOffline;

  /// No description provided for @chatListTitle.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatListTitle;

  /// No description provided for @chatListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get chatListEmptyTitle;

  /// No description provided for @chatListEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Once you unlock a contact or are matched to a vacancy, your chats will appear here.'**
  String get chatListEmptyHint;

  /// No description provided for @tutorActionChatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get tutorActionChatsTitle;

  /// No description provided for @tutorActionChatsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your conversations with students.'**
  String get tutorActionChatsSubtitle;

  /// No description provided for @tutorNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tutorNavHome;

  /// No description provided for @tutorNavChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get tutorNavChats;

  /// No description provided for @tutorNavVacancies.
  ///
  /// In en, this message translates to:
  /// **'Vacancies'**
  String get tutorNavVacancies;

  /// No description provided for @tutorNavSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tutorNavSettings;

  /// No description provided for @wizardServiceAreaPinHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the map until the pin is over the place you teach from.'**
  String get wizardServiceAreaPinHint;

  /// No description provided for @mapPinPickerUseMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get mapPinPickerUseMyLocation;

  /// No description provided for @subjectSectionHeading.
  ///
  /// In en, this message translates to:
  /// **'Subject {number}'**
  String subjectSectionHeading(int number);

  /// No description provided for @subjectLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get subjectLevelLabel;

  /// No description provided for @subjectNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subjectNameLabel;

  /// No description provided for @subjectPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price (NPR)'**
  String get subjectPriceLabel;

  /// No description provided for @subjectPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Per'**
  String get subjectPeriodLabel;

  /// No description provided for @wizardCvUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload your CV'**
  String get wizardCvUploadTitle;

  /// No description provided for @wizardCvUploadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Students will be able to download this PDF from your profile.'**
  String get wizardCvUploadSubtitle;

  /// No description provided for @wizardCvSizeHint.
  ///
  /// In en, this message translates to:
  /// **'PDF only · max 300 KB.'**
  String get wizardCvSizeHint;

  /// No description provided for @wizardCvUploadButton.
  ///
  /// In en, this message translates to:
  /// **'Choose CV PDF'**
  String get wizardCvUploadButton;

  /// No description provided for @wizardCvReplaceButton.
  ///
  /// In en, this message translates to:
  /// **'Replace CV'**
  String get wizardCvReplaceButton;

  /// No description provided for @wizardCvCurrent.
  ///
  /// In en, this message translates to:
  /// **'Your CV is on file.'**
  String get wizardCvCurrent;

  /// No description provided for @wizardCvUploaded.
  ///
  /// In en, this message translates to:
  /// **'CV uploaded.'**
  String get wizardCvUploaded;

  /// No description provided for @wizardCvTooLarge.
  ///
  /// In en, this message translates to:
  /// **'CV must be smaller than 300 KB.'**
  String get wizardCvTooLarge;

  /// No description provided for @wizardCvReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the selected file.'**
  String get wizardCvReadFailed;

  /// No description provided for @esewaSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay with eSewa'**
  String get esewaSheetTitle;

  /// No description provided for @esewaSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR or send {price} to the eSewa account below, then upload the receipt.'**
  String esewaSheetSubtitle(String price);

  /// No description provided for @esewaPayeeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get esewaPayeeNameLabel;

  /// No description provided for @esewaPayeeNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'eSewa #'**
  String get esewaPayeeNumberLabel;

  /// No description provided for @esewaUploadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Upload payment receipt'**
  String get esewaUploadReceipt;

  /// No description provided for @esewaReplaceReceipt.
  ///
  /// In en, this message translates to:
  /// **'Replace receipt'**
  String get esewaReplaceReceipt;

  /// No description provided for @esewaReceiptOnFile.
  ///
  /// In en, this message translates to:
  /// **'Receipt uploaded — awaiting admin review.'**
  String get esewaReceiptOnFile;

  /// No description provided for @esewaReceiptUploaded.
  ///
  /// In en, this message translates to:
  /// **'Receipt uploaded.'**
  String get esewaReceiptUploaded;

  /// No description provided for @esewaReceiptTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Receipt must be smaller than 5 MB.'**
  String get esewaReceiptTooLarge;

  /// No description provided for @esewaReceiptReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the selected file.'**
  String get esewaReceiptReadFailed;

  /// No description provided for @esewaDoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get esewaDoneLabel;

  /// No description provided for @esewaAdminReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Your coins are credited once an admin verifies the receipt.'**
  String get esewaAdminReviewHint;

  /// No description provided for @esewaTopUpQueued.
  ///
  /// In en, this message translates to:
  /// **'Top-up submitted. We\'ll credit your wallet after the receipt is verified.'**
  String get esewaTopUpQueued;

  /// No description provided for @loginChooserTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue as'**
  String get loginChooserTitle;

  /// No description provided for @loginChooserSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This email is registered as both a tutor and a student. Which one are you signing in as right now?'**
  String get loginChooserSubtitle;

  /// No description provided for @loginChooserAsTutor.
  ///
  /// In en, this message translates to:
  /// **'Login as a tutor'**
  String get loginChooserAsTutor;

  /// No description provided for @loginChooserAsStudent.
  ///
  /// In en, this message translates to:
  /// **'Login as a student'**
  String get loginChooserAsStudent;

  /// No description provided for @contractNoneHint.
  ///
  /// In en, this message translates to:
  /// **'Agree on terms here, then start a contract.'**
  String get contractNoneHint;

  /// No description provided for @contractCompletedHint.
  ///
  /// In en, this message translates to:
  /// **'Your last contract is complete. Start a new one anytime.'**
  String get contractCompletedHint;

  /// No description provided for @contractStartCta.
  ///
  /// In en, this message translates to:
  /// **'Start contract'**
  String get contractStartCta;

  /// No description provided for @contractProposeTitle.
  ///
  /// In en, this message translates to:
  /// **'Propose a contract'**
  String get contractProposeTitle;

  /// No description provided for @contractProposeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The other person accepts before it becomes active.'**
  String get contractProposeSubtitle;

  /// No description provided for @contractSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject / what you\'ll teach'**
  String get contractSubjectLabel;

  /// No description provided for @contractSubjectRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter what the contract is for.'**
  String get contractSubjectRequired;

  /// No description provided for @contractRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Rate (NPR)'**
  String get contractRateLabel;

  /// No description provided for @contractPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Per'**
  String get contractPeriodLabel;

  /// No description provided for @contractScheduleLabel.
  ///
  /// In en, this message translates to:
  /// **'Schedule (e.g. Sun–Fri, 5pm)'**
  String get contractScheduleLabel;

  /// No description provided for @contractProposeSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send proposal'**
  String get contractProposeSubmit;

  /// No description provided for @contractAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get contractAccept;

  /// No description provided for @contractDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get contractDecline;

  /// No description provided for @contractCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get contractCancel;

  /// No description provided for @contractWaitingResponse.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a response…'**
  String get contractWaitingResponse;

  /// No description provided for @contractActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Contract active'**
  String get contractActiveLabel;

  /// No description provided for @contractEndCta.
  ///
  /// In en, this message translates to:
  /// **'End contract'**
  String get contractEndCta;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate {name}'**
  String reviewTitle(String name);

  /// No description provided for @reviewHint.
  ///
  /// In en, this message translates to:
  /// **'Share how the tuition went (optional).'**
  String get reviewHint;

  /// No description provided for @reviewSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get reviewSubmit;

  /// No description provided for @reviewSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get reviewSkip;

  /// No description provided for @reviewThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your review!'**
  String get reviewThanks;

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

  /// No description provided for @reviewSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get reviewSending;

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

  /// No description provided for @myPostsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Posts'**
  String get myPostsTitle;

  /// No description provided for @myPostsTabJobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs ({count})'**
  String myPostsTabJobs(int count);

  /// No description provided for @myPostsTabVacancies.
  ///
  /// In en, this message translates to:
  /// **'Vacancies ({count})'**
  String myPostsTabVacancies(int count);

  /// No description provided for @postRequirementCta.
  ///
  /// In en, this message translates to:
  /// **'Post Requirement'**
  String get postRequirementCta;

  /// No description provided for @requestTutorCta.
  ///
  /// In en, this message translates to:
  /// **'Request a Tutor'**
  String get requestTutorCta;

  /// No description provided for @myJobsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No jobs posted yet. Tap \"Post Requirement\" to create one.'**
  String get myJobsEmpty;

  /// No description provided for @myVacanciesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tutor requests yet. Tap \"Request a Tutor\" to send one to the admin.'**
  String get myVacanciesEmpty;

  /// No description provided for @viewMessages.
  ///
  /// In en, this message translates to:
  /// **'View Messages'**
  String get viewMessages;

  /// No description provided for @closeAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeAction;

  /// No description provided for @repostAction.
  ///
  /// In en, this message translates to:
  /// **'Repost'**
  String get repostAction;

  /// No description provided for @chatPhase9Hint.
  ///
  /// In en, this message translates to:
  /// **'In-app chat ships in Phase 9.'**
  String get chatPhase9Hint;

  /// No description provided for @vacancyPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get vacancyPendingReview;

  /// No description provided for @postDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Post Detail'**
  String get postDetailTitle;

  /// No description provided for @postNotFound.
  ///
  /// In en, this message translates to:
  /// **'Post not found.'**
  String get postNotFound;

  /// No description provided for @postClosedBanner.
  ///
  /// In en, this message translates to:
  /// **'This requirement is closed.'**
  String get postClosedBanner;

  /// No description provided for @postPostedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Posted: {date}'**
  String postPostedPrefix(String date);

  /// No description provided for @postRequiresPrefix.
  ///
  /// In en, this message translates to:
  /// **'Requires: {label}'**
  String postRequiresPrefix(String label);

  /// No description provided for @postPostedByPrefix.
  ///
  /// In en, this message translates to:
  /// **'Posted by: {name}'**
  String postPostedByPrefix(String name);

  /// No description provided for @postWhatsAppVerified.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp verified ✓ (number hidden until match)'**
  String get postWhatsAppVerified;

  /// No description provided for @postYouFallback.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get postYouFallback;

  /// No description provided for @postModeOnlineYes.
  ///
  /// In en, this message translates to:
  /// **'Available online'**
  String get postModeOnlineYes;

  /// No description provided for @postModeEither.
  ///
  /// In en, this message translates to:
  /// **'Online or in-person'**
  String get postModeEither;

  /// No description provided for @postModeOnlineNo.
  ///
  /// In en, this message translates to:
  /// **'Not available online'**
  String get postModeOnlineNo;

  /// No description provided for @postModeHomeYes.
  ///
  /// In en, this message translates to:
  /// **'Available for home tutoring'**
  String get postModeHomeYes;

  /// No description provided for @postModeHomeNo.
  ///
  /// In en, this message translates to:
  /// **'Online only — no home tutoring'**
  String get postModeHomeNo;

  /// No description provided for @postCanTravel.
  ///
  /// In en, this message translates to:
  /// **'Can travel'**
  String get postCanTravel;

  /// No description provided for @postCannotTravel.
  ///
  /// In en, this message translates to:
  /// **'Cannot travel'**
  String get postCannotTravel;

  /// No description provided for @postDescriptionHeader.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get postDescriptionHeader;

  /// No description provided for @postNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description.'**
  String get postNoDescription;

  /// No description provided for @jobStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get jobStatusOpen;

  /// No description provided for @jobStatusShortlisting.
  ///
  /// In en, this message translates to:
  /// **'Shortlisting'**
  String get jobStatusShortlisting;

  /// No description provided for @jobStatusHired.
  ///
  /// In en, this message translates to:
  /// **'Hired'**
  String get jobStatusHired;

  /// No description provided for @jobStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get jobStatusClosed;

  /// No description provided for @jobStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get jobStatusExpired;

  /// No description provided for @vacancyStatusPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending admin review'**
  String get vacancyStatusPendingReview;

  /// No description provided for @vacancyStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get vacancyStatusOpen;

  /// No description provided for @vacancyStatusApplicationsClosed.
  ///
  /// In en, this message translates to:
  /// **'Applications closed'**
  String get vacancyStatusApplicationsClosed;

  /// No description provided for @vacancyStatusFilled.
  ///
  /// In en, this message translates to:
  /// **'Filled'**
  String get vacancyStatusFilled;

  /// No description provided for @vacancyStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get vacancyStatusCancelled;

  /// No description provided for @engagementFullTime.
  ///
  /// In en, this message translates to:
  /// **'Full time'**
  String get engagementFullTime;

  /// No description provided for @engagementPartTime.
  ///
  /// In en, this message translates to:
  /// **'Part time'**
  String get engagementPartTime;

  /// No description provided for @engagementOneOff.
  ///
  /// In en, this message translates to:
  /// **'One-off'**
  String get engagementOneOff;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @phoneInTextValidation.
  ///
  /// In en, this message translates to:
  /// **'Remove phone numbers or contact details.'**
  String get phoneInTextValidation;

  /// No description provided for @phoneBanFormHint.
  ///
  /// In en, this message translates to:
  /// **'Please don\'t share any contact details (phone, email, website etc) here.'**
  String get phoneBanFormHint;

  /// No description provided for @postJobAppBar.
  ///
  /// In en, this message translates to:
  /// **'Post a job'**
  String get postJobAppBar;

  /// No description provided for @postJobSectionType.
  ///
  /// In en, this message translates to:
  /// **'Type of job'**
  String get postJobSectionType;

  /// No description provided for @postJobTypeHome.
  ///
  /// In en, this message translates to:
  /// **'Home tuition'**
  String get postJobTypeHome;

  /// No description provided for @postJobTypeOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get postJobTypeOnline;

  /// No description provided for @postJobTypeAssignment.
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get postJobTypeAssignment;

  /// No description provided for @postJobSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get postJobSectionTitle;

  /// No description provided for @postJobTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Headline (e.g., Maths tutor needed in Kapan)'**
  String get postJobTitleHint;

  /// No description provided for @postJobSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get postJobSectionDescription;

  /// No description provided for @postJobDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what you need.'**
  String get postJobDescriptionHint;

  /// No description provided for @postJobSectionWhereWhen.
  ///
  /// In en, this message translates to:
  /// **'Where & when'**
  String get postJobSectionWhereWhen;

  /// No description provided for @postJobSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get postJobSubjectLabel;

  /// No description provided for @postJobGradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade / Class'**
  String get postJobGradeLabel;

  /// No description provided for @postJobAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Area / chowk'**
  String get postJobAreaLabel;

  /// No description provided for @postJobScheduleLabel.
  ///
  /// In en, this message translates to:
  /// **'Schedule (e.g., evenings, 5–6pm)'**
  String get postJobScheduleLabel;

  /// No description provided for @postJobDueDatePick.
  ///
  /// In en, this message translates to:
  /// **'Due date — pick a date'**
  String get postJobDueDatePick;

  /// No description provided for @postJobDueOnPrefix.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String postJobDueOnPrefix(String date);

  /// No description provided for @postJobSectionBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get postJobSectionBudget;

  /// No description provided for @postJobBudgetMinLabel.
  ///
  /// In en, this message translates to:
  /// **'Min (NPR)'**
  String get postJobBudgetMinLabel;

  /// No description provided for @postJobBudgetMaxLabel.
  ///
  /// In en, this message translates to:
  /// **'Max (NPR)'**
  String get postJobBudgetMaxLabel;

  /// No description provided for @postJobPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get postJobPeriodLabel;

  /// No description provided for @postJobSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get postJobSectionPreferences;

  /// No description provided for @postJobModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get postJobModeLabel;

  /// No description provided for @postJobTutorGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'Tutor gender'**
  String get postJobTutorGenderLabel;

  /// No description provided for @postJobEngagementLabel.
  ///
  /// In en, this message translates to:
  /// **'Engagement type'**
  String get postJobEngagementLabel;

  /// No description provided for @postJobEngagementAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get postJobEngagementAny;

  /// No description provided for @postJobPostingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Posting…'**
  String get postJobPostingEllipsis;

  /// No description provided for @postJobSubmit.
  ///
  /// In en, this message translates to:
  /// **'Post job'**
  String get postJobSubmit;

  /// No description provided for @postJobFooter.
  ///
  /// In en, this message translates to:
  /// **'Matching tutors are notified automatically. You\'ll see their bids in My Posts.'**
  String get postJobFooter;

  /// No description provided for @postJobSuccessSnack.
  ///
  /// In en, this message translates to:
  /// **'Job posted. Tutors will be notified.'**
  String get postJobSuccessSnack;

  /// No description provided for @budgetPeriodHour.
  ///
  /// In en, this message translates to:
  /// **'/hour'**
  String get budgetPeriodHour;

  /// No description provided for @budgetPeriodDay.
  ///
  /// In en, this message translates to:
  /// **'/day'**
  String get budgetPeriodDay;

  /// No description provided for @budgetPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get budgetPeriodMonth;

  /// No description provided for @budgetPeriodSession.
  ///
  /// In en, this message translates to:
  /// **'/session'**
  String get budgetPeriodSession;

  /// No description provided for @budgetPeriodFixed.
  ///
  /// In en, this message translates to:
  /// **'fixed'**
  String get budgetPeriodFixed;

  /// No description provided for @requestSectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Details of your requirement'**
  String get requestSectionDetails;

  /// No description provided for @requestDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Hi,\nI need maths and Hindi tutors online.'**
  String get requestDetailsHint;

  /// No description provided for @requestSectionLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get requestSectionLocation;

  /// No description provided for @requestSectionSubjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get requestSectionSubjects;

  /// No description provided for @requestSubjectsRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one subject.'**
  String get requestSubjectsRequired;

  /// No description provided for @requestSectionLevel.
  ///
  /// In en, this message translates to:
  /// **'Your Level'**
  String get requestSectionLevel;

  /// No description provided for @requestDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration / preferred time (e.g., 5pm–6pm)'**
  String get requestDurationLabel;

  /// No description provided for @requestMinSalaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Min salary (NPR)'**
  String get requestMinSalaryLabel;

  /// No description provided for @requestMaxSalaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Max salary (NPR)'**
  String get requestMaxSalaryLabel;

  /// No description provided for @requestGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender preference'**
  String get requestGenderLabel;

  /// No description provided for @requestSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send request to admin'**
  String get requestSubmit;

  /// No description provided for @requestFooter.
  ///
  /// In en, this message translates to:
  /// **'Admin reviews your request, assigns an HTN-NNNNN code, and notifies matching tutors. You\'ll get a push when it\'s live.'**
  String get requestFooter;

  /// No description provided for @requestSuccessSnack.
  ///
  /// In en, this message translates to:
  /// **'Request sent. Admin will review and publish soon.'**
  String get requestSuccessSnack;

  /// No description provided for @requestTitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'Tutor needed in {area}'**
  String requestTitlePrefix(String area);

  /// No description provided for @coinPacksIntro.
  ///
  /// In en, this message translates to:
  /// **'Coins are used inside the app — to apply to vacancies, unlock contacts, and boost your listing. Tuition fees are settled off-platform.'**
  String get coinPacksIntro;

  /// No description provided for @coinPackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} coins'**
  String coinPackSubtitle(int count);

  /// No description provided for @coinPackSubtitleWithBonus.
  ///
  /// In en, this message translates to:
  /// **'{count} coins · {bonus}'**
  String coinPackSubtitleWithBonus(int count, String bonus);

  /// No description provided for @coinPackBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get coinPackBuy;

  /// No description provided for @topUpFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not start payment.'**
  String get topUpFailedGeneric;

  /// No description provided for @coinPackPaymentInitiated.
  ///
  /// In en, this message translates to:
  /// **'Payment of {price} via {provider} initiated — coins arrive on confirmation.'**
  String coinPackPaymentInitiated(String price, String provider);

  /// No description provided for @payWithTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay with'**
  String get payWithTitle;

  /// No description provided for @payProviderHint.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be taken to the provider to complete the payment. Coins are credited the moment we receive the confirmation.'**
  String get payProviderHint;

  /// No description provided for @draftBannerPublished.
  ///
  /// In en, this message translates to:
  /// **'Your profile is live. Edits auto-save and re-publish.'**
  String get draftBannerPublished;

  /// No description provided for @draftBannerDraft.
  ///
  /// In en, this message translates to:
  /// **'Your profile is in draft mode. Complete all steps to publish and go live.'**
  String get draftBannerDraft;

  /// No description provided for @subjectsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No subjects added yet. Tap \"Add subject\" to start.'**
  String get subjectsEmpty;

  /// No description provided for @addSubject.
  ///
  /// In en, this message translates to:
  /// **'Add subject'**
  String get addSubject;

  /// No description provided for @subjectsRequireLevel.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one student level above to add subjects.'**
  String get subjectsRequireLevel;

  /// No description provided for @subjectHint.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subjectHint;

  /// No description provided for @priceHint.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceHint;

  /// No description provided for @educationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add your degrees, schools, fields of study.'**
  String get educationEmpty;

  /// No description provided for @addEducation.
  ///
  /// In en, this message translates to:
  /// **'Add education'**
  String get addEducation;

  /// No description provided for @experienceEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add teaching or work experience.'**
  String get experienceEmpty;

  /// No description provided for @addExperience.
  ///
  /// In en, this message translates to:
  /// **'Add experience'**
  String get addExperience;

  /// No description provided for @certificatesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add certificates and awards.'**
  String get certificatesEmpty;

  /// No description provided for @addCertificate.
  ///
  /// In en, this message translates to:
  /// **'Add certificate'**
  String get addCertificate;

  /// No description provided for @degreeLabel.
  ///
  /// In en, this message translates to:
  /// **'Degree'**
  String get degreeLabel;

  /// No description provided for @institutionLabel.
  ///
  /// In en, this message translates to:
  /// **'Institution'**
  String get institutionLabel;

  /// No description provided for @fieldOfStudyLabel.
  ///
  /// In en, this message translates to:
  /// **'Field of study'**
  String get fieldOfStudyLabel;

  /// No description provided for @startYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Start year'**
  String get startYearLabel;

  /// No description provided for @endYearLabel.
  ///
  /// In en, this message translates to:
  /// **'End year'**
  String get endYearLabel;

  /// No description provided for @roleTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role title'**
  String get roleTitleLabel;

  /// No description provided for @organizationLabel.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organizationLabel;

  /// No description provided for @certificateTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get certificateTitleLabel;

  /// No description provided for @issuerLabel.
  ///
  /// In en, this message translates to:
  /// **'Issuer'**
  String get issuerLabel;

  /// No description provided for @yearAwardedLabel.
  ///
  /// In en, this message translates to:
  /// **'Year awarded'**
  String get yearAwardedLabel;

  /// No description provided for @attachCertificateLabel.
  ///
  /// In en, this message translates to:
  /// **'Attach certificate (PDF / image)'**
  String get attachCertificateLabel;

  /// No description provided for @attachCertificateNotReady.
  ///
  /// In en, this message translates to:
  /// **'File upload UI ships when Supabase Storage is configured.'**
  String get attachCertificateNotReady;

  /// No description provided for @removeAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeAction;

  /// No description provided for @timeBandPre10am.
  ///
  /// In en, this message translates to:
  /// **'Pre 10 am'**
  String get timeBandPre10am;

  /// No description provided for @timeBandMidday.
  ///
  /// In en, this message translates to:
  /// **'10 am – 5 pm'**
  String get timeBandMidday;

  /// No description provided for @timeBandAfter5pm.
  ///
  /// In en, this message translates to:
  /// **'After 5 pm'**
  String get timeBandAfter5pm;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @pricePeriodHour.
  ///
  /// In en, this message translates to:
  /// **'/hour'**
  String get pricePeriodHour;

  /// No description provided for @pricePeriodDay.
  ///
  /// In en, this message translates to:
  /// **'/day'**
  String get pricePeriodDay;

  /// No description provided for @pricePeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get pricePeriodMonth;

  /// No description provided for @pricePeriodSession.
  ///
  /// In en, this message translates to:
  /// **'/session'**
  String get pricePeriodSession;

  /// No description provided for @wizardStepIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get wizardStepIdentity;

  /// No description provided for @wizardStepTeachingMode.
  ///
  /// In en, this message translates to:
  /// **'Teaching mode'**
  String get wizardStepTeachingMode;

  /// No description provided for @wizardStepWhereYouTeach.
  ///
  /// In en, this message translates to:
  /// **'Where you teach'**
  String get wizardStepWhereYouTeach;

  /// No description provided for @wizardStepLevelsYouTeach.
  ///
  /// In en, this message translates to:
  /// **'Levels you teach'**
  String get wizardStepLevelsYouTeach;

  /// No description provided for @wizardStepSubjectsPrices.
  ///
  /// In en, this message translates to:
  /// **'Subjects & prices'**
  String get wizardStepSubjectsPrices;

  /// No description provided for @wizardStepAboutYou.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get wizardStepAboutYou;

  /// No description provided for @wizardStepAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get wizardStepAvailability;

  /// No description provided for @wizardAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Tutor onboarding — {step}/{total}'**
  String wizardAppBarTitle(int step, int total);

  /// No description provided for @backAction.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backAction;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @finishAction.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishAction;

  /// No description provided for @wizardIdentitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your name and contact were captured at registration. Add a photo and demographic details from Profile Settings later — they\'re optional now.'**
  String get wizardIdentitySubtitle;

  /// No description provided for @wizardTeachingModeTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you teach?'**
  String get wizardTeachingModeTitle;

  /// No description provided for @wizardTeachingModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Online-only tutors are not pinned on the map — they still appear in search.'**
  String get wizardTeachingModeSubtitle;

  /// No description provided for @wizardServiceAreaSkipTitle.
  ///
  /// In en, this message translates to:
  /// **'Online-only — no service area needed'**
  String get wizardServiceAreaSkipTitle;

  /// No description provided for @wizardServiceAreaSkipSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You teach online. Skip this step.'**
  String get wizardServiceAreaSkipSubtitle;

  /// No description provided for @wizardServiceAreaTitle.
  ///
  /// In en, this message translates to:
  /// **'Where do you teach?'**
  String get wizardServiceAreaTitle;

  /// No description provided for @wizardServiceAreaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Used to match students near you. The exact address is private.'**
  String get wizardServiceAreaSubtitle;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// No description provided for @areaChowkLabel.
  ///
  /// In en, this message translates to:
  /// **'Area / chowk (e.g., Baneshwor)'**
  String get areaChowkLabel;

  /// No description provided for @areaChowkLabelShort.
  ///
  /// In en, this message translates to:
  /// **'Area / chowk'**
  String get areaChowkLabelShort;

  /// No description provided for @travelRadiusPrefix.
  ///
  /// In en, this message translates to:
  /// **'Travel radius: {km} km'**
  String travelRadiusPrefix(int km);

  /// No description provided for @kmSuffix.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String kmSuffix(int km);

  /// No description provided for @wizardLevelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Which student levels can you teach?'**
  String get wizardLevelsTitle;

  /// No description provided for @wizardLevelsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick all that apply. Students filter the map by their own level.'**
  String get wizardLevelsSubtitle;

  /// No description provided for @wizardSubjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Subjects offered'**
  String get wizardSubjectsTitle;

  /// No description provided for @wizardSubjectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For each level you teach, add the subjects and the price (per hour, day, month, or session). The lowest price across your offerings is shown as the \"from\" rate on tutor cards.'**
  String get wizardSubjectsSubtitle;

  /// No description provided for @tutorProfilePhoneBanWarning.
  ///
  /// In en, this message translates to:
  /// **'Do not include phone numbers, WhatsApp links, or email addresses. Accounts that do will be blocked.'**
  String get tutorProfilePhoneBanWarning;

  /// No description provided for @tutorProfilePhoneBanWarningBio.
  ///
  /// In en, this message translates to:
  /// **'Do not include phone numbers, WhatsApp links, or email addresses in the bio fields. Accounts that do will be blocked.'**
  String get tutorProfilePhoneBanWarningBio;

  /// No description provided for @aboutMeLabel.
  ///
  /// In en, this message translates to:
  /// **'About me'**
  String get aboutMeLabel;

  /// No description provided for @aboutMeHintWizard.
  ///
  /// In en, this message translates to:
  /// **'A short bio (min 100 chars for completion)'**
  String get aboutMeHintWizard;

  /// No description provided for @aboutMeHintShort.
  ///
  /// In en, this message translates to:
  /// **'A short bio'**
  String get aboutMeHintShort;

  /// No description provided for @aboutSessionsLabel.
  ///
  /// In en, this message translates to:
  /// **'About my sessions'**
  String get aboutSessionsLabel;

  /// No description provided for @aboutSessionsHintWizard.
  ///
  /// In en, this message translates to:
  /// **'How you teach (min 50 chars)'**
  String get aboutSessionsHintWizard;

  /// No description provided for @aboutSessionsHintShort.
  ///
  /// In en, this message translates to:
  /// **'How you teach'**
  String get aboutSessionsHintShort;

  /// No description provided for @qualificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Qualifications'**
  String get qualificationsLabel;

  /// No description provided for @qualificationsHintWizard.
  ///
  /// In en, this message translates to:
  /// **'Degrees, certifications (min 30 chars)'**
  String get qualificationsHintWizard;

  /// No description provided for @qualificationsHintShort.
  ///
  /// In en, this message translates to:
  /// **'Degrees, certifications'**
  String get qualificationsHintShort;

  /// No description provided for @wizardAvailabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'When are you available?'**
  String get wizardAvailabilityTitle;

  /// No description provided for @wizardAvailabilitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap a cell to toggle. Tap a row label (e.g., \"Pre 10 am\") to toggle the whole row.'**
  String get wizardAvailabilitySubtitle;

  /// No description provided for @settingsAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile settings'**
  String get settingsAppBarTitle;

  /// No description provided for @settingsTabPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get settingsTabPersonal;

  /// No description provided for @settingsTabEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get settingsTabEducation;

  /// No description provided for @settingsTabSubjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get settingsTabSubjects;

  /// No description provided for @settingsTabAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get settingsTabAvailability;

  /// No description provided for @settingsTabVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get settingsTabVerification;

  /// No description provided for @autoSavedLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto-saved'**
  String get autoSavedLabel;

  /// No description provided for @saveAndPublishCta.
  ///
  /// In en, this message translates to:
  /// **'Save & Publish'**
  String get saveAndPublishCta;

  /// No description provided for @saveChangesCta.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChangesCta;

  /// No description provided for @taglineLabel.
  ///
  /// In en, this message translates to:
  /// **'Tagline'**
  String get taglineLabel;

  /// No description provided for @taglineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A one-line headline shown on your card.'**
  String get taglineSubtitle;

  /// No description provided for @settingsAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get settingsAddressTitle;

  /// No description provided for @settingsAddressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The full address is private. Only the area name is shown publicly.'**
  String get settingsAddressSubtitle;

  /// No description provided for @settingsLanguagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Languages I know'**
  String get settingsLanguagesTitle;

  /// No description provided for @settingsEducationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional. Degrees, schools, fields of study.'**
  String get settingsEducationSubtitle;

  /// No description provided for @settingsExperienceTitle.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get settingsExperienceTitle;

  /// No description provided for @settingsExperienceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional. Past teaching or work roles.'**
  String get settingsExperienceSubtitle;

  /// No description provided for @settingsCertificatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Certificates & Awards'**
  String get settingsCertificatesTitle;

  /// No description provided for @settingsCertificatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional. Boosts the verified-badge review.'**
  String get settingsCertificatesSubtitle;

  /// No description provided for @settingsSubjectsListedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For each level, list the subjects and prices.'**
  String get settingsSubjectsListedSubtitle;

  /// No description provided for @settingsAvailabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly availability'**
  String get settingsAvailabilityTitle;

  /// No description provided for @settingsAvailabilitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap a cell to toggle. Row labels toggle the entire row.'**
  String get settingsAvailabilitySubtitle;

  /// No description provided for @verifyCitizenshipTitle.
  ///
  /// In en, this message translates to:
  /// **'Citizenship'**
  String get verifyCitizenshipTitle;

  /// No description provided for @verifyCitizenshipSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload front + back. Stored in a private Supabase Storage bucket; only the admin can view it.'**
  String get verifyCitizenshipSubtitle;

  /// No description provided for @verifyUploadCitizenship.
  ///
  /// In en, this message translates to:
  /// **'Upload citizenship'**
  String get verifyUploadCitizenship;

  /// No description provided for @verifySelfieTitle.
  ///
  /// In en, this message translates to:
  /// **'Selfie holding citizenship'**
  String get verifySelfieTitle;

  /// No description provided for @verifySelfieSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Anti-spoof check used by the admin during verification.'**
  String get verifySelfieSubtitle;

  /// No description provided for @verifyUploadSelfie.
  ///
  /// In en, this message translates to:
  /// **'Upload selfie'**
  String get verifyUploadSelfie;

  /// No description provided for @verifyStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get verifyStatusTitle;

  /// No description provided for @verifyStatusNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started — submit your documents to begin review.'**
  String get verifyStatusNotStarted;

  /// No description provided for @verifyUploadNotReady.
  ///
  /// In en, this message translates to:
  /// **'{kind} upload UI wires to Supabase Storage when buckets are configured.'**
  String verifyUploadNotReady(String kind);

  /// No description provided for @accountBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account is restricted'**
  String get accountBlockedTitle;

  /// No description provided for @accountBlockedReason.
  ///
  /// In en, this message translates to:
  /// **'Your account has been suspended or banned. Contact the admin to appeal.'**
  String get accountBlockedReason;

  /// No description provided for @contactAdminOnWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Contact admin on WhatsApp'**
  String get contactAdminOnWhatsApp;

  /// No description provided for @openThisUrl.
  ///
  /// In en, this message translates to:
  /// **'Open this URL: {url}'**
  String openThisUrl(String url);

  /// No description provided for @showPasswordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPasswordTooltip;

  /// No description provided for @hidePasswordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePasswordTooltip;

  /// No description provided for @starRatingTooltip.
  ///
  /// In en, this message translates to:
  /// **'{stars, plural, one{Rate {stars} star} other{Rate {stars} stars}}'**
  String starRatingTooltip(int stars);

  /// No description provided for @wizardPrevStepTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous step'**
  String get wizardPrevStepTooltip;

  /// No description provided for @mapPinSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, {distance}{verified}'**
  String mapPinSemantics(String name, String distance, String verified);

  /// No description provided for @mapPinVerifiedSuffix.
  ///
  /// In en, this message translates to:
  /// **', verified tutor'**
  String get mapPinVerifiedSuffix;

  /// No description provided for @balanceCardSemantics.
  ///
  /// In en, this message translates to:
  /// **'Current balance, {count, plural, one{{count} coin} other{{count} coins}}'**
  String balanceCardSemantics(int count);

  /// No description provided for @tutorCardSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, {area}, {distance}{verified}{rating}'**
  String tutorCardSemantics(
    String name,
    String area,
    String distance,
    String verified,
    String rating,
  );

  /// No description provided for @tutorCardRatingSuffix.
  ///
  /// In en, this message translates to:
  /// **', rated {average} out of 5 from {count, plural, one{{count} review} other{{count} reviews}}'**
  String tutorCardRatingSuffix(String average, int count);

  /// No description provided for @notificationBellSemantics.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Notifications, no unread} one{Notifications, {count} unread} other{Notifications, {count} unread}}'**
  String notificationBellSemantics(int count);

  /// No description provided for @draftBannerSemantics.
  ///
  /// In en, this message translates to:
  /// **'{status}, {percent} percent complete'**
  String draftBannerSemantics(String status, int percent);

  /// No description provided for @notificationCardSemantics.
  ///
  /// In en, this message translates to:
  /// **'{kind}, {title}, {time}{readState}'**
  String notificationCardSemantics(
    String kind,
    String title,
    String time,
    String readState,
  );

  /// No description provided for @notificationUnreadSuffix.
  ///
  /// In en, this message translates to:
  /// **', unread'**
  String get notificationUnreadSuffix;

  /// No description provided for @vacancyCardSemantics.
  ///
  /// In en, this message translates to:
  /// **'{code}, {title}, {area}, {salary}{applied}'**
  String vacancyCardSemantics(
    String code,
    String title,
    String area,
    String salary,
    String applied,
  );

  /// No description provided for @vacancyAlreadyAppliedSuffix.
  ///
  /// In en, this message translates to:
  /// **', already applied'**
  String get vacancyAlreadyAppliedSuffix;

  /// No description provided for @mapSheetHandleSemantics.
  ///
  /// In en, this message translates to:
  /// **'Tutor list, {state}, double tap to {action}'**
  String mapSheetHandleSemantics(String state, String action);

  /// No description provided for @mapSheetExpanded.
  ///
  /// In en, this message translates to:
  /// **'expanded'**
  String get mapSheetExpanded;

  /// No description provided for @mapSheetCollapsed.
  ///
  /// In en, this message translates to:
  /// **'collapsed'**
  String get mapSheetCollapsed;

  /// No description provided for @mapSheetActionExpand.
  ///
  /// In en, this message translates to:
  /// **'expand'**
  String get mapSheetActionExpand;

  /// No description provided for @mapSheetActionCollapse.
  ///
  /// In en, this message translates to:
  /// **'collapse'**
  String get mapSheetActionCollapse;
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
