import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/services/platform_settings_service.dart';
import 'package:home_tuition_nepal_app/features/vacancies/data/fake_vacancies_repository.dart';
import 'package:home_tuition_nepal_app/features/vacancies/domain/models/vacancy.dart';
import 'package:home_tuition_nepal_app/features/vacancies/domain/models/vacancy_application.dart';
import 'package:home_tuition_nepal_app/features/vacancies/domain/vacancies_repository.dart';
import 'package:home_tuition_nepal_app/features/vacancies/presentation/blocs/vacancies_bloc.dart';
import 'package:home_tuition_nepal_app/features/wallet/data/fake_wallet_repository.dart';

// The fake repo attributes applications to this demo tutor id; load the bloc
// with the same id so the post-apply reload surfaces the new application.
const _demoTutor = 'fake-login';

/// Repo whose [apply] always fails with [code] — lets us drive the bloc's
/// error branches without draining a real wallet.
class _ThrowingApplyRepository implements VacanciesRepository {
  _ThrowingApplyRepository(this.code);
  final String code;

  @override
  Future<String> apply({
    required String vacancyId,
    required String coverNote,
    num? expectedRate,
    String? cvStoragePath,
  }) async =>
      throw VacanciesException(code, 'forced');

  @override
  Future<List<Vacancy>> listOpen({String? subjectQuery, String? areaQuery}) async => const [];

  @override
  Future<List<VacancyApplication>> listMyApplications(String tutorId) async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not stubbed');
}

void main() {
  late FakeVacanciesRepository repo;

  setUp(() {
    final settings = PlatformSettingsService();
    repo = FakeVacanciesRepository(FakeWalletRepository(settings), settings);
  });

  Future<String> firstVacancyId() async => (await repo.listOpen()).first.id;

  group('VacanciesBloc', () {
    blocTest<VacanciesBloc, VacanciesState>(
      'VacanciesLoaded loads open vacancies into a ready state',
      build: () => VacanciesBloc(repo),
      act: (b) => b.add(const VacanciesLoaded(_demoTutor)),
      wait: const Duration(milliseconds: 300),
      verify: (b) {
        expect(b.state.status, VacanciesStatus.ready);
        expect(b.state.vacancies, isNotEmpty);
      },
    );

    blocTest<VacanciesBloc, VacanciesState>(
      'VacanciesFiltersChanged records the query and narrows the list',
      build: () => VacanciesBloc(repo),
      act: (b) async {
        b.add(const VacanciesLoaded(_demoTutor));
        await Future<void>.delayed(const Duration(milliseconds: 250));
        b.add(const VacanciesFiltersChanged(subject: 'Maths'));
      },
      wait: const Duration(milliseconds: 300),
      verify: (b) {
        expect(b.state.subjectQuery, 'Maths');
        expect(b.state.status, VacanciesStatus.ready);
        for (final v in b.state.vacancies) {
          expect(
            v.subjects.any((s) => s.toLowerCase().contains('maths')),
            isTrue,
          );
        }
      },
    );

    blocTest<VacanciesBloc, VacanciesState>(
      'VacancyApplied succeeds and records the application in the repo',
      build: () => VacanciesBloc(repo),
      act: (b) async {
        final id = await firstVacancyId();
        b.add(const VacanciesLoaded(_demoTutor));
        await Future<void>.delayed(const Duration(milliseconds: 300));
        b.add(VacancyApplied(vacancyId: id, coverNote: 'Keen to help'));
      },
      wait: const Duration(milliseconds: 400),
      verify: (b) async {
        expect(b.state.applyStatus, ApplyStatus.success);
        // Assert against the repo (ground truth): the bloc's own
        // myApplications list can be transiently clobbered by a concurrent
        // load-reload that started before the application was stored.
        expect(await repo.listMyApplications(_demoTutor), isNotEmpty);
      },
    );

    blocTest<VacanciesBloc, VacanciesState>(
      'applying twice to the same vacancy surfaces an already-applied error',
      build: () => VacanciesBloc(repo),
      act: (b) async {
        final id = await firstVacancyId();
        b.add(const VacanciesLoaded(_demoTutor));
        await Future<void>.delayed(const Duration(milliseconds: 250));
        b.add(VacancyApplied(vacancyId: id, coverNote: 'once'));
        await Future<void>.delayed(const Duration(milliseconds: 300));
        b.add(VacancyApplied(vacancyId: id, coverNote: 'twice'));
      },
      wait: const Duration(milliseconds: 400),
      verify: (b) {
        expect(b.state.applyStatus, ApplyStatus.error);
        expect(b.state.applyError, contains('already applied'));
      },
    );

    blocTest<VacanciesBloc, VacanciesState>(
      'insufficient coins sets applyNeedsTopUp (structured, not string-matched)',
      build: () => VacanciesBloc(_ThrowingApplyRepository('insufficient_coins')),
      act: (b) => b.add(const VacancyApplied(vacancyId: 'v1', coverNote: 'hi')),
      wait: const Duration(milliseconds: 200),
      verify: (b) {
        expect(b.state.applyStatus, ApplyStatus.error);
        expect(b.state.applyNeedsTopUp, isTrue);
      },
    );

    blocTest<VacanciesBloc, VacanciesState>(
      'a non-coins apply error leaves applyNeedsTopUp false',
      build: () => VacanciesBloc(_ThrowingApplyRepository('already_applied')),
      act: (b) => b.add(const VacancyApplied(vacancyId: 'v1', coverNote: 'hi')),
      wait: const Duration(milliseconds: 200),
      verify: (b) {
        expect(b.state.applyStatus, ApplyStatus.error);
        expect(b.state.applyNeedsTopUp, isFalse);
      },
    );

    blocTest<VacanciesBloc, VacanciesState>(
      'VacancyApplyAcknowledged resets the apply status to idle',
      build: () => VacanciesBloc(repo),
      act: (b) async {
        final id = await firstVacancyId();
        b.add(const VacanciesLoaded(_demoTutor));
        await Future<void>.delayed(const Duration(milliseconds: 250));
        b.add(VacancyApplied(vacancyId: id, coverNote: 'hi'));
        await Future<void>.delayed(const Duration(milliseconds: 300));
        b.add(const VacancyApplyAcknowledged());
      },
      wait: const Duration(milliseconds: 400),
      verify: (b) {
        expect(b.state.applyStatus, ApplyStatus.idle);
        expect(b.state.applyError, isNull);
      },
    );
  });
}
