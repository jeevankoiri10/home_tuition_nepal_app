import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/map/domain/models/map_filters.dart';
import 'package:home_tuition_nepal_app/features/tutor_profile/domain/models/profile_enums.dart';

void main() {
  group('MapFilters.copyWith', () {
    test('copyWith narrows by level', () {
      const f = MapFilters();
      final next = f.copyWith(level: StudentLevel.see);
      expect(next.level, StudentLevel.see);
      // Default radiusKm is null — meaning "no distance limit".
      expect(next.radiusKm, isNull);
    });

    test('clearRadius wipes a previously set radius', () {
      const f = MapFilters(radiusKm: 10);
      final cleared = f.copyWith(clearRadius: true);
      expect(cleared.radiusKm, isNull);
    });

    test('clearLevel resets to null even when level is also passed', () {
      const f = MapFilters(level: StudentLevel.see);
      final cleared = f.copyWith(clearLevel: true);
      expect(cleared.level, isNull);
    });

    test('clearMode resets mode', () {
      const f = MapFilters(mode: TeachingMode.online);
      expect(f.copyWith(clearMode: true).mode, isNull);
    });

    test('toggling verifiedOnly preserves other fields', () {
      const f = MapFilters(level: StudentLevel.see, radiusKm: 10);
      final next = f.copyWith(verifiedOnly: true);
      expect(next.verifiedOnly, isTrue);
      expect(next.level, StudentLevel.see);
      expect(next.radiusKm, 10);
    });
  });
}
