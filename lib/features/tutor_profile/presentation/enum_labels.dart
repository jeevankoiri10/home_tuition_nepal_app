import 'package:flutter/material.dart';

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

/// At-a-glance icon for a teaching mode — globe (online), home (in-person), or
/// pinch (both). Shared by the map pin and the tutor card so the visual
/// language stays consistent.
extension TeachingModeIcon on TeachingMode {
  IconData get icon {
    switch (this) {
      case TeachingMode.online:
        return Icons.public;
      case TeachingMode.offline:
        return Icons.home;
      case TeachingMode.both:
        return Icons.pinch;
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

extension TimeBandLabel on TimeBand {
  String localized(AppLocalizations l10n) {
    switch (this) {
      case TimeBand.pre10am:
        return l10n.timeBandPre10am;
      case TimeBand.midday:
        return l10n.timeBandMidday;
      case TimeBand.after5pm:
        return l10n.timeBandAfter5pm;
    }
  }
}

extension WeekdayLabel on Weekday {
  String localizedShort(AppLocalizations l10n) {
    switch (this) {
      case Weekday.sun:
        return l10n.weekdaySun;
      case Weekday.mon:
        return l10n.weekdayMon;
      case Weekday.tue:
        return l10n.weekdayTue;
      case Weekday.wed:
        return l10n.weekdayWed;
      case Weekday.thu:
        return l10n.weekdayThu;
      case Weekday.fri:
        return l10n.weekdayFri;
      case Weekday.sat:
        return l10n.weekdaySat;
    }
  }
}

extension PricePeriodLabel on PricePeriod {
  String localizedSuffix(AppLocalizations l10n) {
    switch (this) {
      case PricePeriod.hour:
        return l10n.pricePeriodHour;
      case PricePeriod.day:
        return l10n.pricePeriodDay;
      case PricePeriod.month:
        return l10n.pricePeriodMonth;
      case PricePeriod.session:
        return l10n.pricePeriodSession;
    }
  }
}
