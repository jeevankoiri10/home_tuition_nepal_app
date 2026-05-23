import '../../../l10n/generated/app_localizations.dart';
import '../domain/models/profile_enums.dart';

/// Map domain enums (whose hard-coded `label` fields are the server-side
/// English fallback) to user-facing strings via AppLocalizations.
///
/// Kept out of the domain layer so the enum stays presentation-agnostic.
extension TeachingModeLabel on TeachingMode {
  String localized(AppLocalizations l10n) {
    switch (this) {
      case TeachingMode.online:
        return l10n.teachingModeOnline;
      case TeachingMode.offline:
        return l10n.teachingModeOffline;
      case TeachingMode.both:
        return l10n.teachingModeBoth;
    }
  }
}

extension StudentLevelLabel on StudentLevel {
  String localized(AppLocalizations l10n) {
    switch (this) {
      case StudentLevel.belowClass9:
        return l10n.studentLevelBelowClass9;
      case StudentLevel.see:
        return l10n.studentLevelSee;
      case StudentLevel.plus2:
        return l10n.studentLevelPlus2;
      case StudentLevel.aLevel:
        return l10n.studentLevelALevel;
    }
  }
}
