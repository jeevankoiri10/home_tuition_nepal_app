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
  String get languageToggleTooltip => 'भाषा परिवर्तन गर्नुहोस्';

  @override
  String get noticeDetailsTitle => 'सूचना';

  @override
  String get noticeDetailsNotFound => 'यो सूचना अब उपलब्ध छैन।';

  @override
  String noticeDetailsReceivedAt(String when) {
    return 'प्राप्त भयो $when';
  }

  @override
  String get filterRadiusNoLimit => 'कुनै दुरी';

  @override
  String get filterRadiusOptionNoLimit => 'सीमा छैन';

  @override
  String get settingsTitle => 'सेटिङ';

  @override
  String get settingsProfileTooltip => 'प्रोफाइल र सेटिङ';

  @override
  String get settingsLanguageSection => 'भाषा';

  @override
  String get settingsLanguageHint => 'एपको लागि मन पर्ने भाषा छान्नुहोस्।';

  @override
  String get settingsLogoutLabel => 'लग आउट';

  @override
  String get tutorSettingsProfileSection => 'तपाईंको प्रोफाइल';

  @override
  String get tutorSettingsEditProfileCta => 'प्रोफाइल अपडेट गर्नुहोस्';

  @override
  String get settingsReferralSection => 'साथीलाई रेफर गर्नुहोस्';

  @override
  String settingsReferralHint(int coins) {
    return 'आफ्नो कोड साथीलाई पठाउनुहोस्। उहाँले साइन अप गर्दा दुवैले $coins सिक्का पाउनुहुनेछ।';
  }

  @override
  String get settingsReferralCodeLabel => 'तपाईंको रेफरल कोड';

  @override
  String get settingsReferralCopy => 'कोड कपी गर्नुहोस्';

  @override
  String get settingsReferralCopied => 'कोड क्लिपबोर्डमा कपी भयो';

  @override
  String get tutorCardViewCv => 'CV हेर्नुहोस्';

  @override
  String get tutorCardCvOpenFailed => 'CV खोल्न सकिएन।';

  @override
  String get requestSubjectsCustomHint => 'अर्को विषय थप्नुहोस्';

  @override
  String get requestSubjectsCustomAdd => 'थप्नुहोस्';

  @override
  String get postJobSectionMode => 'अनलाइन वा अफलाइन?';

  @override
  String get jobModeOffline => 'अफलाइन';

  @override
  String get chatListTitle => 'च्याट';

  @override
  String get chatListEmptyTitle => 'कुनै कुराकानी छैन';

  @override
  String get chatListEmptyHint =>
      'तपाईंले सम्पर्क अनलक गर्नुभयो वा कुनै रिक्तिमा मिलाइनुभयो भने यहाँ च्याटहरू देखिनेछ।';

  @override
  String get tutorActionChatsTitle => 'च्याट';

  @override
  String get tutorActionChatsSubtitle => 'विद्यार्थीहरूसँगका कुराकानी।';

  @override
  String get tutorNavHome => 'होम';

  @override
  String get tutorNavChats => 'च्याट';

  @override
  String get tutorNavVacancies => 'रिक्ति';

  @override
  String get tutorNavSettings => 'सेटिङ';

  @override
  String get wizardServiceAreaPinHint =>
      'तपाईंले पढाउने ठाउँमा पिन आउने गरी नक्सा सार्नुहोस्।';

  @override
  String get mapPinPickerUseMyLocation => 'मेरो वर्तमान स्थान प्रयोग गर्नुहोस्';

  @override
  String get openSettingsAction => 'सेटिङ खोल्नुहोस्';

  @override
  String get locationServicesDisabledMessage =>
      'स्थान सेवा बन्द छ। आफ्नो वर्तमान स्थान प्रयोग गर्न यसलाई खोल्नुहोस्।';

  @override
  String get locationPermissionBlockedMessage =>
      'स्थानको अनुमति रोकिएको छ। आफ्नो स्थान प्रयोग गर्न सेटिङमा गई अनुमति दिनुहोस्।';

  @override
  String get locationPermissionDeniedMessage =>
      'स्थानको अनुमति दिइएन। पूर्वनिर्धारित क्षेत्र देखाइँदै छ — नक्सा तानेर आफ्नो स्थानमा राख्नुहोस्।';

  @override
  String get locationUnavailableMessage =>
      'अहिले तपाईंको स्थान पत्ता लगाउन सकिएन। पूर्वनिर्धारित क्षेत्र देखाइँदै छ — नक्सा तानेर आफ्नो स्थानमा राख्नुहोस्।';

  @override
  String subjectSectionHeading(int number) {
    return 'विषय $number';
  }

  @override
  String get subjectLevelLabel => 'तह';

  @override
  String get subjectNameLabel => 'विषय';

  @override
  String get subjectPriceLabel => 'मूल्य (NPR)';

  @override
  String get subjectPeriodLabel => 'प्रति';

  @override
  String get wizardCvUploadTitle => 'आफ्नो CV अपलोड गर्नुहोस्';

  @override
  String get wizardCvUploadSubtitle =>
      'विद्यार्थीहरूले तपाईंको प्रोफाइलबाट यो PDF डाउनलोड गर्न सक्नेछन्।';

  @override
  String get wizardCvSizeHint => 'PDF मात्र · अधिकतम ३०० KB।';

  @override
  String get wizardCvUploadButton => 'CV PDF छान्नुहोस्';

  @override
  String get wizardCvReplaceButton => 'CV बदल्नुहोस्';

  @override
  String get wizardCvCurrent => 'तपाईंको CV दाखिल भएको छ।';

  @override
  String get wizardCvUploaded => 'CV अपलोड भयो।';

  @override
  String get wizardCvTooLarge => 'CV ३०० KB भन्दा सानो हुनुपर्छ।';

  @override
  String get wizardCvReadFailed => 'छानिएको फाइल पढ्न सकिएन।';

  @override
  String get esewaSheetTitle => 'eSewa बाट तिर्नुहोस्';

  @override
  String esewaSheetSubtitle(String price) {
    return 'QR स्क्यान गर्नुहोस् वा $price तल भएको eSewa खातामा पठाएर रसिद अपलोड गर्नुहोस्।';
  }

  @override
  String get esewaPayeeNameLabel => 'नाम';

  @override
  String get esewaPayeeNumberLabel => 'eSewa नं.';

  @override
  String get esewaUploadReceipt => 'भुक्तानी रसिद अपलोड गर्नुहोस्';

  @override
  String get esewaReplaceReceipt => 'रसिद बदल्नुहोस्';

  @override
  String get esewaReceiptOnFile =>
      'रसिद अपलोड भयो — व्यवस्थापकको पुष्टि बाँकी।';

  @override
  String get esewaReceiptUploaded => 'रसिद अपलोड भयो।';

  @override
  String get esewaReceiptTooLarge => 'रसिद ५ MB भन्दा सानो हुनुपर्छ।';

  @override
  String get esewaReceiptReadFailed => 'छानिएको फाइल पढ्न सकिएन।';

  @override
  String get esewaDoneLabel => 'सकियो';

  @override
  String get esewaAdminReviewHint => 'रसिद पुष्टि भएपछि सिक्का जम्मा गरिनेछ।';

  @override
  String get esewaTopUpQueued =>
      'टप-अप पेश गरियो। रसिद पुष्टि भएपछि वालेटमा थपिनेछ।';

  @override
  String get loginChooserTitle => 'कसको रूपमा जारी राख्ने?';

  @override
  String get loginChooserSubtitle =>
      'यो इमेल शिक्षक र विद्यार्थी दुवैको रूपमा दर्ता छ। अहिले कुन रूपमा साइन इन गर्ने?';

  @override
  String get loginChooserAsTutor => 'शिक्षकको रूपमा लग इन';

  @override
  String get loginChooserAsStudent => 'विद्यार्थीको रूपमा लग इन';

  @override
  String get contractNoneHint =>
      'यहाँ सर्तहरूमा सहमत भएर सम्झौता सुरु गर्नुहोस्।';

  @override
  String get contractCompletedHint =>
      'तपाईंको अघिल्लो सम्झौता पूरा भयो। जहिले पनि नयाँ सुरु गर्न सकिन्छ।';

  @override
  String get contractStartCta => 'सम्झौता सुरु गर्नुहोस्';

  @override
  String get contractProposeTitle => 'सम्झौता प्रस्ताव गर्नुहोस्';

  @override
  String get contractProposeSubtitle =>
      'सक्रिय हुनुअघि अर्को व्यक्तिले स्वीकार गर्नुपर्छ।';

  @override
  String get contractSubjectLabel => 'विषय / के पढाउने';

  @override
  String get contractSubjectRequired =>
      'सम्झौता केका लागि हो भन्ने लेख्नुहोस्।';

  @override
  String get contractRateLabel => 'दर (NPR)';

  @override
  String get contractPeriodLabel => 'प्रति';

  @override
  String get contractScheduleLabel => 'तालिका (जस्तै आइत–शुक्र, ५ बजे)';

  @override
  String get contractProposeSubmit => 'प्रस्ताव पठाउनुहोस्';

  @override
  String get contractAccept => 'स्वीकार गर्नुहोस्';

  @override
  String get contractDecline => 'अस्वीकार गर्नुहोस्';

  @override
  String get contractCancel => 'रद्द गर्नुहोस्';

  @override
  String get contractWaitingResponse => 'जवाफको प्रतीक्षामा…';

  @override
  String get contractActiveLabel => 'सम्झौता सक्रिय';

  @override
  String get contractEndCta => 'सम्झौता अन्त्य गर्नुहोस्';

  @override
  String reviewTitle(String name) {
    return '$name लाई मूल्याङ्कन गर्नुहोस्';
  }

  @override
  String get reviewHint => 'ट्युशन कस्तो रह्यो साझा गर्नुहोस् (वैकल्पिक)।';

  @override
  String get reviewSubmit => 'समीक्षा पेस गर्नुहोस्';

  @override
  String get reviewSkip => 'अहिलेलाई छोड्नुहोस्';

  @override
  String get reviewThanks => 'तपाईंको समीक्षाका लागि धन्यवाद!';

  @override
  String get reviewsTitle => 'समीक्षाहरू';

  @override
  String get reviewsEmpty => 'अहिलेसम्म कुनै समीक्षा छैन';

  @override
  String get reviewsLoadError =>
      'समीक्षाहरू लोड गर्न सकिएन। पुनः प्रयास गर्न तान्नुहोस्।';

  @override
  String get seeReviewsAction => 'समीक्षाहरू हेर्नुहोस्';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count समीक्षाहरू',
      one: '१ समीक्षा',
      zero: 'कुनै समीक्षा छैन',
    );
    return '$_temp0';
  }

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
  String get settingsThemeSection => 'रूप';

  @override
  String get settingsThemeHint => 'एप कस्तो देखिने छान्नुहोस्।';

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
  String get googleContinue => 'Google मार्फत जारी राख्नुहोस्';

  @override
  String get googleAsStudent =>
      'विद्यार्थीको रूपमा Google मार्फत जारी राख्नुहोस्';

  @override
  String get googleAsTutor => 'ट्युटरको रूपमा Google मार्फत जारी राख्नुहोस्';

  @override
  String get orSeparator => 'वा';

  @override
  String get nextAction => 'अर्को';

  @override
  String get doneAction => 'सम्पन्न';

  @override
  String get whatsappLabel => 'WhatsApp नम्बर';

  @override
  String get onboardingContactTitle => 'तपाईंको सम्पर्क विवरण';

  @override
  String get onboardingContactSubtitle =>
      'हामी यी तपाईंलाई जोड्न प्रयोग गर्छौं। यी सार्वजनिक रूपमा देखाइँदैन।';

  @override
  String get onboardingLocationTitle => 'तपाईंको स्थान छान्नुहोस्';

  @override
  String get onboardingLocationSubtitle =>
      'तपाईं भएको ठाउँमा पिन राख्न नक्सा तान्नुहोस्, वा लोकेट बटन थिच्नुहोस्।';

  @override
  String get onboardingSelectMyLocation => 'मेरो स्थान छान्नुहोस्';

  @override
  String get wizardStepContact => 'सम्पर्क';

  @override
  String get wizardStepResume => 'बायोडाटा';

  @override
  String get accountSection => 'खाता';

  @override
  String get switchToTutorView => 'ट्युटर भ्यूमा स्विच गर्नुहोस्';

  @override
  String get switchToStudentView => 'विद्यार्थी भ्यूमा स्विच गर्नुहोस्';

  @override
  String get switchRoleSubtitle =>
      'एउटै खाता पढाउन र सिक्न दुवैमा प्रयोग गर्नुहोस्।';

  @override
  String get loginErrorInvalidCredentials => 'इमेल वा पासवर्ड मिलेन।';

  @override
  String get errorGeneric => 'केही गडबड भयो। फेरि प्रयास गर्नुहोस्।';

  @override
  String get errorNoInternet =>
      'इन्टरनेट जडान छैन। आफ्नो नेटवर्क जाँच गरी फेरि प्रयास गर्नुहोस्।';

  @override
  String get errorGoogleSignInFailed =>
      'Google मार्फत साइन इन गर्न सकिएन। केही बेरमा फेरि प्रयास गर्नुहोस्।';

  @override
  String get errorSignInCancelled =>
      'साइन इन पूरा हुनु अघि नै रद्द भयो। फेरि प्रयास गर्न Google जारी राख्नुहोस् थिच्नुहोस्।';

  @override
  String get errorSignInTimeout =>
      'साइन इन गर्न धेरै समय लाग्यो र समय सकियो। फेरि प्रयास गर्नुहोस्।';

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
  String get promoteJobAction => 'प्रवर्द्धन (२४घ)';

  @override
  String get promoteJobConfirmTitle => 'यो पोस्ट प्रवर्द्धन गर्ने?';

  @override
  String promoteJobConfirmBody(int cost) {
    return 'यो पोस्टलाई २४ घण्टा खोजको शीर्षमा पुर्‍याउन $cost सिक्का खर्च गर्नुहोस्।';
  }

  @override
  String get promoteJobConfirmCta => 'प्रवर्द्धन गर्नुहोस्';

  @override
  String promoteJobSuccessSnack(int balance) {
    return 'पोस्ट २४घका लागि प्रवर्द्धन भयो · ब्यालेन्स: $balance';
  }

  @override
  String get promoteJobFailedSnack => 'पोस्ट प्रवर्द्धन गर्न सकिएन।';

  @override
  String get promoteJobInsufficientSnack => 'प्रवर्द्धनका लागि सिक्का अपुग।';

  @override
  String get cancelLabel => 'रद्द गर्नुहोस्';

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
  String get vacancyMapEmpty => 'यहाँ नजिक अहिले कुनै खुला रिक्ति छैन।';

  @override
  String get vacancyMapBrowseAll => 'सबै रिक्तिहरू हेर्नुहोस्';

  @override
  String get vacancyMapSortSalary => 'तलब: बढीदेखि कम';

  @override
  String get vacancyMapSortNewest => 'नयाँ';

  @override
  String vacancyMapNearbyCount(int count) {
    return 'नजिकका $count रिक्ति';
  }

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
  String get mapSortNearest => 'नजिकको';

  @override
  String get mapSortPriceLowHigh => 'मूल्य: कमदेखि बढी';

  @override
  String get mapSortTopRated => 'उत्कृष्ट मूल्याङ्कन';

  @override
  String get mapAllMatchesHeader => 'सबै मिलेका';

  @override
  String get mapEmptyTitle => 'तपाईंका फिल्टरमा कुनै शिक्षक भेटिएन';

  @override
  String get mapEmptyHint =>
      'क्षेत्र फराकिलो बनाउनुहोस् वा फिल्टर खुकुलो गर्नुहोस्।';

  @override
  String get mapLoadError => 'नजिकका शिक्षकहरू लोड गर्न सकिएन।';

  @override
  String get mapEmptyExpandRadius => 'क्षेत्र बढाउनुहोस्';

  @override
  String get mapSearchHereSnack => 'यस बिन्दु वरिपरि शिक्षक खोज्दै';

  @override
  String get filterClearAll => 'फिल्टर हटाउनुहोस्';

  @override
  String get actionClear => 'हटाउनुहोस्';

  @override
  String get actionRetry => 'पुनः प्रयास';

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
  String get contactNoNumber => 'यो शिक्षकको फोन नम्बर उपलब्ध छैन।';

  @override
  String get contactLaunchFailed =>
      'यो एप खोल्न सकिएन। अर्को विकल्प प्रयोग गर्नुहोस्।';

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
  String get notifKindTutorApplied => 'नयाँ आवेदन';

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
  String get notifKindAnnouncement => 'घोषणा';

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
  String get reviewSending => 'पठाउँदै…';

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
  String get verifiedTutorLabel => 'प्रमाणित शिक्षक';

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

  @override
  String get myPostsTitle => 'मेरा पोस्ट';

  @override
  String myPostsTabJobs(int count) {
    return 'जागिर ($count)';
  }

  @override
  String myPostsTabVacancies(int count) {
    return 'खालीस्थान ($count)';
  }

  @override
  String get postRequirementCta => 'आवश्यकता पोस्ट';

  @override
  String get requestTutorCta => 'शिक्षक अनुरोध';

  @override
  String get myJobsEmpty =>
      'अहिलेसम्म कुनै जागिर पोस्ट गरिएको छैन। नयाँ पोस्ट गर्न ‘आवश्यकता पोस्ट’ थिच्नुहोस्।';

  @override
  String get myVacanciesEmpty =>
      'अहिलेसम्म कुनै शिक्षक अनुरोध छैन। एडमिनलाई पठाउन ‘शिक्षक अनुरोध’ थिच्नुहोस्।';

  @override
  String get viewMessages => 'सन्देश हेर्नुहोस्';

  @override
  String get closeAction => 'बन्द गर्नुहोस्';

  @override
  String get repostAction => 'पुनः पोस्ट';

  @override
  String get vacancyPendingReview => 'समीक्षा बाँकी';

  @override
  String get postDetailTitle => 'पोस्ट विवरण';

  @override
  String get postNotFound => 'पोस्ट भेटिएन।';

  @override
  String get postClosedBanner => 'यो आवश्यकता बन्द भयो।';

  @override
  String postPostedPrefix(String date) {
    return 'पोस्ट: $date';
  }

  @override
  String postRequiresPrefix(String label) {
    return 'आवश्यक: $label';
  }

  @override
  String postPostedByPrefix(String name) {
    return 'पोस्ट गर्ने: $name';
  }

  @override
  String get postWhatsAppVerified =>
      'WhatsApp प्रमाणित ✓ (म्याच नभएसम्म नम्बर लुकाइएको)';

  @override
  String get postYouFallback => 'तपाईं';

  @override
  String get postModeOnlineYes => 'अनलाइन उपलब्ध';

  @override
  String get postModeEither => 'अनलाइन वा आफैं भेटेर';

  @override
  String get postModeOnlineNo => 'अनलाइन उपलब्ध छैन';

  @override
  String get postModeHomeYes => 'घर-शिक्षणका लागि उपलब्ध';

  @override
  String get postModeHomeNo => 'अनलाइन मात्र — घर-शिक्षण छैन';

  @override
  String get postCanTravel => 'यात्रा गर्न सक्छन्';

  @override
  String get postCannotTravel => 'यात्रा गर्न सक्दैनन्';

  @override
  String get postDescriptionHeader => 'विवरण';

  @override
  String get postNoDescription => 'विवरण छैन।';

  @override
  String get jobStatusOpen => 'खुला';

  @override
  String get jobStatusShortlisting => 'छनोट';

  @override
  String get jobStatusHired => 'नियुक्त';

  @override
  String get jobStatusClosed => 'बन्द';

  @override
  String get jobStatusExpired => 'समय सकियो';

  @override
  String get vacancyStatusPendingReview => 'एडमिन समीक्षा बाँकी';

  @override
  String get vacancyStatusOpen => 'खुला';

  @override
  String get vacancyStatusApplicationsClosed => 'आवेदन बन्द';

  @override
  String get vacancyStatusFilled => 'भरियो';

  @override
  String get vacancyStatusCancelled => 'रद्द';

  @override
  String get engagementFullTime => 'पूर्णकालीन';

  @override
  String get engagementPartTime => 'अंशकालीन';

  @override
  String get engagementOneOff => 'एकपटक';

  @override
  String get requiredField => 'आवश्यक';

  @override
  String get phoneInTextValidation => 'फोन नम्बर वा सम्पर्क विवरण हटाउनुहोस्।';

  @override
  String get phoneBanFormHint =>
      'यहाँ फोन, इमेल, वेबसाइट जस्ता सम्पर्क विवरण साझा नगर्नुहोस्।';

  @override
  String get postJobAppBar => 'जागिर पोस्ट गर्नुहोस्';

  @override
  String get postJobSectionType => 'जागिरको प्रकार';

  @override
  String get postJobTypeHome => 'घर शिक्षण';

  @override
  String get postJobTypeOnline => 'अनलाइन';

  @override
  String get postJobTypeAssignment => 'असाइनमेन्ट';

  @override
  String get postJobSectionTitle => 'शीर्षक';

  @override
  String get postJobTitleHint => 'शीर्षक (उदाहरण: कपनमा गणित शिक्षक चाहियो)';

  @override
  String get postJobSectionDescription => 'विवरण';

  @override
  String get postJobDescriptionHint => 'तपाईंलाई के चाहिन्छ वर्णन गर्नुहोस्।';

  @override
  String get postJobSectionWhereWhen => 'कहाँ र कहिले';

  @override
  String get postJobSubjectLabel => 'विषय';

  @override
  String get postJobGradeLabel => 'कक्षा';

  @override
  String get postJobAreaLabel => 'क्षेत्र / चोक';

  @override
  String get postJobScheduleLabel => 'तालिका (उदाहरण: साँझ, ५–६ बजे)';

  @override
  String get postJobDueDatePick => 'अन्तिम मिति — मिति छान्नुहोस्';

  @override
  String postJobDueOnPrefix(String date) {
    return 'अन्तिम $date';
  }

  @override
  String get postJobSectionBudget => 'बजेट';

  @override
  String get postJobBudgetMinLabel => 'न्यून (NPR)';

  @override
  String get postJobBudgetMaxLabel => 'अधिकतम (NPR)';

  @override
  String get postJobPeriodLabel => 'अवधि';

  @override
  String get postJobSectionPreferences => 'प्राथमिकता';

  @override
  String get postJobModeLabel => 'तरिका';

  @override
  String get postJobTutorGenderLabel => 'शिक्षकको लिङ्ग';

  @override
  String get postJobEngagementLabel => 'नियुक्ति प्रकार';

  @override
  String get postJobEngagementAny => 'जुनसुकै';

  @override
  String get postJobPostingEllipsis => 'पोस्ट गर्दै…';

  @override
  String get postJobSubmit => 'जागिर पोस्ट';

  @override
  String get postJobFooter =>
      'मिल्ने शिक्षकलाई स्वतः सूचना जान्छ। ‘मेरा पोस्ट’ मा बिडहरू देखिनेछन्।';

  @override
  String get postJobSuccessSnack => 'जागिर पोस्ट भयो। शिक्षकलाई सूचना जान्छ।';

  @override
  String get budgetPeriodHour => '/घण्टा';

  @override
  String get budgetPeriodDay => '/दिन';

  @override
  String get budgetPeriodMonth => '/महिना';

  @override
  String get budgetPeriodSession => '/सेसन';

  @override
  String get budgetPeriodFixed => 'एकमुष्ट';

  @override
  String get requestSectionDetails => 'तपाईंको आवश्यकताको विवरण';

  @override
  String get requestDetailsHint =>
      'नमस्ते,\nमलाई गणित र हिन्दी शिक्षक अनलाइन चाहियो।';

  @override
  String get requestSectionLocation => 'स्थान';

  @override
  String get requestSectionSubjects => 'विषयहरू';

  @override
  String get requestSubjectsRequired => 'कम्तीमा एउटा विषय छान्नुहोस्।';

  @override
  String get requestSectionLevel => 'तपाईंको तह';

  @override
  String get requestDurationLabel => 'अवधि / मनपर्ने समय (उदाहरण: ५–६ बजे)';

  @override
  String get requestMinSalaryLabel => 'न्यून तलब (NPR)';

  @override
  String get requestMaxSalaryLabel => 'अधिकतम तलब (NPR)';

  @override
  String get requestGenderLabel => 'लिङ्ग प्राथमिकता';

  @override
  String get requestSubmit => 'एडमिनलाई अनुरोध पठाउनुहोस्';

  @override
  String get requestFooter =>
      'एडमिनले अनुरोध हेरेर HTN-NNNNN कोड दिनुहुन्छ र मिल्ने शिक्षकलाई सूचना पठाउनुहुन्छ। लाइभ हुँदा पुस सूचना आउँछ।';

  @override
  String get requestSuccessSnack =>
      'अनुरोध पठाइयो। एडमिनले समीक्षा गरेर चाँडै प्रकाशित गर्नुहुनेछ।';

  @override
  String requestTitlePrefix(String area) {
    return '$area मा शिक्षक चाहियो';
  }

  @override
  String get coinPacksIntro =>
      'सिक्का एप भित्र प्रयोग हुन्छन् — खालीस्थानमा आवेदन दिन, सम्पर्क खोल्न र लिस्टिङ बूस्ट गर्न। शिक्षण शुल्क एप बाहिर मिलाइन्छ।';

  @override
  String coinPackSubtitle(int count) {
    return '$count सिक्का';
  }

  @override
  String coinPackSubtitleWithBonus(int count, String bonus) {
    return '$count सिक्का · $bonus';
  }

  @override
  String get coinPackBuy => 'किन्नुहोस्';

  @override
  String get topUpFailedGeneric => 'भुक्तानी सुरु गर्न सकिएन।';

  @override
  String coinPackPaymentInitiated(String price, String provider) {
    return '$provider मार्फत $price को भुक्तानी सुरु भयो — पुष्टि भएपछि सिक्का आउनेछन्।';
  }

  @override
  String get payWithTitle => 'यसबाट भुक्तानी';

  @override
  String get payProviderHint =>
      'भुक्तानी पूरा गर्न तपाईं प्रदायककहाँ जानुहुनेछ। पुष्टि भएपछि सिक्का तुरुन्तै थपिन्छन्।';

  @override
  String get draftBannerPublished =>
      'तपाईंको प्रोफाइल लाइभ छ। सम्पादनहरू स्वतः सेभ भएर पुनः प्रकाशित हुन्छन्।';

  @override
  String get draftBannerDraft =>
      'तपाईंको प्रोफाइल ड्राफ्टमा छ। सबै चरण पूरा गरेर प्रकाशित गर्नुहोस्।';

  @override
  String get subjectsEmpty =>
      'अहिलेसम्म कुनै विषय थपिएको छैन। सुरु गर्न ‘विषय थप’ थिच्नुहोस्।';

  @override
  String get addSubject => 'विषय थप्नुहोस्';

  @override
  String get subjectsRequireLevel => 'विषय थप्न माथि कम्तीमा एक तह छान्नुहोस्।';

  @override
  String get subjectHint => 'विषय';

  @override
  String get priceHint => 'मूल्य';

  @override
  String get educationEmpty =>
      'तपाईंका डिग्री, विद्यालय, अध्ययन क्षेत्र थप्नुहोस्।';

  @override
  String get addEducation => 'शिक्षा थप्नुहोस्';

  @override
  String get experienceEmpty => 'शिक्षण वा कार्य अनुभव थप्नुहोस्।';

  @override
  String get addExperience => 'अनुभव थप्नुहोस्';

  @override
  String get certificatesEmpty => 'प्रमाणपत्र र पुरस्कार थप्नुहोस्।';

  @override
  String get addCertificate => 'प्रमाणपत्र थप्नुहोस्';

  @override
  String get degreeLabel => 'डिग्री';

  @override
  String get institutionLabel => 'संस्था';

  @override
  String get fieldOfStudyLabel => 'अध्ययन क्षेत्र';

  @override
  String get startYearLabel => 'सुरु वर्ष';

  @override
  String get endYearLabel => 'अन्तिम वर्ष';

  @override
  String get roleTitleLabel => 'भूमिका शीर्षक';

  @override
  String get organizationLabel => 'संगठन';

  @override
  String get certificateTitleLabel => 'शीर्षक';

  @override
  String get issuerLabel => 'जारी गर्ने';

  @override
  String get yearAwardedLabel => 'प्रदान वर्ष';

  @override
  String get attachCertificateLabel => 'प्रमाणपत्र संलग्न (PDF / तस्बिर)';

  @override
  String get attachCertificateNotReady =>
      'Supabase Storage सेटअप भएपछि फाइल अपलोड आउँछ।';

  @override
  String get removeAction => 'हटाउनुहोस्';

  @override
  String get timeBandPre10am => '१० बजे अघि';

  @override
  String get timeBandMidday => '१०–५ बजे';

  @override
  String get timeBandAfter5pm => '५ बजे पछि';

  @override
  String get weekdaySun => 'आइत';

  @override
  String get weekdayMon => 'सोम';

  @override
  String get weekdayTue => 'मंगल';

  @override
  String get weekdayWed => 'बुध';

  @override
  String get weekdayThu => 'बिहि';

  @override
  String get weekdayFri => 'शुक्र';

  @override
  String get weekdaySat => 'शनि';

  @override
  String get pricePeriodHour => '/घण्टा';

  @override
  String get pricePeriodDay => '/दिन';

  @override
  String get pricePeriodMonth => '/महिना';

  @override
  String get pricePeriodSession => '/सेसन';

  @override
  String get wizardStepIdentity => 'परिचय';

  @override
  String get wizardStepTeachingMode => 'पढाउने तरिका';

  @override
  String get wizardStepWhereYouTeach => 'तपाईं कहाँ पढाउनुहुन्छ';

  @override
  String get wizardStepLevelsYouTeach => 'तपाईंले पढाउने तह';

  @override
  String get wizardStepSubjectsPrices => 'विषय र मूल्य';

  @override
  String get wizardStepAboutYou => 'तपाईंको बारेमा';

  @override
  String get wizardStepAvailability => 'उपलब्धता';

  @override
  String wizardAppBarTitle(int step, int total) {
    return 'शिक्षक दर्ता — $step/$total';
  }

  @override
  String get backAction => 'पछाडि';

  @override
  String get continueAction => 'जारी राख्नुहोस्';

  @override
  String get finishAction => 'समाप्त';

  @override
  String get wizardIdentitySubtitle =>
      'तपाईंको नाम र सम्पर्क दर्ता बखत लिइएको छ। प्रोफाइल सेटिङबाट तस्बिर र थप विवरण पछि थप्नुहोस् — अहिले वैकल्पिक छ।';

  @override
  String get wizardTeachingModeTitle => 'तपाईं कसरी पढाउनुहुन्छ?';

  @override
  String get wizardTeachingModeSubtitle =>
      'अनलाइन मात्र पढाउनेलाई म्यापमा देखाइँदैन — खोजीमा भने आउँछन्।';

  @override
  String get wizardServiceAreaSkipTitle =>
      'अनलाइन मात्र — सेवा क्षेत्र चाहिँदैन';

  @override
  String get wizardServiceAreaSkipSubtitle =>
      'तपाईं अनलाइन पढाउनुहुन्छ। यो चरण छोड्नुहोस्।';

  @override
  String get wizardServiceAreaTitle => 'तपाईं कहाँ पढाउनुहुन्छ?';

  @override
  String get wizardServiceAreaSubtitle =>
      'नजिकका विद्यार्थीसँग मिलाउन प्रयोग हुन्छ। ठेगाना निजी रहन्छ।';

  @override
  String get cityLabel => 'सहर';

  @override
  String get areaChowkLabel => 'क्षेत्र / चोक (उदाहरण: बानेश्वर)';

  @override
  String get areaChowkLabelShort => 'क्षेत्र / चोक';

  @override
  String travelRadiusPrefix(int km) {
    return 'यात्रा क्षेत्र: $km किमी';
  }

  @override
  String kmSuffix(int km) {
    return '$km किमी';
  }

  @override
  String get wizardLevelsTitle =>
      'तपाईं कुन तहका विद्यार्थीलाई पढाउन सक्नुहुन्छ?';

  @override
  String get wizardLevelsSubtitle =>
      'मिल्ने सबै छान्नुहोस्। विद्यार्थीले आफ्नो तह अनुसार फिल्टर गर्छन्।';

  @override
  String get wizardSubjectsTitle => 'प्रस्तावित विषयहरू';

  @override
  String get wizardSubjectsSubtitle =>
      'प्रत्येक तहका लागि विषय र मूल्य (घण्टा, दिन, महिना वा सेसन) थप्नुहोस्। तपाईंका प्रस्तावमध्ये सबैभन्दा कम मूल्य कार्डमा ‘देखि’ दरका रूपमा देखाइन्छ।';

  @override
  String get tutorProfilePhoneBanWarning =>
      'फोन नम्बर, WhatsApp लिङ्क वा इमेल नराख्नुहोस्। राख्ने खाताहरू ब्लक हुनेछन्।';

  @override
  String get tutorProfilePhoneBanWarningBio =>
      'बायो फिल्डमा फोन नम्बर, WhatsApp लिङ्क वा इमेल नराख्नुहोस्। राख्ने खाताहरू ब्लक हुनेछन्।';

  @override
  String get aboutMeLabel => 'मेरो बारेमा';

  @override
  String get aboutMeHintWizard =>
      'छोटो बायो (पूर्णताका लागि कम्तीमा १०० अक्षर)';

  @override
  String get aboutMeHintShort => 'छोटो बायो';

  @override
  String get aboutSessionsLabel => 'मेरो सेसनको बारेमा';

  @override
  String get aboutSessionsHintWizard =>
      'तपाईं कसरी पढाउनुहुन्छ (कम्तीमा ५० अक्षर)';

  @override
  String get aboutSessionsHintShort => 'तपाईं कसरी पढाउनुहुन्छ';

  @override
  String get qualificationsLabel => 'योग्यता';

  @override
  String get qualificationsHintWizard =>
      'डिग्री, प्रमाणपत्र (कम्तीमा ३० अक्षर)';

  @override
  String get qualificationsHintShort => 'डिग्री, प्रमाणपत्र';

  @override
  String get wizardAvailabilityTitle => 'तपाईं कहिले उपलब्ध हुनुहुन्छ?';

  @override
  String get wizardAvailabilitySubtitle =>
      'सेल थिचेर टगल गर्नुहोस्। पङ्क्तिको लेबल (जस्तै ‘१० बजे अघि’) थिच्दा सबै पङ्क्ति टगल हुन्छ।';

  @override
  String get settingsAppBarTitle => 'प्रोफाइल सेटिङ';

  @override
  String get settingsTabPersonal => 'व्यक्तिगत';

  @override
  String get settingsTabEducation => 'शिक्षा';

  @override
  String get settingsTabSubjects => 'विषय';

  @override
  String get settingsTabAvailability => 'उपलब्धता';

  @override
  String get settingsTabVerification => 'प्रमाणीकरण';

  @override
  String get autoSavedLabel => 'स्वतः सेभ भयो';

  @override
  String get saveAndPublishCta => 'सेभ र प्रकाशन';

  @override
  String get saveChangesCta => 'परिवर्तन सेभ';

  @override
  String get taglineLabel => 'ट्यागलाइन';

  @override
  String get taglineSubtitle => 'तपाईंको कार्डमा देखिने एक-लाइन शीर्षक।';

  @override
  String get settingsAddressTitle => 'ठेगाना';

  @override
  String get settingsAddressSubtitle =>
      'पूरै ठेगाना निजी रहन्छ। केवल क्षेत्रको नाम सार्वजनिक देखिन्छ।';

  @override
  String get settingsLanguagesTitle => 'मलाई आउने भाषाहरू';

  @override
  String get settingsEducationSubtitle =>
      'वैकल्पिक। डिग्री, विद्यालय, अध्ययन क्षेत्र।';

  @override
  String get settingsExperienceTitle => 'अनुभव';

  @override
  String get settingsExperienceSubtitle => 'वैकल्पिक। शिक्षण वा कार्य अनुभव।';

  @override
  String get settingsCertificatesTitle => 'प्रमाणपत्र र पुरस्कार';

  @override
  String get settingsCertificatesSubtitle =>
      'वैकल्पिक। प्रमाणित ब्याज समीक्षामा सहयोग पुग्छ।';

  @override
  String get settingsSubjectsListedSubtitle =>
      'प्रत्येक तहका लागि विषय र मूल्य उल्लेख गर्नुहोस्।';

  @override
  String get settingsAvailabilityTitle => 'साप्ताहिक उपलब्धता';

  @override
  String get settingsAvailabilitySubtitle =>
      'सेल थिचेर टगल गर्नुहोस्। पङ्क्ति लेबलले सबै पङ्क्ति टगल गर्छ।';

  @override
  String get verifyCitizenshipTitle => 'नागरिकता';

  @override
  String get verifyCitizenshipSubtitle =>
      'अगाडि र पछाडि अपलोड गर्नुहोस्। निजी Supabase Storage मा रहन्छ; एडमिनले मात्र हेर्न सक्छन्।';

  @override
  String get verifyUploadCitizenship => 'नागरिकता अपलोड';

  @override
  String get verifySelfieTitle => 'नागरिकता समातेको सेल्फी';

  @override
  String get verifySelfieSubtitle =>
      'प्रमाणीकरण बखत एडमिनले एन्टी-स्पुफ जाँचका लागि प्रयोग गर्छन्।';

  @override
  String get verifyUploadSelfie => 'सेल्फी अपलोड';

  @override
  String get verifyStatusTitle => 'स्थिति';

  @override
  String get verifyStatusNotStarted =>
      'सुरु भएको छैन — समीक्षाका लागि कागजात पेस गर्नुहोस्।';

  @override
  String verifyUploadNotReady(String kind) {
    return 'Supabase Storage सेटअप भएपछि $kind अपलोड UI जोडिनेछ।';
  }

  @override
  String get accountBlockedTitle => 'खाता प्रतिबन्धित';

  @override
  String get accountBlockedReason =>
      'तपाईंको खाता निलम्बन वा प्रतिबन्धित गरिएको छ। अपिल गर्न एडमिनलाई सम्पर्क गर्नुहोस्।';

  @override
  String get blockedScreenTitle => 'खाता निष्क्रिय गरिएको छ';

  @override
  String get blockedScreenMessage =>
      'तपाईंले हाम्रो नीति सर्तहरू उल्लङ्घन गर्नुभएको हुनाले तपाईंको खाता निष्क्रिय गरिएको छ। तपाईं अब Home Tuition Nepal प्रयोग गर्न सक्नुहुन्न। यो निर्णयमा अपिल गर्न हाम्रो टोलीलाई सम्पर्क गर्नुहोस्।';

  @override
  String get blockedScreenEmailCta => 'हामीलाई इमेल गर्नुहोस्';

  @override
  String get blockedScreenRefresh =>
      'मलाई पुनः सक्रिय गरिएको छ — फेरि जाँच गर्नुहोस्';

  @override
  String get blockedScreenStillBlocked => 'तपाईंको खाता अझै निष्क्रिय छ।';

  @override
  String get presenceOnline => 'अनलाइन';

  @override
  String presenceLastSeen(String time) {
    return 'पछिल्लो पटक देखिएको $time';
  }

  @override
  String get contactAdminOnWhatsApp => 'WhatsApp मा एडमिनलाई सम्पर्क';

  @override
  String openThisUrl(String url) {
    return 'यो URL खोल्नुहोस्: $url';
  }

  @override
  String get showPasswordTooltip => 'पासवर्ड देखाउनुहोस्';

  @override
  String get hidePasswordTooltip => 'पासवर्ड लुकाउनुहोस्';

  @override
  String starRatingTooltip(int stars) {
    String _temp0 = intl.Intl.pluralLogic(
      stars,
      locale: localeName,
      other: '$stars तारा दिनुहोस्',
      one: '$stars तारा दिनुहोस्',
    );
    return '$_temp0';
  }

  @override
  String get wizardPrevStepTooltip => 'अघिल्लो चरण';

  @override
  String mapPinSemantics(String name, String distance, String verified) {
    return '$name, $distance$verified';
  }

  @override
  String get mapPinVerifiedSuffix => ', प्रमाणित शिक्षक';

  @override
  String balanceCardSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सिक्का',
      one: '$count सिक्का',
    );
    return 'हालको रकम, $_temp0';
  }

  @override
  String tutorCardSemantics(
    String name,
    String area,
    String distance,
    String verified,
    String rating,
  ) {
    return '$name, $area, $distance$verified$rating';
  }

  @override
  String tutorCardRatingSuffix(String average, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count समीक्षाबाट',
      one: '$count समीक्षाबाट',
    );
    return ', $_temp0 ५ मा $average';
  }

  @override
  String notificationBellSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'सूचना, $count नपढिएको',
      one: 'सूचना, $count नपढिएको',
      zero: 'सूचना, कुनै नपढिएको छैन',
    );
    return '$_temp0';
  }

  @override
  String draftBannerSemantics(String status, int percent) {
    return '$status, $percent प्रतिशत पूरा';
  }

  @override
  String notificationCardSemantics(
    String kind,
    String title,
    String time,
    String readState,
  ) {
    return '$kind, $title, $time$readState';
  }

  @override
  String get notificationUnreadSuffix => ', नपढिएको';

  @override
  String vacancyCardSemantics(
    String code,
    String title,
    String area,
    String salary,
    String applied,
  ) {
    return '$code, $title, $area, $salary$applied';
  }

  @override
  String get vacancyAlreadyAppliedSuffix => ', पहिले नै आवेदन भएको';

  @override
  String mapSheetHandleSemantics(String state, String action) {
    return 'शिक्षक सूची, $state, $action गर्न दुई पटक थिच्नुहोस्';
  }

  @override
  String get mapSheetExpanded => 'विस्तारित';

  @override
  String get mapSheetCollapsed => 'खुम्चिएको';

  @override
  String get mapSheetActionExpand => 'विस्तार';

  @override
  String get mapSheetActionCollapse => 'खुम्चिने';

  @override
  String tutorCardExperienceYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years वर्ष अनुभव',
      one: '$years वर्ष अनुभव',
    );
    return '$_temp0';
  }
}
