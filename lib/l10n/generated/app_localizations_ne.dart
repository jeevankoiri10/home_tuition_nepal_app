// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get appName => 'होम ट्युशन नेपाल';

  @override
  String get appTagline => 'तपाईंको क्षेत्रका शिक्षक खोज्नुहोस्।';

  @override
  String get publisher => 'KTM academy द्वारा';

  @override
  String get languagePickerTitle => 'आफ्नो भाषा छान्नुहोस्';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageNepali => 'नेपाली';

  @override
  String get continueLabel => 'अगाडि बढ्नुहोस्';

  @override
  String get loginTitle => 'फेरि स्वागत छ';

  @override
  String get loginSubtitle =>
      'तपाईंको क्षेत्रका शिक्षक खोज्न साइन इन गर्नुहोस्।';

  @override
  String get registerTitle => 'खाता बनाउनुहोस्';

  @override
  String get registerSubtitle => 'सुरु गर्न आफ्नो विवरण भर्नुहोस्।';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get emailLabel => 'इमेल';

  @override
  String get emailInvalid => 'मान्य इमेल हाल्नुहोस्।';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get passwordRequired => 'आफ्नो पासवर्ड हाल्नुहोस्।';

  @override
  String get loginSubmit => 'साइन इन';

  @override
  String get loginToRegister => 'खाता छैन? बनाउनुहोस्';

  @override
  String get loginErrorInvalidCredentials => 'इमेल वा पासवर्ड मिलेन।';

  @override
  String get errorGeneric => 'केही गडबड भयो। फेरि प्रयास गर्नुहोस्।';

  @override
  String get firstNameLabel => 'नाम';

  @override
  String get lastNameLabel => 'थर';

  @override
  String get emailAddressLabel => 'इमेल ठेगाना';

  @override
  String get phoneNumberLabel => 'मोबाइल नम्बर';

  @override
  String get phoneNumberHint => '98XXXXXXXX';

  @override
  String get confirmPasswordLabel => 'पासवर्ड पुष्टि गर्नुहोस्';

  @override
  String get nameInvalid => 'आवश्यक (बढीमा ४०)।';

  @override
  String get phoneInvalid => '१० अङ्कको नेपाली मोबाइल हाल्नुहोस् (९८… / ९७…)।';

  @override
  String get passwordTooShort => 'कम्तीमा ८ अक्षर।';

  @override
  String get passwordWeak => 'पासवर्डमा अक्षर र अङ्क दुवै हुनुपर्छ।';

  @override
  String get confirmPasswordMismatch => 'पासवर्ड मिलेन।';

  @override
  String get roleLabel => 'भूमिका';

  @override
  String get roleTutor => 'म शिक्षक हुँ';

  @override
  String get roleTutorSubtitle => 'म पढाउन चाहन्छु';

  @override
  String get roleStudent => 'म विद्यार्थी हुँ';

  @override
  String get roleStudentSubtitle => 'म शिक्षक खोज्दैछु';

  @override
  String get rolePermanentNote => 'तपाईंको भूमिका यो खातामा स्थायी हुनेछ।';

  @override
  String get tosAcceptLabel => 'म सर्तहरू र गोपनीयता नीति स्वीकार गर्छु।';

  @override
  String get cocAcceptLabel => 'म शिक्षकहरूको आचारसंहिता स्वीकार गर्छु।';

  @override
  String get pickRoleSnack => 'अगाडि बढ्न भूमिका छान्नुहोस्।';

  @override
  String get tosRequiredSnack => 'तपाईंले सर्तहरू स्वीकार गर्नुपर्छ।';

  @override
  String get cocRequiredSnack => 'शिक्षकहरूले आचारसंहिता स्वीकार गर्नुपर्छ।';

  @override
  String get registerSubmit => 'दर्ता गर्नुहोस्';

  @override
  String get registerToLogin => 'पहिले नै दर्ता हुनुहुन्छ? साइन इन';

  @override
  String get registerErrorSignupFailed =>
      'खाता बनाउन सकिएन। इमेल पहिले नै प्रयोग भएको हुन सक्छ।';

  @override
  String get registerErrorCocRequired =>
      'शिक्षकहरूले आचारसंहिता स्वीकार गर्नुपर्छ।';

  @override
  String get verifyEmailTitle => 'इमेल प्रमाणित गर्नुहोस्';

  @override
  String verifyEmailInstruction(String email) {
    return 'हामीले $email मा प्रमाणीकरण लिङ्क पठाएका छौं। यही उपकरणबाट खोल्नुहोस्, अनि फर्केर \'मैले प्रमाणित गरें\' थिच्नुहोस्।';
  }

  @override
  String get verifyEmailRefresh => 'मैले प्रमाणित गरें';

  @override
  String get verifyEmailResend => 'इमेल पुनः पठाउनुहोस्';

  @override
  String get verifyEmailResentSnack => 'नयाँ प्रमाणीकरण इमेल पठाइयो।';

  @override
  String get verifyEmailNotYet =>
      'अहिलेसम्म प्रमाणीकरण देखिएन — इमेल खोल्नुहोस् र लिङ्क थिच्नुहोस्।';

  @override
  String get verifyEmailErrorNoSession => 'सेसन सकियो। पुनः साइन इन गर्नुहोस्।';

  @override
  String verifyEmailResendCooldown(int seconds) {
    return '$seconds सेकेन्डपछि पुनः पठाउनुहोस्';
  }

  @override
  String get studentHomeTitle => 'विद्यार्थी होम';

  @override
  String get tutorHomeTitle => 'शिक्षक होम';

  @override
  String get signOutTooltip => 'साइन आउट';

  @override
  String homeWelcome(String name) {
    return 'स्वागत छ, $name';
  }

  @override
  String homeHandle(String handle) {
    return 'ह्यान्डल: $handle';
  }

  @override
  String get studentMapPlaceholder =>
      'क्षेत्र-आधारित म्याप (मुख्य सुविधा) फेज ४ मा आउँछ।';

  @override
  String get previewLabel => 'पूर्वावलोकन';

  @override
  String get currentBalanceLabel => 'हालको रकम';

  @override
  String coinsSuffix(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सिक्का',
      one: '$count सिक्का',
    );
    return '$_temp0';
  }

  @override
  String get tutorActionCompleteProfileTitle => 'प्रोफाइल पूरा गर्नुहोस्';

  @override
  String get tutorActionCompleteProfileSubtitle =>
      '७ चरणको विजार्डबाट आफ्नो शिक्षक प्रोफाइल प्रकाशित गर्नुहोस्।';

  @override
  String get tutorActionProfileSettingsTitle => 'प्रोफाइल सेटिङ';

  @override
  String get tutorActionProfileSettingsSubtitle =>
      'विषय, मूल्य, उपलब्धता, मेरो बारेमा, र प्रमाणपत्र सम्पादन गर्नुहोस्।';

  @override
  String get tutorActionVacanciesTitle => 'खालीस्थानहरू';

  @override
  String get tutorActionVacanciesSubtitle =>
      'खुला HTN-NNNNN खालीस्थानहरू हेर्नुहोस् र १ सिक्कामा आवेदन दिनुहोस्।';

  @override
  String get tutorActionWalletTitle => 'सिक्का वालेट';

  @override
  String get tutorActionWalletSubtitle =>
      'रकम, इतिहास हेर्नुहोस् र सिक्का किन्नुहोस्।';

  @override
  String get tutorActionBoostTitle => 'लिस्टिङ बूस्ट (२४ घण्टा)';

  @override
  String get tutorActionBoostSubtitle =>
      'हाइलाइट पिन र फिडको शीर्ष स्थान पाउनुहोस्।';

  @override
  String tutorBoostSuccessSnack(int balance) {
    return 'लिस्टिङ २४ घण्टाका लागि बूस्ट भयो · रकम: $balance';
  }

  @override
  String get tutorBoostFailedSnack => 'लिस्टिङ बूस्ट गर्न सकिएन।';

  @override
  String get tutorBoostInsufficientSnack => 'बूस्टका लागि सिक्का अपुग।';

  @override
  String get tutorPhasesNote =>
      'पुस-नोटिफिकेसन, इन-एप च्याट, र समीक्षा फेज ८–१० मा आउँछन्।';

  @override
  String get mapTitle => 'तपाईंको नजिकका शिक्षक';

  @override
  String get mapMyPostsTooltip => 'मेरा पोस्ट';

  @override
  String get mapRecenterTooltip => 'केन्द्र मा फर्काउनुहोस्';

  @override
  String get mapRequestTutorFab => 'शिक्षक अनुरोध';

  @override
  String get mapPostJobFab => 'जागिर पोस्ट';

  @override
  String mapTutorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count शिक्षक',
      one: '$count शिक्षक',
    );
    return '$_temp0';
  }

  @override
  String get mapAllMatchesHeader => 'सबै मिलेका';

  @override
  String get mapEmptyTitle => 'तपाईंका फिल्टरमा कुनै शिक्षक भेटिएन';

  @override
  String get mapEmptyHint =>
      'क्षेत्र फराकिलो बनाउनुहोस् वा फिल्टर खुकुलो गर्नुहोस्।';
}
