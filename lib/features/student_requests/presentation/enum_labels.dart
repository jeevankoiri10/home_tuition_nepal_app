import '../../../l10n/generated/app_localizations.dart';
import '../domain/models/request_enums.dart';

/// Localised labels for the student-request domain enums. Pattern mirrors
/// tutor_profile/presentation/enum_labels.dart — the enum keeps its
/// English `.label` as the server-side fallback; presentation reads
/// through `.localized(l10n)` instead.
extension JobModeLabel on JobMode {
  String localized(AppLocalizations l10n) {
    switch (this) {
      case JobMode.inPerson:
        return l10n.jobModeInPerson;
      case JobMode.online:
        return l10n.jobModeOnline;
      case JobMode.either:
        return l10n.jobModeEither;
    }
  }
}

extension GenderPrefLabel on GenderPref {
  String localized(AppLocalizations l10n) {
    switch (this) {
      case GenderPref.any:
        return l10n.genderPrefAny;
      case GenderPref.male:
        return l10n.genderPrefMale;
      case GenderPref.female:
        return l10n.genderPrefFemale;
    }
  }
}

extension JobStatusLabel on JobStatus {
  String localized(AppLocalizations l10n) {
    switch (this) {
      case JobStatus.open:
        return l10n.jobStatusOpen;
      case JobStatus.shortlisting:
        return l10n.jobStatusShortlisting;
      case JobStatus.hired:
        return l10n.jobStatusHired;
      case JobStatus.closed:
        return l10n.jobStatusClosed;
      case JobStatus.expired:
        return l10n.jobStatusExpired;
    }
  }
}

extension VacancyStatusLabel on VacancyStatus {
  String localized(AppLocalizations l10n) {
    switch (this) {
      case VacancyStatus.pendingAdminReview:
        return l10n.vacancyStatusPendingReview;
      case VacancyStatus.open:
        return l10n.vacancyStatusOpen;
      case VacancyStatus.applicationsClosed:
        return l10n.vacancyStatusApplicationsClosed;
      case VacancyStatus.filled:
        return l10n.vacancyStatusFilled;
      case VacancyStatus.cancelled:
        return l10n.vacancyStatusCancelled;
    }
  }
}

extension EngagementTypeLabel on EngagementType {
  String localized(AppLocalizations l10n) {
    switch (this) {
      case EngagementType.fullTime:
        return l10n.engagementFullTime;
      case EngagementType.partTime:
        return l10n.engagementPartTime;
      case EngagementType.oneOff:
        return l10n.engagementOneOff;
    }
  }
}

extension JobTypeLabel on JobType {
  /// Short label suited to a segmented button. Use [.localized] for forms
  /// where the full phrase reads better.
  String shortLabel(AppLocalizations l10n) {
    switch (this) {
      case JobType.homeTuition:
        return l10n.postJobTypeHome;
      case JobType.onlineTuition:
        return l10n.postJobTypeOnline;
      case JobType.assignmentHelp:
        return l10n.postJobTypeAssignment;
    }
  }
}

extension BudgetPeriodLabel on BudgetPeriod {
  String localized(AppLocalizations l10n) {
    switch (this) {
      case BudgetPeriod.hour:
        return l10n.budgetPeriodHour;
      case BudgetPeriod.day:
        return l10n.budgetPeriodDay;
      case BudgetPeriod.month:
        return l10n.budgetPeriodMonth;
      case BudgetPeriod.session:
        return l10n.budgetPeriodSession;
      case BudgetPeriod.fixed:
        return l10n.budgetPeriodFixed;
    }
  }
}
