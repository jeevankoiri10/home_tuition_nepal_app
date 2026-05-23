import 'package:equatable/equatable.dart';

import 'profile_enums.dart';

/// 3 time-bands × 7 days of weekly availability. Persisted as a JSONB column.
/// Serialization shape mirrors the SQL example:
///   { "pre_10am": {"sun": true, "mon": false, ...}, "10_5pm": {...}, "after_5pm": {...} }
class TutorAvailability extends Equatable {
  TutorAvailability({Map<TimeBand, Map<Weekday, bool>>? slots})
      : slots = slots ?? _empty();

  final Map<TimeBand, Map<Weekday, bool>> slots;

  bool isAvailable(TimeBand band, Weekday day) => slots[band]?[day] ?? false;

  TutorAvailability toggle(TimeBand band, Weekday day) {
    final next = _clone(slots);
    final row = next[band]!;
    row[day] = !(row[day] ?? false);
    return TutorAvailability(slots: next);
  }

  TutorAvailability toggleRow(TimeBand band, {required bool value}) {
    final next = _clone(slots);
    for (final d in Weekday.values) {
      next[band]![d] = value;
    }
    return TutorAvailability(slots: next);
  }

  int get checkedCount {
    int n = 0;
    for (final band in slots.values) {
      for (final v in band.values) {
        if (v) n++;
      }
    }
    return n;
  }

  /// True when the user has explicitly set at least one slot (any value, true or false).
  /// Used to decide whether to award completion credit for availability.
  bool get isSet => checkedCount > 0;

  Map<String, dynamic> toJson() {
    final out = <String, dynamic>{};
    for (final band in TimeBand.values) {
      final row = <String, dynamic>{};
      for (final day in Weekday.values) {
        row[day.value] = slots[band]?[day] ?? false;
      }
      out[band.value] = row;
    }
    return out;
  }

  static TutorAvailability fromJson(Map<String, dynamic>? json) {
    if (json == null) return TutorAvailability();
    final out = _empty();
    json.forEach((bandKey, dayMap) {
      final band = TimeBand.fromString(bandKey);
      final dm = dayMap as Map<String, dynamic>;
      dm.forEach((dayKey, value) {
        out[band]![Weekday.fromValue(dayKey)] = (value as bool?) ?? false;
      });
    });
    return TutorAvailability(slots: out);
  }

  static Map<TimeBand, Map<Weekday, bool>> _empty() {
    return {
      for (final b in TimeBand.values) b: {for (final d in Weekday.values) d: false},
    };
  }

  static Map<TimeBand, Map<Weekday, bool>> _clone(Map<TimeBand, Map<Weekday, bool>> src) {
    return {
      for (final entry in src.entries) entry.key: Map<Weekday, bool>.from(entry.value),
    };
  }

  @override
  List<Object?> get props => [toJson().toString()];
}
