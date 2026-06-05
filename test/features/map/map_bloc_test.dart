import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/services/location_service.dart';
import 'package:home_tuition_nepal_app/features/map/data/fake_map_repository.dart';
import 'package:home_tuition_nepal_app/features/map/domain/map_repository.dart';
import 'package:home_tuition_nepal_app/features/map/domain/map_sort.dart';
import 'package:home_tuition_nepal_app/features/map/domain/models/map_filters.dart';
import 'package:home_tuition_nepal_app/features/map/domain/models/map_tutor.dart';
import 'package:home_tuition_nepal_app/features/map/presentation/blocs/map_bloc.dart';
import 'package:home_tuition_nepal_app/features/tutor_profile/domain/models/profile_enums.dart';

class _FakeLocationService extends LocationService {
  @override
  Future<(double, double)> currentOrFallback() async => (27.6915, 85.3370);
}

/// Fails the first [failures] searches with a [MapRepositoryException], then
/// delegates to a real fake — lets us assert the error state and recovery.
class _FlakyMapRepository implements MapRepository {
  final FakeMapRepository _delegate = FakeMapRepository();

  /// Number of leading searches that fail before results flow.
  int failures = 1;

  @override
  Future<List<MapTutor>> search({
    required double lat,
    required double lng,
    required MapFilters filters,
  }) async {
    if (failures > 0) {
      failures--;
      throw MapRepositoryException('network', 'offline');
    }
    return _delegate.search(lat: lat, lng: lng, filters: filters);
  }
}

void main() {
  group('MapBloc', () {
    blocTest<MapBloc, MapState>(
      'MapStarted resolves to ready with tutors',
      build: () => MapBloc(FakeMapRepository(), _FakeLocationService()),
      act: (bloc) => bloc.add(const MapStarted()),
      wait: const Duration(milliseconds: 600),
      verify: (bloc) {
        expect(bloc.state.status, MapStatus.ready);
        expect(bloc.state.tutors, isNotEmpty);
        expect(bloc.state.centerLat, 27.6915);
      },
    );

    blocTest<MapBloc, MapState>(
      'filter change debounces but eventually re-queries',
      build: () => MapBloc(FakeMapRepository(), _FakeLocationService()),
      act: (bloc) async {
        bloc.add(const MapStarted());
        await Future<void>.delayed(const Duration(milliseconds: 500));
        bloc.add(MapFiltersChanged(const MapFilters(level: StudentLevel.aLevel)));
      },
      wait: const Duration(milliseconds: 1500),
      verify: (bloc) {
        expect(bloc.state.status, MapStatus.ready);
        expect(bloc.state.filters.level, StudentLevel.aLevel);
        expect(bloc.state.tutors.every((t) => t.levelsTaught.contains(StudentLevel.aLevel)),
            isTrue);
      },
    );

    blocTest<MapBloc, MapState>(
      'search failure surfaces MapStatus.error with a message',
      build: () => MapBloc(_FlakyMapRepository(), _FakeLocationService()),
      act: (bloc) => bloc.add(const MapStarted()),
      wait: const Duration(milliseconds: 600),
      verify: (bloc) {
        expect(bloc.state.status, MapStatus.error);
        expect(bloc.state.errorMessage, isNotNull);
        expect(bloc.state.tutors, isEmpty);
      },
    );

    blocTest<MapBloc, MapState>(
      'retry after a failure recovers to ready with tutors',
      build: () => MapBloc(_FlakyMapRepository(), _FakeLocationService()),
      act: (bloc) async {
        bloc.add(const MapStarted());
        await Future<void>.delayed(const Duration(milliseconds: 400));
        bloc.add(const MapRefreshRequested());
      },
      wait: const Duration(milliseconds: 800),
      verify: (bloc) {
        expect(bloc.state.status, MapStatus.ready);
        expect(bloc.state.tutors, isNotEmpty);
        expect(bloc.state.errorMessage, isNull);
      },
    );

    blocTest<MapBloc, MapState>(
      'changing the sort re-orders the loaded tutors without re-querying',
      build: () => MapBloc(FakeMapRepository(), _FakeLocationService()),
      act: (bloc) async {
        bloc.add(const MapStarted());
        await Future<void>.delayed(const Duration(milliseconds: 500));
        bloc.add(const MapSortChanged(MapSort.priceLowHigh));
      },
      wait: const Duration(milliseconds: 300),
      verify: (bloc) {
        expect(bloc.state.sort, MapSort.priceLowHigh);
        // Priced tutors lead, ascending; unpriced (null) sort to the end.
        final prices = bloc.state.tutors
            .map((t) => t.fromPriceNpr)
            .whereType<num>()
            .toList();
        final ascending = [...prices]..sort();
        expect(prices, ascending);
      },
    );

    blocTest<MapBloc, MapState>(
      'long-press searches around the dropped point and recenters',
      build: () => MapBloc(FakeMapRepository(), _FakeLocationService()),
      act: (bloc) async {
        bloc.add(const MapStarted());
        await Future<void>.delayed(const Duration(milliseconds: 500));
        bloc.add(const MapSearchHere(lat: 27.65, lng: 85.40));
      },
      wait: const Duration(milliseconds: 700),
      verify: (bloc) {
        expect(bloc.state.status, MapStatus.ready);
        expect(bloc.state.centerLat, 27.65);
        expect(bloc.state.centerLng, 85.40);
        // recenterSeq bumped so the page flies the camera to the dropped point.
        expect(bloc.state.recenterSeq, greaterThan(0));
        // selection cleared since the old pick likely isn't near the new centre.
        expect(bloc.state.selectedTutorId, isNull);
      },
    );

    blocTest<MapBloc, MapState>(
      'selecting a tutor populates selectedTutor',
      build: () => MapBloc(FakeMapRepository(), _FakeLocationService()),
      act: (bloc) async {
        bloc.add(const MapStarted());
        await Future<void>.delayed(const Duration(milliseconds: 500));
        final id = bloc.state.tutors.first.tutorId;
        bloc.add(MapTutorSelected(id));
      },
      wait: const Duration(milliseconds: 700),
      verify: (bloc) {
        expect(bloc.state.selectedTutorId, isNotNull);
        expect(bloc.state.selectedTutor, isNotNull);
      },
    );
  });
}
