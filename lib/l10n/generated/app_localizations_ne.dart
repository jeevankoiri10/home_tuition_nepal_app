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

  @override
  String get walletTitle => 'सिक्का वालेट';

  @override
  String get walletBuyCoins => 'सिक्का किन्नुहोस्';

  @override
  String get walletTransactionHistory => 'कारोबार इतिहास';

  @override
  String get walletNoTransactions => 'अहिलेसम्म कुनै कारोबार छैन।';

  @override
  String get ledgerColDate => 'मिति';

  @override
  String get ledgerColDetails => 'विवरण';

  @override
  String get ledgerColCoins => 'सिक्का';

  @override
  String get unlockNotSignedIn => 'पहिले साइन इन गर्नुहोस्।';

  @override
  String unlockTitle(int cost) {
    return '$cost सिक्कामा सम्पर्क खोल्नुहोस्';
  }

  @override
  String get unlockBody =>
      'खोलेपछि तपाईं फोन वा WhatsApp मार्फत शिक्षकलाई सम्पर्क गर्न सक्नुहुन्छ। यो एक-पटकको शुल्क हो — उही शिक्षकका लागि पुनः खोल्नु निःशुल्क।';

  @override
  String get unlockNeedMoreCoins => 'थप सिक्का चाहियो। थप गर्नुहोस्।';

  @override
  String get unlockFailedGeneric => 'सम्पर्क खोल्न सकिएन।';

  @override
  String get workingEllipsis => 'गर्दैछ…';

  @override
  String unlockConfirmCta(int cost) {
    return 'पुष्टि — $cost सिक्का';
  }

  @override
  String get buyCoinsLink => 'सिक्का किन्नुहोस्';

  @override
  String get unlockSuccess => 'सम्पर्क खोलियो';

  @override
  String unlockNewBalance(int balance) {
    return 'नयाँ रकम: $balance सिक्का';
  }

  @override
  String get openChat => 'च्याट खोल्नुहोस्';

  @override
  String get callLabel => 'कल';

  @override
  String get whatsAppLabel => 'WhatsApp';

  @override
  String get unlockCallPhase7Hint =>
      'फोन नम्बर खुलासा फेज ७ का एडमिन म्याचसँगै आउँछ।';

  @override
  String get unlockWhatsAppPhase7Hint => 'WhatsApp लिङ्क फेज ७ मा जोडिनेछ।';

  @override
  String get leaveReview => 'समीक्षा छोड्नुहोस्';

  @override
  String get doneLabel => 'भयो';

  @override
  String get notificationsTitle => 'सूचनाहरू';

  @override
  String get notificationsMarkAllRead => 'सबै पढिएको चिन्ह लगाउनुहोस्';

  @override
  String get notificationsTabAll => 'सबै';

  @override
  String notificationsTabAllCount(int count) {
    return 'सबै ($count)';
  }

  @override
  String get notificationsTabUnread => 'नपढिएका';

  @override
  String notificationsTabUnreadCount(int count) {
    return 'नपढिएका ($count)';
  }

  @override
  String get notificationsTabRead => 'पढिएका';

  @override
  String get notificationsEmpty => 'अहिलेसम्म कुनै सूचना छैन।';

  @override
  String get notificationsEmptyUnread => 'नपढिएका सूचना छैनन्।';

  @override
  String get notificationsEmptyRead => 'पढिएका सूचना छैनन्।';

  @override
  String get relativeJustNow => 'अहिले';

  @override
  String relativeMinutesAgo(int count) {
    return '$count मिनेट अघि';
  }

  @override
  String relativeHoursAgo(int count) {
    return '$count घण्टा अघि';
  }

  @override
  String relativeDaysAgo(int count) {
    return '$count दिन अघि';
  }

  @override
  String get notifKindNewJobPosted => 'नयाँ जागिर पोस्ट';

  @override
  String get notifKindApplicationShortlisted => 'आवेदन छनोट';

  @override
  String get notifKindApplicationHired => 'तपाईं छनोट हुनुभयो';

  @override
  String get notifKindContactRevealed => 'सम्पर्क खुलासा';

  @override
  String get notifKindIdentityApproved => 'पहिचान प्रमाणीकरण स्वीकृत';

  @override
  String get notifKindIdentityRejected => 'प्रमाणीकरण फेरि हेर्नुहोस्';

  @override
  String get notifKindCoinCredited => 'सिक्का थपियो';

  @override
  String get notifKindCoinDebited => 'सिक्का घटाइयो';

  @override
  String get notifKindNewReview => 'नयाँ समीक्षा';

  @override
  String get notifKindSystem => 'सूचना';

  @override
  String get chatTitleFallback => 'च्याट';

  @override
  String get chatOpenError => 'च्याट खोल्न सकिएन।';

  @override
  String get chatComposerHint => 'सन्देश लेख्नुहोस्…';

  @override
  String get chatEmptyHint =>
      'नमस्ते भन्नुहोस् — तर फोन नम्बर वा इमेल साझा नगर्नुहोस्।';

  @override
  String reviewRateTitle(String name) {
    return '$name लाई मूल्याङ्कन गर्नुहोस्';
  }

  @override
  String get reviewPhoneBanWarning =>
      'समीक्षामा फोन नम्बर वा सम्पर्क विवरण नराख्नुहोस्।';

  @override
  String get reviewTextLabel =>
      'अरू विद्यार्थीलाई यो शिक्षकको बारेमा बताउनुहोस्';

  @override
  String get reviewTextHint => 'वैकल्पिक। स्पष्ट र सम्मानजनक रहनुहोस्।';

  @override
  String get reviewSubmit => 'समीक्षा पेस गर्नुहोस्';

  @override
  String get reviewSending => 'पठाउँदै…';

  @override
  String get reviewThanks => 'तपाईंको समीक्षाका लागि धन्यवाद!';

  @override
  String get reviewGateNotMet => 'पहिले यो शिक्षकलाई खोल्नुहोस्।';

  @override
  String get reviewPhoneRejected => 'फोन नम्बर र सम्पर्क विवरण स्वीकार्य छैन।';

  @override
  String get reviewFailedGeneric => 'समीक्षा पेस गर्न सकिएन।';

  @override
  String get notRated => 'मूल्याङ्कन भएको छैन';

  @override
  String get filterVerifiedOnly => 'प्रमाणित मात्र';

  @override
  String get filterAvailableNow => 'अहिले उपलब्ध';

  @override
  String get filterLevelTooltip => 'विद्यार्थी तह';

  @override
  String get filterAllLevels => 'सबै तह';

  @override
  String get filterTeachingModeTooltip => 'पढाउने तरिका';

  @override
  String get filterAnyMode => 'जुनसुकै';

  @override
  String get filterRadiusTooltip => 'क्षेत्र';

  @override
  String filterRadiusWithinKm(int km) {
    return '$km किमी भित्र';
  }

  @override
  String filterRadiusKm(int km) {
    return '$km किमी';
  }

  @override
  String get tutorAvailable => 'उपलब्ध';

  @override
  String get contactLabel => 'सम्पर्क';

  @override
  String get teachingModeOnline => 'अनलाइन';

  @override
  String get teachingModeOffline => 'अफलाइन (आफैं भेटेर)';

  @override
  String get teachingModeBoth => 'दुवै';

  @override
  String get studentLevelBelowClass9 => 'कक्षा ९ भन्दा कम';

  @override
  String get studentLevelSee => 'SEE';

  @override
  String get studentLevelPlus2 => '+२';

  @override
  String get studentLevelALevel => 'A Level';

  @override
  String get vacanciesTitle => 'खालीस्थानहरू';

  @override
  String get refreshTooltip => 'ताजा गर्नुहोस्';

  @override
  String get vacanciesLoadError => 'खालीस्थान लोड गर्न सकिएन।';

  @override
  String get vacanciesEmpty =>
      'अहिले खुला खालीस्थान छैन। ताजा गर्न तान्नुहोस्।';

  @override
  String get vacancyApplyLabel => 'आवेदन दिनुहोस्';

  @override
  String get vacancyAppliedLabel => 'आवेदन भयो';

  @override
  String get vacancyAlreadyApplied => 'पहिले नै आवेदन भएको';

  @override
  String vacancyGradePrefix(String grade) {
    return 'कक्षा: $grade';
  }

  @override
  String vacancySubjectsPrefix(String subjects) {
    return 'विषयहरू: $subjects';
  }

  @override
  String vacancyNumStudentsPrefix(int count) {
    return 'विद्यार्थी सङ्ख्या: $count';
  }

  @override
  String vacancyTimePrefix(String text) {
    return 'समय: $text';
  }

  @override
  String vacancyGenderPrefPrefix(String label) {
    return 'लिङ्ग प्राथमिकता: $label';
  }

  @override
  String vacancyModePrefix(String label) {
    return 'तरिका: $label';
  }

  @override
  String get vacancyNotesHeader => 'टिप्पणी';

  @override
  String get vacancyPostedByAdmin => 'Home Tuition Nepal एडमिनद्वारा पोस्ट।';

  @override
  String get vacancyTitleFallback => 'खालीस्थान';

  @override
  String get vacancyNotFound => 'खालीस्थान भेटिएन।';

  @override
  String applySheetTitle(String label) {
    return '$label मा आवेदन';
  }

  @override
  String get applyPhoneBanWarning =>
      'कभर नोटमा फोन नम्बर वा सम्पर्क विवरण नराख्नुहोस्। राख्ने खाताहरू ब्लक हुनेछन्।';

  @override
  String get applyCoverLabel => 'कभर नोट';

  @override
  String get applyCoverHint => 'किन तपाईं उपयुक्त हुनुहुन्छ?';

  @override
  String get applyCoverRequired => 'छोटो कभर नोट लेख्नुहोस्।';

  @override
  String get applyCoverPhoneViolation =>
      'फोन नम्बर वा सम्पर्क विवरण हटाउनुहोस्।';

  @override
  String get applyRateLabel => 'अपेक्षित दर (NPR, वैकल्पिक)';

  @override
  String get applySending => 'पठाउँदै…';

  @override
  String applyButtonLabel(int cost) {
    String _temp0 = intl.Intl.pluralLogic(
      cost,
      locale: localeName,
      other: 'आवेदन — $cost सिक्का',
      one: 'आवेदन — $cost सिक्का',
    );
    return '$_temp0';
  }

  @override
  String get applySuccessSnack => 'आवेदन पठाइयो। एडमिनले हेर्नेछन्।';

  @override
  String get jobModeInPerson => 'आफैं भेटेर';

  @override
  String get jobModeOnline => 'अनलाइन';

  @override
  String get jobModeEither => 'जुनसुकै';

  @override
  String get genderPrefAny => 'जुनसुकै';

  @override
  String get genderPrefMale => 'पुरुष';

  @override
  String get genderPrefFemale => 'महिला';
}
