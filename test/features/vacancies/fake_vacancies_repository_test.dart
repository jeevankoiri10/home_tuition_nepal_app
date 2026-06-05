import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/services/platform_settings_service.dart';
import 'package:home_tuition_nepal_app/features/vacancies/data/fake_vacancies_repository.dart';
import 'package:home_tuition_nepal_app/features/vacancies/domain/connect_cost.dart';
import 'package:home_tuition_nepal_app/features/vacancies/domain/vacancies_repository.dart';
import 'package:home_tuition_nepal_app/features/wallet/data/fake_wallet_repository.dart';

void main() {
  late PlatformSettingsService settings;
  late FakeWalletRepository wallet;
  late FakeVacanciesRepository repo;

  setUp(() {
    settings = PlatformSettingsService();
    wallet = FakeWalletRepository(settings);
    repo = FakeVacanciesRepository(wallet, settings);
  });

  group('FakeVacanciesRepository', () {
    test('listOpen returns the seeded vacancies', () async {
      final list = await repo.listOpen();
      expect(list, isNotEmpty);
      expect(list.first.code, startsWith('HTN-'));
    });

    test('subject filter narrows the list', () async {
      final all = await repo.listOpen();
      final maths = await repo.listOpen(subjectQuery: 'Maths');
      expect(maths.length, lessThanOrEqualTo(all.length));
      for (final v in maths) {
        final hasMaths = v.subjects.any((s) => s.toLowerCase().contains('maths'));
        expect(hasMaths, isTrue);
      }
    });

    test('apply debits the percentage connect cost and records the application',
        () async {
      final list = await repo.listOpen();
      final vacancy = list.first;
      final expectedCost = ConnectCost.forVacancyWithSettings(vacancy, settings);
      final balanceBefore = await wallet.loadBalance('fake-login');
      await repo.apply(vacancyId: vacancy.id, coverNote: 'I can help.');
      final balanceAfter = await wallet.loadBalance('fake-login');
      expect(balanceAfter, balanceBefore - expectedCost);

      final apps = await repo.listMyApplications('fake-login');
      expect(apps.length, 1);
      expect(apps.first.vacancyId, vacancy.id);
      expect(apps.first.coinsSpent, expectedCost);
    });

    test('applying twice to the same vacancy throws already_applied', () async {
      final v = (await repo.listOpen()).first;
      await repo.apply(vacancyId: v.id, coverNote: 'Round one.');
      expect(
        () => repo.apply(vacancyId: v.id, coverNote: 'Round two.'),
        throwsA(isA<VacanciesException>()
            .having((e) => e.isAlreadyApplied, 'isAlreadyApplied', true)),
      );
    });
  });

  group('FakeVacanciesRepository.searchNearby', () {
    // Kathmandu Valley centre — the seed scatters vacancies around here.
    const lat = 27.7050;
    const lng = 85.3300;

    test('returns located vacancies sorted nearest-first, each with distance', () async {
      final results = await repo.searchNearby(lat: lat, lng: lng);
      expect(results, isNotEmpty);
      expect(results.every((v) => v.hasLocation && v.distanceKm != null), isTrue);
      for (var i = 1; i < results.length; i++) {
        expect(results[i - 1].distanceKm! <= results[i].distanceKm! + 1e-9, isTrue);
      }
    });

    test('radius limit excludes far vacancies', () async {
      final all = await repo.searchNearby(lat: lat, lng: lng);
      final near = await repo.searchNearby(lat: lat, lng: lng, radiusKm: 1);
      expect(near.length, lessThanOrEqualTo(all.length));
      expect(near.every((v) => v.distanceKm! <= 1.0 + 1e-9), isTrue);
    });

    test('subjectQuery filters by subject case-insensitively', () async {
      final maths = await repo.searchNearby(lat: lat, lng: lng, subjectQuery: 'maths');
      expect(
        maths.every((v) => v.subjects.any((s) => s.toLowerCase().contains('maths'))),
        isTrue,
      );
    });
  });
}
