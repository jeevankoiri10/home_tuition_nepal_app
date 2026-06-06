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

  group('MapFilters.expandedRadius', () {
    test('steps up to the next tier', () {
      expect(const MapFilters(radiusKm: 1).expandedRadius().radiusKm, 3);
      expect(const MapFilters(radiusKm: 3).expandedRadius().radiusKm, 5);
      expect(const MapFilters(radiusKm: 5).expandedRadius().radiusKm, 10);
    });

    test('a custom radius jumps to the next-larger tier', () {
      expect(const MapFilters(radiusKm: 2).expandedRadius().radiusKm, 3);
      expect(const MapFilters(radiusKm: 7).expandedRadius().radiusKm, 10);
    });

    test('widening past the largest tier goes to no limit', () {
      expect(const MapFilters(radiusKm: 10).expandedRadius().radiusKm, isNull);
      expect(const MapFilters(radiusKm: 25).expandedRadius().radiusKm, isNull);
    });

    test('already-unlimited stays unlimited and cannot expand', () {
      const f = MapFilters();
      expect(f.canExpandRadius, isFalse);
      expect(f.expandedRadius(), f);
    });

    test('a set radius can expand', () {
      expect(const MapFilters(radiusKm: 5).canExpandRadius, isTrue);
    });

    test('expanding preserves other filters', () {
      const f = MapFilters(
        level: StudentLevel.see,
        verifiedOnly: true,
        radiusKm: 3,
      );
      final next = f.expandedRadius();
      expect(next.radiusKm, 5);
      expect(next.level, StudentLevel.see);
      expect(next.verifiedOnly, isTrue);
    });
  });

  group('MapFilters.hasActiveFilters', () {
    test('is false for the default (everything, no distance limit)', () {
      expect(const MapFilters().hasActiveFilters, isFalse);
    });

    test('is true when any single filter narrows the default', () {
      expect(const MapFilters(level: StudentLevel.see).hasActiveFilters, isTrue);
      expect(const MapFilters(mode: TeachingMode.online).hasActiveFilters, isTrue);
      expect(const MapFilters(verifiedOnly: true).hasActiveFilters, isTrue);
      expect(const MapFilters(availableOnly: true).hasActiveFilters, isTrue);
      expect(const MapFilters(radiusKm: 5).hasActiveFilters, isTrue);
      expect(const MapFilters(subjectQuery: 'Maths').hasActiveFilters, isTrue);
    });

    test('clearing back to the default makes it false again', () {
      const f = MapFilters(level: StudentLevel.see, radiusKm: 5);
      expect(const MapFilters().hasActiveFilters, isFalse);
      expect(f.hasActiveFilters, isTrue);
    });
  });

  group('MapFilters.radiusMeters', () {
    test('is null when there is no distance limit (no circle drawn)', () {
      expect(const MapFilters().radiusMeters, isNull);
    });

    test('converts the km radius to metres for the map circle', () {
      expect(const MapFilters(radiusKm: 3).radiusMeters, 3000);
      expect(const MapFilters(radiusKm: 0.5).radiusMeters, 500);
    });
  });
}
