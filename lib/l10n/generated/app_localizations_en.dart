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
}
