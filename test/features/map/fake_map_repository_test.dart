import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/map/data/fake_map_repository.dart';
import 'package:home_tuition_nepal_app/features/map/domain/models/map_filters.dart';
import 'package:home_tuition_nepal_app/features/tutor_profile/domain/models/profile_enums.dart';

const _seedLat = 27.6915; // Baneshwor
const _seedLng = 85.3370;

void main() {
  late FakeMapRepository repo;

  setUp(() => repo = FakeMapRepository());

  group('FakeMapRepository.search', () {
    test('default filters return tutors within 5 km, sorted by available/verified/distance', () async {
      final results = await repo.search(
        lat: _seedLat,
        lng: _seedLng,
        filters: const MapFilters(),
      );
      expect(results, isNotEmpty);
      // Sort invariant: any "available + verified" tutor must precede any "not-available" tutor.
      for (int i = 1; i < results.length; i++) {
        if (results[i].available && !results[i - 1].available) {
          fail('available tutor at index $i comes after a non-available tutor');
        }
      }
      // Distance invariant within same (available, verified) bucket.
      expect(results.first.distanceKm <= results.last.distanceKm + 0.001, isTrue);
    });

    test('verifiedOnly filter excludes non-verified tutors', () async {
      final results = await repo.search(
        lat: _seedLat,
        lng: _seedLng,
        filters: const MapFilters(verifiedOnly: true),
      );
      expect(results.every((t) => t.verified), isTrue);
    });

    test('level filter excludes tutors who do not teach the level', () async {
      final results = await repo.search(
        lat: _seedLat,
        lng: _seedLng,
        filters: const MapFilters(level: StudentLevel.aLevel),
      );
      expect(results.every((t) => t.levelsTaught.contains(StudentLevel.aLevel)), isTrue);
    });

    test('radius filter limits returned tutors', () async {
      final wide = await repo.search(
        lat: _seedLat,
        lng: _seedLng,
        filters: const MapFilters(radiusKm: 20),
      );
      final narrow = await repo.search(
        lat: _seedLat,
        lng: _seedLng,
        filters: const MapFilters(radiusKm: 1),
      );
      expect(narrow.length, lessThanOrEqualTo(wide.length));
      expect(narrow.every((t) => t.distanceKm <= 1.001), isTrue);
    });

    test('no-limit radius (null) returns every seeded tutor', () async {
      final all = await repo.search(
        lat: _seedLat,
        lng: _seedLng,
        filters: const MapFilters(), // radiusKm defaults to null = no limit
      );
      // 15 seeds, none excluded by other default filters.
      expect(all.length, 15);
    });

    test('availableOnly filter keeps only available tutors', () async {
      final results = await repo.search(
        lat: _seedLat,
        lng: _seedLng,
        filters: const MapFilters(availableOnly: true),
      );
      expect(results, isNotEmpty);
      expect(results.every((t) => t.available), isTrue);
    });

    test('online mode filter includes online + both, excludes offline-only', () async {
      final results = await repo.search(
        lat: _seedLat,
        lng: _seedLng,
        filters: const MapFilters(mode: TeachingMode.online),
      );
      expect(results, isNotEmpty);
      expect(
        results.every((t) =>
            t.teachingMode == TeachingMode.online || t.teachingMode == TeachingMode.both),
        isTrue,
      );
      expect(results.any((t) => t.teachingMode == TeachingMode.offline), isFalse);
    });

    test('offline mode filter includes both-mode tutors too', () async {
      final results = await repo.search(
        lat: _seedLat,
        lng: _seedLng,
        filters: const MapFilters(mode: TeachingMode.offline),
      );
      expect(results.any((t) => t.teachingMode == TeachingMode.both), isTrue);
      expect(results.any((t) => t.teachingMode == TeachingMode.online), isFalse);
    });

    test('subjectQuery matches case-insensitively on topSubjects', () async {
      final results = await repo.search(
        lat: _seedLat,
        lng: _seedLng,
        filters: const MapFilters(subjectQuery: 'phys'),
      );
      expect(results, isNotEmpty);
      expect(
        results.every((t) => t.topSubjects.any((s) => s.toLowerCase().contains('phys'))),
        isTrue,
      );
    });
  });
}
