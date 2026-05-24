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

  @override
  String verifyEmailResendCooldown(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get studentHomeTitle => 'Student home';

  @override
  String get tutorHomeTitle => 'Tutor home';

  @override
  String get signOutTooltip => 'Sign out';

  @override
  String homeWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String homeHandle(String handle) {
    return 'Handle: $handle';
  }

  @override
  String get studentMapPlaceholder =>
      'The locality-first map (the headline feature) ships in Phase 4.';

  @override
  String get previewLabel => 'Preview';

  @override
  String get currentBalanceLabel => 'CURRENT BALANCE';

  @override
  String coinsSuffix(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coins',
      one: '$count coin',
    );
    return '$_temp0';
  }

  @override
  String get tutorActionCompleteProfileTitle => 'Complete your profile';

  @override
  String get tutorActionCompleteProfileSubtitle =>
      'Walk through the 7-step wizard to publish your tutor profile.';

  @override
  String get tutorActionProfileSettingsTitle => 'Profile settings';

  @override
  String get tutorActionProfileSettingsSubtitle =>
      'Edit subjects, prices, availability, About sections, credentials.';

  @override
  String get tutorActionVacanciesTitle => 'Vacancies';

  @override
  String get tutorActionVacanciesSubtitle =>
      'Browse open HTN-NNNNN vacancies and apply with 1 coin.';

  @override
  String get tutorActionWalletTitle => 'Coin wallet';

  @override
  String get tutorActionWalletSubtitle =>
      'See balance, transaction history, and buy coins.';

  @override
  String get tutorActionBoostTitle => 'Boost listing (24h)';

  @override
  String get tutorActionBoostSubtitle =>
      'Get a highlighted pin and a top-of-feed slot.';

  @override
  String tutorBoostSuccessSnack(int balance) {
    return 'Listing boosted for 24h · Balance: $balance';
  }

  @override
  String get tutorBoostFailedSnack => 'Could not boost listing.';

  @override
  String get tutorBoostInsufficientSnack => 'Insufficient coins for boost.';

  @override
  String get tutorPhasesNote =>
      'Push notifications, in-app chat, and reviews ship in Phases 8–10.';

  @override
  String get mapTitle => 'Tutors near you';

  @override
  String get mapMyPostsTooltip => 'My posts';

  @override
  String get mapRecenterTooltip => 'Re-center';

  @override
  String get mapRequestTutorFab => 'Request a tutor';

  @override
  String get mapPostJobFab => 'Post a job';

  @override
  String mapTutorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tutors',
      one: '$count tutor',
    );
    return '$_temp0';
  }

  @override
  String get mapAllMatchesHeader => 'All matches';

  @override
  String get mapEmptyTitle => 'No tutors match your filters';

  @override
  String get mapEmptyHint => 'Try widening the radius or loosening filters.';

  @override
  String get walletTitle => 'Coin Wallet';

  @override
  String get walletBuyCoins => 'Buy Coins';

  @override
  String get walletTransactionHistory => 'Transaction History';

  @override
  String get walletNoTransactions => 'No transactions yet.';

  @override
  String get ledgerColDate => 'Date';

  @override
  String get ledgerColDetails => 'Details';

  @override
  String get ledgerColCoins => 'Coins';

  @override
  String get unlockNotSignedIn => 'Please sign in first.';

  @override
  String unlockTitle(int cost) {
    return 'Unlock contact for $cost coins';
  }

  @override
  String get unlockBody =>
      'You can contact the tutor over phone or WhatsApp once unlocked. This is a one-time cost — repeat unlocks for the same tutor are free.';

  @override
  String get unlockNeedMoreCoins => 'You need more coins. Top up to continue.';

  @override
  String get unlockFailedGeneric => 'Could not unlock contact.';

  @override
  String get workingEllipsis => 'Working…';

  @override
  String unlockConfirmCta(int cost) {
    return 'Confirm — $cost coins';
  }

  @override
  String get buyCoinsLink => 'Buy coins';

  @override
  String get unlockSuccess => 'Contact unlocked';

  @override
  String unlockNewBalance(int balance) {
    return 'New balance: $balance coins';
  }

  @override
  String get openChat => 'Open chat';

  @override
  String get callLabel => 'Call';

  @override
  String get whatsAppLabel => 'WhatsApp';

  @override
  String get unlockCallPhase7Hint =>
      'Phone-number reveal lands when admin matches go live (Phase 7).';

  @override
  String get unlockWhatsAppPhase7Hint => 'WhatsApp launch wires in Phase 7.';

  @override
  String get leaveReview => 'Leave a review';

  @override
  String get doneLabel => 'Done';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsTabAll => 'All';

  @override
  String notificationsTabAllCount(int count) {
    return 'All ($count)';
  }

  @override
  String get notificationsTabUnread => 'Unread';

  @override
  String notificationsTabUnreadCount(int count) {
    return 'Unread ($count)';
  }

  @override
  String get notificationsTabRead => 'Read';

  @override
  String get notificationsEmpty => 'No notifications yet.';

  @override
  String get notificationsEmptyUnread => 'No unread notifications.';

  @override
  String get notificationsEmptyRead => 'No read notifications.';

  @override
  String get relativeJustNow => 'just now';

  @override
  String relativeMinutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String relativeHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String relativeDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get notifKindNewJobPosted => 'New job posted';

  @override
  String get notifKindApplicationShortlisted => 'Application shortlisted';

  @override
  String get notifKindApplicationHired => 'You were hired';

  @override
  String get notifKindContactRevealed => 'Contact revealed';

  @override
  String get notifKindIdentityApproved => 'Identity Verification Approved';

  @override
  String get notifKindIdentityRejected => 'Verification needs attention';

  @override
  String get notifKindCoinCredited => 'Coins credited';

  @override
  String get notifKindCoinDebited => 'Coins debited';

  @override
  String get notifKindNewReview => 'New review';

  @override
  String get notifKindSystem => 'Notice';

  @override
  String get chatTitleFallback => 'Chat';

  @override
  String get chatOpenError => 'Could not open chat.';

  @override
  String get chatComposerHint => 'Type a message…';

  @override
  String get chatEmptyHint =>
      'Say hello — and remember: do not share phone numbers or emails here.';

  @override
  String reviewRateTitle(String name) {
    return 'Rate $name';
  }

  @override
  String get reviewPhoneBanWarning =>
      'Do not include phone numbers or contact details in your review.';

  @override
  String get reviewTextLabel => 'Tell other students about this tutor';

  @override
  String get reviewTextHint => 'Optional. Stay specific and respectful.';

  @override
  String get reviewSubmit => 'Submit review';

  @override
  String get reviewSending => 'Sending…';

  @override
  String get reviewThanks => 'Thanks for your review!';

  @override
  String get reviewGateNotMet => 'You need to unlock this tutor first.';

  @override
  String get reviewPhoneRejected =>
      'Phone numbers and contact details are not allowed.';

  @override
  String get reviewFailedGeneric => 'Could not submit review.';

  @override
  String get notRated => 'Not rated';

  @override
  String get filterVerifiedOnly => 'Verified only';

  @override
  String get filterAvailableNow => 'Available now';

  @override
  String get filterLevelTooltip => 'Student level';

  @override
  String get filterAllLevels => 'All levels';

  @override
  String get filterTeachingModeTooltip => 'Teaching mode';

  @override
  String get filterAnyMode => 'Any mode';

  @override
  String get filterRadiusTooltip => 'Radius';

  @override
  String filterRadiusWithinKm(int km) {
    return 'Within $km km';
  }

  @override
  String filterRadiusKm(int km) {
    return '$km km';
  }

  @override
  String get tutorAvailable => 'Available';

  @override
  String get contactLabel => 'Contact';

  @override
  String get teachingModeOnline => 'Online';

  @override
  String get teachingModeOffline => 'Offline (in-person)';

  @override
  String get teachingModeBoth => 'Both';

  @override
  String get studentLevelBelowClass9 => 'Below Class 9';

  @override
  String get studentLevelSee => 'SEE';

  @override
  String get studentLevelPlus2 => '+2';

  @override
  String get studentLevelALevel => 'A Level';

  @override
  String get vacanciesTitle => 'Vacancies';

  @override
  String get refreshTooltip => 'Refresh';

  @override
  String get vacanciesLoadError => 'Could not load vacancies.';

  @override
  String get vacanciesEmpty => 'No open vacancies right now. Pull to refresh.';

  @override
  String get vacancyApplyLabel => 'Apply';

  @override
  String get vacancyAppliedLabel => 'Applied';

  @override
  String get vacancyAlreadyApplied => 'Already applied';

  @override
  String vacancyGradePrefix(String grade) {
    return 'Grade: $grade';
  }

  @override
  String vacancySubjectsPrefix(String subjects) {
    return 'Subjects: $subjects';
  }

  @override
  String vacancyNumStudentsPrefix(int count) {
    return 'No. of students: $count';
  }

  @override
  String vacancyTimePrefix(String text) {
    return 'Time: $text';
  }

  @override
  String vacancyGenderPrefPrefix(String label) {
    return 'Gender preference: $label';
  }

  @override
  String vacancyModePrefix(String label) {
    return 'Mode: $label';
  }

  @override
  String get vacancyNotesHeader => 'Notes';

  @override
  String get vacancyPostedByAdmin => 'Posted by Home Tuition Nepal admin.';

  @override
  String get vacancyTitleFallback => 'Vacancy';

  @override
  String get vacancyNotFound => 'Vacancy not found.';

  @override
  String applySheetTitle(String label) {
    return 'Apply to $label';
  }

  @override
  String get applyPhoneBanWarning =>
      'Do not include phone numbers or contact details in your cover note. Accounts that do will be blocked.';

  @override
  String get applyCoverLabel => 'Cover note';

  @override
  String get applyCoverHint => 'Why are you a good fit?';

  @override
  String get applyCoverRequired => 'Please write a short cover note.';

  @override
  String get applyCoverPhoneViolation =>
      'Remove phone numbers or contact details.';

  @override
  String get applyRateLabel => 'Expected rate (NPR, optional)';

  @override
  String get applySending => 'Sending…';

  @override
  String applyButtonLabel(int cost) {
    String _temp0 = intl.Intl.pluralLogic(
      cost,
      locale: localeName,
      other: 'Apply — $cost coins',
      one: 'Apply — $cost coin',
    );
    return '$_temp0';
  }

  @override
  String get applySuccessSnack => 'Application sent. Admin will review it.';

  @override
  String get jobModeInPerson => 'In-person';

  @override
  String get jobModeOnline => 'Online';

  @override
  String get jobModeEither => 'Either';

  @override
  String get genderPrefAny => 'Any';

  @override
  String get genderPrefMale => 'Male';

  @override
  String get genderPrefFemale => 'Female';

  @override
  String get myPostsTitle => 'My Posts';

  @override
  String myPostsTabJobs(int count) {
    return 'Jobs ($count)';
  }

  @override
  String myPostsTabVacancies(int count) {
    return 'Vacancies ($count)';
  }

  @override
  String get postRequirementCta => 'Post Requirement';

  @override
  String get requestTutorCta => 'Request a Tutor';

  @override
  String get myJobsEmpty =>
      'No jobs posted yet. Tap \"Post Requirement\" to create one.';

  @override
  String get myVacanciesEmpty =>
      'No tutor requests yet. Tap \"Request a Tutor\" to send one to the admin.';

  @override
  String get viewMessages => 'View Messages';

  @override
  String get closeAction => 'Close';

  @override
  String get repostAction => 'Repost';

  @override
  String get chatPhase9Hint => 'In-app chat ships in Phase 9.';

  @override
  String get vacancyPendingReview => 'Pending review';

  @override
  String get postDetailTitle => 'Post Detail';

  @override
  String get postNotFound => 'Post not found.';

  @override
  String get postClosedBanner => 'This requirement is closed.';

  @override
  String postPostedPrefix(String date) {
    return 'Posted: $date';
  }

  @override
  String postRequiresPrefix(String label) {
    return 'Requires: $label';
  }

  @override
  String postPostedByPrefix(String name) {
    return 'Posted by: $name';
  }

  @override
  String get postWhatsAppVerified =>
      'WhatsApp verified ✓ (number hidden until match)';

  @override
  String get postYouFallback => 'You';

  @override
  String get postModeOnlineYes => 'Available online';

  @override
  String get postModeEither => 'Online or in-person';

  @override
  String get postModeOnlineNo => 'Not available online';

  @override
  String get postModeHomeYes => 'Available for home tutoring';

  @override
  String get postModeHomeNo => 'Online only — no home tutoring';

  @override
  String get postCanTravel => 'Can travel';

  @override
  String get postCannotTravel => 'Cannot travel';

  @override
  String get postDescriptionHeader => 'Description';

  @override
  String get postNoDescription => 'No description.';

  @override
  String get jobStatusOpen => 'Open';

  @override
  String get jobStatusShortlisting => 'Shortlisting';

  @override
  String get jobStatusHired => 'Hired';

  @override
  String get jobStatusClosed => 'Closed';

  @override
  String get jobStatusExpired => 'Expired';

  @override
  String get vacancyStatusPendingReview => 'Pending admin review';

  @override
  String get vacancyStatusOpen => 'Open';

  @override
  String get vacancyStatusApplicationsClosed => 'Applications closed';

  @override
  String get vacancyStatusFilled => 'Filled';

  @override
  String get vacancyStatusCancelled => 'Cancelled';

  @override
  String get engagementFullTime => 'Full time';

  @override
  String get engagementPartTime => 'Part time';

  @override
  String get engagementOneOff => 'One-off';

  @override
  String get requiredField => 'Required';

  @override
  String get phoneInTextValidation =>
      'Remove phone numbers or contact details.';

  @override
  String get phoneBanFormHint =>
      'Please don\'t share any contact details (phone, email, website etc) here.';

  @override
  String get postJobAppBar => 'Post a job';

  @override
  String get postJobSectionType => 'Type of job';

  @override
  String get postJobTypeHome => 'Home tuition';

  @override
  String get postJobTypeOnline => 'Online';

  @override
  String get postJobTypeAssignment => 'Assignment';

  @override
  String get postJobSectionTitle => 'Title';

  @override
  String get postJobTitleHint => 'Headline (e.g., Maths tutor needed in Kapan)';

  @override
  String get postJobSectionDescription => 'Description';

  @override
  String get postJobDescriptionHint => 'Describe what you need.';

  @override
  String get postJobSectionWhereWhen => 'Where & when';

  @override
  String get postJobSubjectLabel => 'Subject';

  @override
  String get postJobGradeLabel => 'Grade / Class';

  @override
  String get postJobAreaLabel => 'Area / chowk';

  @override
  String get postJobScheduleLabel => 'Schedule (e.g., evenings, 5–6pm)';

  @override
  String get postJobDueDatePick => 'Due date — pick a date';

  @override
  String postJobDueOnPrefix(String date) {
    return 'Due $date';
  }

  @override
  String get postJobSectionBudget => 'Budget';

  @override
  String get postJobBudgetMinLabel => 'Min (NPR)';

  @override
  String get postJobBudgetMaxLabel => 'Max (NPR)';

  @override
  String get postJobPeriodLabel => 'Period';

  @override
  String get postJobSectionPreferences => 'Preferences';

  @override
  String get postJobModeLabel => 'Mode';

  @override
  String get postJobTutorGenderLabel => 'Tutor gender';

  @override
  String get postJobEngagementLabel => 'Engagement type';

  @override
  String get postJobEngagementAny => 'Any';

  @override
  String get postJobPostingEllipsis => 'Posting…';

  @override
  String get postJobSubmit => 'Post job';

  @override
  String get postJobFooter =>
      'Matching tutors are notified automatically. You\'ll see their bids in My Posts.';

  @override
  String get postJobSuccessSnack => 'Job posted. Tutors will be notified.';

  @override
  String get budgetPeriodHour => '/hour';

  @override
  String get budgetPeriodDay => '/day';

  @override
  String get budgetPeriodMonth => '/month';

  @override
  String get budgetPeriodSession => '/session';

  @override
  String get budgetPeriodFixed => 'fixed';

  @override
  String get requestSectionDetails => 'Details of your requirement';

  @override
  String get requestDetailsHint => 'Hi,\nI need maths and Hindi tutors online.';

  @override
  String get requestSectionLocation => 'Location';

  @override
  String get requestSectionSubjects => 'Subjects';

  @override
  String get requestSubjectsRequired => 'Pick at least one subject.';

  @override
  String get requestSectionLevel => 'Your Level';

  @override
  String get requestDurationLabel =>
      'Duration / preferred time (e.g., 5pm–6pm)';

  @override
  String get requestMinSalaryLabel => 'Min salary (NPR)';

  @override
  String get requestMaxSalaryLabel => 'Max salary (NPR)';

  @override
  String get requestGenderLabel => 'Gender preference';

  @override
  String get requestSubmit => 'Send request to admin';

  @override
  String get requestFooter =>
      'Admin reviews your request, assigns an HTN-NNNNN code, and notifies matching tutors. You\'ll get a push when it\'s live.';

  @override
  String get requestSuccessSnack =>
      'Request sent. Admin will review and publish soon.';

  @override
  String requestTitlePrefix(String area) {
    return 'Tutor needed in $area';
  }

  @override
  String get coinPacksIntro =>
      'Coins are used inside the app — to apply to vacancies, unlock contacts, and boost your listing. Tuition fees are settled off-platform.';

  @override
  String coinPackSubtitle(int count) {
    return '$count coins';
  }

  @override
  String coinPackSubtitleWithBonus(int count, String bonus) {
    return '$count coins · $bonus';
  }

  @override
  String get coinPackBuy => 'Buy';

  @override
  String get topUpFailedGeneric => 'Could not start payment.';

  @override
  String coinPackPaymentInitiated(String price, String provider) {
    return 'Payment of $price via $provider initiated — coins arrive on confirmation.';
  }

  @override
  String get payWithTitle => 'Pay with';

  @override
  String get payProviderHint =>
      'You\'ll be taken to the provider to complete the payment. Coins are credited the moment we receive the confirmation.';

  @override
  String get draftBannerPublished =>
      'Your profile is live. Edits auto-save and re-publish.';

  @override
  String get draftBannerDraft =>
      'Your profile is in draft mode. Complete all steps to publish and go live.';

  @override
  String get subjectsEmpty =>
      'No subjects added yet. Tap \"Add subject\" to start.';

  @override
  String get addSubject => 'Add subject';

  @override
  String get subjectsRequireLevel =>
      'Pick at least one student level above to add subjects.';

  @override
  String get subjectHint => 'Subject';

  @override
  String get priceHint => 'Price';

  @override
  String get educationEmpty => 'Add your degrees, schools, fields of study.';

  @override
  String get addEducation => 'Add education';

  @override
  String get experienceEmpty => 'Add teaching or work experience.';

  @override
  String get addExperience => 'Add experience';

  @override
  String get certificatesEmpty => 'Add certificates and awards.';

  @override
  String get addCertificate => 'Add certificate';

  @override
  String get degreeLabel => 'Degree';

  @override
  String get institutionLabel => 'Institution';

  @override
  String get fieldOfStudyLabel => 'Field of study';

  @override
  String get startYearLabel => 'Start year';

  @override
  String get endYearLabel => 'End year';

  @override
  String get roleTitleLabel => 'Role title';

  @override
  String get organizationLabel => 'Organization';

  @override
  String get certificateTitleLabel => 'Title';

  @override
  String get issuerLabel => 'Issuer';

  @override
  String get yearAwardedLabel => 'Year awarded';

  @override
  String get attachCertificateLabel => 'Attach certificate (PDF / image)';

  @override
  String get attachCertificateNotReady =>
      'File upload UI ships when Supabase Storage is configured.';

  @override
  String get removeAction => 'Remove';

  @override
  String get timeBandPre10am => 'Pre 10 am';

  @override
  String get timeBandMidday => '10 am – 5 pm';

  @override
  String get timeBandAfter5pm => 'After 5 pm';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get pricePeriodHour => '/hour';

  @override
  String get pricePeriodDay => '/day';

  @override
  String get pricePeriodMonth => '/month';

  @override
  String get pricePeriodSession => '/session';

  @override
  String get wizardStepIdentity => 'Identity';

  @override
  String get wizardStepTeachingMode => 'Teaching mode';

  @override
  String get wizardStepWhereYouTeach => 'Where you teach';

  @override
  String get wizardStepLevelsYouTeach => 'Levels you teach';

  @override
  String get wizardStepSubjectsPrices => 'Subjects & prices';

  @override
  String get wizardStepAboutYou => 'About you';

  @override
  String get wizardStepAvailability => 'Availability';

  @override
  String wizardAppBarTitle(int step, int total) {
    return 'Tutor onboarding — $step/$total';
  }

  @override
  String get backAction => 'Back';

  @override
  String get continueAction => 'Continue';

  @override
  String get finishAction => 'Finish';

  @override
  String get wizardIdentitySubtitle =>
      'Your name and contact were captured at registration. Add a photo and demographic details from Profile Settings later — they\'re optional now.';

  @override
  String get wizardTeachingModeTitle => 'How do you teach?';

  @override
  String get wizardTeachingModeSubtitle =>
      'Online-only tutors are not pinned on the map — they still appear in search.';

  @override
  String get wizardServiceAreaSkipTitle =>
      'Online-only — no service area needed';

  @override
  String get wizardServiceAreaSkipSubtitle =>
      'You teach online. Skip this step.';

  @override
  String get wizardServiceAreaTitle => 'Where do you teach?';

  @override
  String get wizardServiceAreaSubtitle =>
      'Used to match students near you. The exact address is private.';

  @override
  String get cityLabel => 'City';

  @override
  String get areaChowkLabel => 'Area / chowk (e.g., Baneshwor)';

  @override
  String get areaChowkLabelShort => 'Area / chowk';

  @override
  String travelRadiusPrefix(int km) {
    return 'Travel radius: $km km';
  }

  @override
  String kmSuffix(int km) {
    return '$km km';
  }

  @override
  String get wizardLevelsTitle => 'Which student levels can you teach?';

  @override
  String get wizardLevelsSubtitle =>
      'Pick all that apply. Students filter the map by their own level.';

  @override
  String get wizardSubjectsTitle => 'Subjects offered';

  @override
  String get wizardSubjectsSubtitle =>
      'For each level you teach, add the subjects and the price (per hour, day, month, or session). The lowest price across your offerings is shown as the \"from\" rate on tutor cards.';

  @override
  String get tutorProfilePhoneBanWarning =>
      'Do not include phone numbers, WhatsApp links, or email addresses. Accounts that do will be blocked.';

  @override
  String get tutorProfilePhoneBanWarningBio =>
      'Do not include phone numbers, WhatsApp links, or email addresses in the bio fields. Accounts that do will be blocked.';

  @override
  String get aboutMeLabel => 'About me';

  @override
  String get aboutMeHintWizard => 'A short bio (min 100 chars for completion)';

  @override
  String get aboutMeHintShort => 'A short bio';

  @override
  String get aboutSessionsLabel => 'About my sessions';

  @override
  String get aboutSessionsHintWizard => 'How you teach (min 50 chars)';

  @override
  String get aboutSessionsHintShort => 'How you teach';

  @override
  String get qualificationsLabel => 'Qualifications';

  @override
  String get qualificationsHintWizard =>
      'Degrees, certifications (min 30 chars)';

  @override
  String get qualificationsHintShort => 'Degrees, certifications';

  @override
  String get wizardAvailabilityTitle => 'When are you available?';

  @override
  String get wizardAvailabilitySubtitle =>
      'Tap a cell to toggle. Tap a row label (e.g., \"Pre 10 am\") to toggle the whole row.';

  @override
  String get settingsAppBarTitle => 'Profile settings';

  @override
  String get settingsTabPersonal => 'Personal';

  @override
  String get settingsTabEducation => 'Education';

  @override
  String get settingsTabSubjects => 'Subjects';

  @override
  String get settingsTabAvailability => 'Availability';

  @override
  String get settingsTabVerification => 'Verification';

  @override
  String get autoSavedLabel => 'Auto-saved';

  @override
  String get saveAndPublishCta => 'Save & Publish';

  @override
  String get saveChangesCta => 'Save changes';

  @override
  String get taglineLabel => 'Tagline';

  @override
  String get taglineSubtitle => 'A one-line headline shown on your card.';

  @override
  String get settingsAddressTitle => 'Address';

  @override
  String get settingsAddressSubtitle =>
      'The full address is private. Only the area name is shown publicly.';

  @override
  String get settingsLanguagesTitle => 'Languages I know';

  @override
  String get settingsEducationSubtitle =>
      'Optional. Degrees, schools, fields of study.';

  @override
  String get settingsExperienceTitle => 'Experience';

  @override
  String get settingsExperienceSubtitle =>
      'Optional. Past teaching or work roles.';

  @override
  String get settingsCertificatesTitle => 'Certificates & Awards';

  @override
  String get settingsCertificatesSubtitle =>
      'Optional. Boosts the verified-badge review.';

  @override
  String get settingsSubjectsListedSubtitle =>
      'For each level, list the subjects and prices.';

  @override
  String get settingsAvailabilityTitle => 'Weekly availability';

  @override
  String get settingsAvailabilitySubtitle =>
      'Tap a cell to toggle. Row labels toggle the entire row.';

  @override
  String get verifyCitizenshipTitle => 'Citizenship';

  @override
  String get verifyCitizenshipSubtitle =>
      'Upload front + back. Stored in a private Supabase Storage bucket; only the admin can view it.';

  @override
  String get verifyUploadCitizenship => 'Upload citizenship';

  @override
  String get verifySelfieTitle => 'Selfie holding citizenship';

  @override
  String get verifySelfieSubtitle =>
      'Anti-spoof check used by the admin during verification.';

  @override
  String get verifyUploadSelfie => 'Upload selfie';

  @override
  String get verifyStatusTitle => 'Status';

  @override
  String get verifyStatusNotStarted =>
      'Not started — submit your documents to begin review.';

  @override
  String verifyUploadNotReady(String kind) {
    return '$kind upload UI wires to Supabase Storage when buckets are configured.';
  }

  @override
  String get accountBlockedTitle => 'Account is restricted';

  @override
  String get accountBlockedReason =>
      'Your account has been suspended or banned. Contact the admin to appeal.';

  @override
  String get contactAdminOnWhatsApp => 'Contact admin on WhatsApp';

  @override
  String openThisUrl(String url) {
    return 'Open this URL: $url';
  }

  @override
  String get showPasswordTooltip => 'Show password';

  @override
  String get hidePasswordTooltip => 'Hide password';

  @override
  String starRatingTooltip(int stars) {
    String _temp0 = intl.Intl.pluralLogic(
      stars,
      locale: localeName,
      other: 'Rate $stars stars',
      one: 'Rate $stars star',
    );
    return '$_temp0';
  }

  @override
  String get wizardPrevStepTooltip => 'Previous step';

  @override
  String mapPinSemantics(String name, String distance, String verified) {
    return '$name, $distance$verified';
  }

  @override
  String get mapPinVerifiedSuffix => ', verified tutor';

  @override
  String balanceCardSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coins',
      one: '$count coin',
    );
    return 'Current balance, $_temp0';
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
      other: '$count reviews',
      one: '$count review',
    );
    return ', rated $average out of 5 from $_temp0';
  }

  @override
  String notificationBellSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Notifications, $count unread',
      one: 'Notifications, $count unread',
      zero: 'Notifications, no unread',
    );
    return '$_temp0';
  }
}
