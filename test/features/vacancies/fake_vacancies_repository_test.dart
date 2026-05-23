import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/services/platform_settings_service.dart';
import 'package:home_tuition_nepal_app/features/vacancies/data/fake_vacancies_repository.dart';
import 'package:home_tuition_nepal_app/features/vacancies/domain/vacancies_repository.dart';
import 'package:home_tuition_nepal_app/features/wallet/data/fake_wallet_repository.dart';

void main() {
  late FakeWalletRepository wallet;
  late FakeVacanciesRepository repo;

  setUp(() {
    wallet = FakeWalletRepository(PlatformSettingsService());
    repo = FakeVacanciesRepository(wallet);
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

    test('apply debits one coin and records the application', () async {
      final list = await repo.listOpen();
      final id = list.first.id;
      final balanceBefore = await wallet.loadBalance('fake-login');
      await repo.apply(vacancyId: id, coverNote: 'I can help.');
      final balanceAfter = await wallet.loadBalance('fake-login');
      expect(balanceAfter, balanceBefore - 1);

      final apps = await repo.listMyApplications('fake-login');
      expect(apps.length, 1);
      expect(apps.first.vacancyId, id);
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
}
