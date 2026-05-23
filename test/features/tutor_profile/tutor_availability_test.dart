import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/tutor_profile/domain/models/profile_enums.dart';
import 'package:home_tuition_nepal_app/features/tutor_profile/domain/models/tutor_availability.dart';

void main() {
  group('TutorAvailability', () {
    test('starts empty — every cell is false, isSet=false', () {
      final a = TutorAvailability();
      for (final band in TimeBand.values) {
        for (final day in Weekday.values) {
          expect(a.isAvailable(band, day), isFalse);
        }
      }
      expect(a.isSet, isFalse);
      expect(a.checkedCount, 0);
    });

    test('toggle flips one cell without mutating the source', () {
      final a = TutorAvailability();
      final b = a.toggle(TimeBand.after5pm, Weekday.fri);
      expect(b.isAvailable(TimeBand.after5pm, Weekday.fri), isTrue);
      expect(a.isAvailable(TimeBand.after5pm, Weekday.fri), isFalse);
      expect(b.checkedCount, 1);
    });

    test('toggleRow sets every day in a band to true', () {
      final a = TutorAvailability().toggleRow(TimeBand.midday, value: true);
      for (final d in Weekday.values) {
        expect(a.isAvailable(TimeBand.midday, d), isTrue);
      }
      expect(a.checkedCount, Weekday.values.length);
    });

    test('JSON round-trip preserves the grid', () {
      final original = TutorAvailability()
          .toggle(TimeBand.pre10am, Weekday.sun)
          .toggle(TimeBand.midday, Weekday.wed)
          .toggleRow(TimeBand.after5pm, value: true);
      final restored = TutorAvailability.fromJson(original.toJson());
      expect(restored, original);
      expect(restored.checkedCount, original.checkedCount);
    });
  });
}
