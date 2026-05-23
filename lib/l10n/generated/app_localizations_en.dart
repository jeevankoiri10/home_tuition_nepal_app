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

  @override
  String get emailLabel => 'Email';

  @override
  String get emailInvalid => 'Enter a valid email.';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordRequired => 'Enter your password.';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginToRegister => 'Don\'t have an account? Create one';

  @override
  String get loginErrorInvalidCredentials => 'Email or password is incorrect.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get lastNameLabel => 'Last name';

  @override
  String get emailAddressLabel => 'Email address';

  @override
  String get phoneNumberLabel => 'Phone number';

  @override
  String get phoneNumberHint => '98XXXXXXXX';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get nameInvalid => 'Required (max 40).';

  @override
  String get phoneInvalid =>
      'Enter a valid 10-digit Nepali mobile (98… / 97…).';

  @override
  String get passwordTooShort => 'At least 8 characters.';

  @override
  String get passwordWeak => 'Password must include letters and digits.';

  @override
  String get confirmPasswordMismatch => 'Passwords do not match.';

  @override
  String get roleLabel => 'Role';

  @override
  String get roleTutor => 'I\'m a tutor';

  @override
  String get roleTutorSubtitle => 'I want to teach';

  @override
  String get roleStudent => 'I\'m a student';

  @override
  String get roleStudentSubtitle => 'I\'m looking for a tutor';

  @override
  String get rolePermanentNote => 'Your role is permanent for this account.';

  @override
  String get tosAcceptLabel =>
      'I accept the Terms of Service & Privacy Policy.';

  @override
  String get cocAcceptLabel => 'I accept the Tutors\' Code of Conduct.';

  @override
  String get pickRoleSnack => 'Pick a role to continue.';

  @override
  String get tosRequiredSnack => 'You must accept the Terms of Service.';

  @override
  String get cocRequiredSnack =>
      'Tutors must accept the Tutors\' Code of Conduct.';

  @override
  String get registerSubmit => 'Register';

  @override
  String get registerToLogin => 'Already registered? Sign in';

  @override
  String get registerErrorSignupFailed =>
      'Could not create the account. The email may already be in use.';

  @override
  String get registerErrorCocRequired =>
      'Tutors must accept the Code of Conduct.';

  @override
  String get verifyEmailTitle => 'Verify your email';

  @override
  String verifyEmailInstruction(String email) {
    return 'We sent a confirmation link to $email. Open it on this device, then come back and tap I\'ve verified.';
  }

  @override
  String get verifyEmailRefresh => 'I\'ve verified';

  @override
  String get verifyEmailResend => 'Resend email';

  @override
  String get verifyEmailResentSnack => 'A new confirmation email was sent.';

  @override
  String get verifyEmailNotYet =>
      'We can\'t see the confirmation yet — open the email and click the link.';

  @override
  String get verifyEmailErrorNoSession =>
      'Session expired. Please sign in again.';
}
