import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/services/location_service.dart';
import 'package:home_tuition_nepal_app/features/map/data/fake_map_repository.dart';
import 'package:home_tuition_nepal_app/features/map/domain/models/map_filters.dart';
import 'package:home_tuition_nepal_app/features/map/presentation/blocs/map_bloc.dart';
import 'package:home_tuition_nepal_app/features/tutor_profile/domain/models/profile_enums.dart';

class _FakeLocationService extends LocationService {
  @override
  Future<(double, double)> currentOrFallback() async => (27.6915, 85.3370);
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
