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
