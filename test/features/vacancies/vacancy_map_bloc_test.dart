import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/services/location_service.dart';
import 'package:home_tuition_nepal_app/features/vacancies/data/fake_vacancies_repository.dart';
import 'package:home_tuition_nepal_app/features/vacancies/domain/models/vacancy.dart';
import 'package:home_tuition_nepal_app/features/vacancies/domain/models/vacancy_application.dart';
import 'package:home_tuition_nepal_app/features/vacancies/domain/vacancies_repository.dart';
import 'package:home_tuition_nepal_app/features/vacancies/domain/vacancy_sort.dart';
import 'package:home_tuition_nepal_app/features/vacancies/presentation/blocs/vacancy_map_bloc.dart';
import 'package:home_tuition_nepal_app/features/wallet/data/fake_wallet_repository.dart';
import 'package:home_tuition_nepal_app/core/services/platform_settings_service.dart';

class _FakeLocationService extends LocationService {
  @override
  Future<(double, double)> currentOrFallback() async => (27.7050, 85.3300);
}

FakeVacanciesRepository _repo() {
  final settings = PlatformSettingsService();
  return FakeVacanciesRepository(FakeWalletRepository(settings), settings);
}

/// Fails the first [failures] nearby searches, then delegates to a real fake —
/// lets us assert the error state and recovery on the tutor vacancy map.
class _FlakyVacanciesRepository implements VacanciesRepository {
  final FakeVacanciesRepository _inner = _repo();
  int failures = 1;

  @override
  Future<List<Vacancy>> searchNearby({
    required double lat,
    required double lng,
    double? radiusKm,
    String? subjectQuery,
  }) async {
    if (failures > 0) {
      failures--;
      throw VacanciesException('network', 'offline');
    }
    return _inner.searchNearby(
        lat: lat, lng: lng, radiusKm: radiusKm, subjectQuery: subjectQuery);
  }

  @override
  Future<List<Vacancy>> listOpen({String? subjectQuery, String? areaQuery}) =>
      _inner.listOpen(subjectQuery: subjectQuery, areaQuery: areaQuery);

  @override
  Future<List<VacancyApplication>> listMyApplications(String tutorId) =>
      _inner.listMyApplications(tutorId);

  @override
  Future<String> apply({
    required String vacancyId,
    required String coverNote,
    num? expectedRate,
    String? cvStoragePath,
  }) =>
      _inner.apply(
        vacancyId: vacancyId,
        coverNote: coverNote,
        expectedRate: expectedRate,
        cvStoragePath: cvStoragePath,
      );
}

void main() {
  group('VacancyMapBloc', () {
    blocTest<VacancyMapBloc, VacancyMapState>(
      'VacancyMapStarted locates then loads nearby vacancies',
      build: () => VacancyMapBloc(_repo(), _FakeLocationService()),
      act: (b) => b.add(const VacancyMapStarted()),
      wait: const Duration(milliseconds: 400),
      verify: (b) {
        expect(b.state.status, VacancyMapStatus.ready);
        expect(b.state.centerLat, 27.7050);
        expect(b.state.vacancies, isNotEmpty);
        expect(b.state.vacancies.every((v) => v.hasLocation), isTrue);
      },
    );

    blocTest<VacancyMapBloc, VacancyMapState>(
      'camera move debounces but eventually re-queries',
      build: () => VacancyMapBloc(_repo(), _FakeLocationService()),
      act: (b) async {
        b.add(const VacancyMapStarted());
        await Future<void>.delayed(const Duration(milliseconds: 400));
        b.add(const VacancyMapCameraMoved(lat: 27.71, lng: 85.33));
      },
      wait: const Duration(milliseconds: 800),
      verify: (b) {
        expect(b.state.status, VacancyMapStatus.ready);
        expect(b.state.centerLat, 27.71);
      },
    );

    blocTest<VacancyMapBloc, VacancyMapState>(
      'selecting a vacancy populates selectedId',
      build: () => VacancyMapBloc(_repo(), _FakeLocationService()),
      act: (b) => b.add(const VacancyMapSelected('v-1')),
      verify: (b) => expect(b.state.selectedId, 'v-1'),
    );

    blocTest<VacancyMapBloc, VacancyMapState>(
      'changing the sort re-orders the loaded vacancies without re-querying',
      build: () => VacancyMapBloc(_repo(), _FakeLocationService()),
      act: (b) async {
        b.add(const VacancyMapStarted());
        await Future<void>.delayed(const Duration(milliseconds: 400));
        b.add(const VacancyMapSortChanged(VacancySort.salaryHighLow));
      },
      wait: const Duration(milliseconds: 300),
      verify: (b) {
        expect(b.state.sort, VacancySort.salaryHighLow);
        final pays = b.state.vacancies
            .map((v) => v.salaryMaxNpr ?? v.salaryMinNpr ?? -1)
            .toList();
        final descending = [...pays]..sort((x, y) => y.compareTo(x));
        expect(pays, descending);
      },
    );

    blocTest<VacancyMapBloc, VacancyMapState>(
      'tapping the map clears the selection',
      build: () => VacancyMapBloc(_repo(), _FakeLocationService()),
      act: (b) async {
        b.add(const VacancyMapSelected('v-1'));
        b.add(const VacancyMapSelected(null));
      },
      verify: (b) => expect(b.state.selectedId, isNull),
    );

    blocTest<VacancyMapBloc, VacancyMapState>(
      'search failure surfaces VacancyMapStatus.error with a message',
      build: () => VacancyMapBloc(_FlakyVacanciesRepository(), _FakeLocationService()),
      act: (b) => b.add(const VacancyMapStarted()),
      wait: const Duration(milliseconds: 400),
      verify: (b) {
        expect(b.state.status, VacancyMapStatus.error);
        expect(b.state.errorMessage, isNotNull);
        expect(b.state.vacancies, isEmpty);
      },
    );

    blocTest<VacancyMapBloc, VacancyMapState>(
      'retry after a failure recovers to ready with vacancies',
      build: () => VacancyMapBloc(_FlakyVacanciesRepository(), _FakeLocationService()),
      act: (b) async {
        b.add(const VacancyMapStarted());
        await Future<void>.delayed(const Duration(milliseconds: 300));
        b.add(const VacancyMapRefreshRequested());
      },
      wait: const Duration(milliseconds: 600),
      verify: (b) {
        expect(b.state.status, VacancyMapStatus.ready);
        expect(b.state.vacancies, isNotEmpty);
        expect(b.state.errorMessage, isNull);
      },
    );
  });
}
