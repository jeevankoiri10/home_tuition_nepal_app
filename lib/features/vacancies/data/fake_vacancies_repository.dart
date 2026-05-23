import 'dart:math';

import '../../student_requests/domain/models/request_enums.dart';
import '../../wallet/domain/wallet_repository.dart';
import '../domain/models/vacancy.dart';
import '../domain/models/vacancy_application.dart';
import '../domain/vacancies_repository.dart';

/// In-memory vacancies repository seeded with ~10 demo HTN-NNNNN vacancies
/// across Kathmandu Valley areas. Used when no Supabase creds are available.
class FakeVacanciesRepository implements VacanciesRepository {
  FakeVacanciesRepository(this._wallet);

  final WalletRepository _wallet;
  final List<Vacancy> _seed = _buildSeed();
  final Map<String, List<VacancyApplication>> _appsByTutor = {};
  final Set<String> _appliedKeys = {};

  @override
  Future<List<Vacancy>> listOpen({String? subjectQuery, String? areaQuery}) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _seed.where((v) {
      if (subjectQuery != null && subjectQuery.isNotEmpty) {
        final q = subjectQuery.toLowerCase();
        if (!v.subjects.any((s) => s.toLowerCase().contains(q))) return false;
      }
      if (areaQuery != null && areaQuery.isNotEmpty) {
        if (!v.areaLabel.toLowerCase().contains(areaQuery.toLowerCase())) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<List<VacancyApplication>> listMyApplications(String tutorId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<VacancyApplication>.from(_appsByTutor[tutorId] ?? const []);
  }

  @override
  Future<String> apply({
    required String vacancyId,
    required String coverNote,
    num? expectedRate,
    String? cvStoragePath,
  }) async {
    // Repo-layer call; the caller (BLoC) passes the tutor id implicitly via
    // the wallet. For the fake repo we infer the caller from a single demo
    // wallet — production goes through Supabase RPC with auth.uid().
    const demoTutorId = 'fake-login'; // matches FakeAuthRepository sample id
    final key = '$vacancyId/$demoTutorId';
    if (_appliedKeys.contains(key)) {
      throw VacanciesException('already_applied', 'You already applied to this vacancy.');
    }

    // Atomic-ish for the demo: debit first, then create the row. If the debit
    // throws insufficient_coins we never create the application.
    try {
      await _wallet.applyToVacancy(tutorId: demoTutorId, vacancyId: vacancyId);
    } on WalletException catch (e) {
      throw VacanciesException(e.code, e.message);
    }

    final app = VacancyApplication(
      id: 'app-${_appliedKeys.length}',
      vacancyId: vacancyId,
      tutorId: demoTutorId,
      coverNote: coverNote,
      expectedRate: expectedRate,
      cvStoragePath: cvStoragePath,
      coinsSpent: 1,
      createdAt: DateTime.now(),
    );
    _appsByTutor.putIfAbsent(demoTutorId, () => []).insert(0, app);
    _appliedKeys.add(key);
    return app.id;
  }

  static List<Vacancy> _buildSeed() {
    final rng = Random(11);
    const areas = [
      'Kapan, Faika Chowk',
      'Baneshwor',
      'Balkot, near Boys Futsal',
      'Lazimpat',
      'Kupandole',
      'Koteswor',
      'Maharajgunj',
      'Sundhara',
      'Chabahil',
      'Putalisadak',
    ];
    const grades = [
      'Class 7',
      'Class 10',
      '+2 Science',
      'Grade 5',
      'A Level',
      'Class 11 (A Level)',
    ];
    const subjectSets = [
      ['Maths', 'Science'],
      ['All'],
      ['Physics', 'Maths'],
      ['Nepali', 'English'],
      ['Accountancy'],
      ['Chemistry'],
      ['English Speaking'],
    ];
    return List.generate(areas.length, (i) {
      final code = 'HTN-${(276 + i).toString().padLeft(5, '0')}';
      final base = 4000 + rng.nextInt(12) * 1000;
      return Vacancy(
        id: 'v-$i',
        code: code,
        title: 'Home Tuition Teacher Required',
        areaLabel: areas[i],
        grade: grades[i % grades.length],
        subjects: subjectSets[i % subjectSets.length],
        salaryMinNpr: base,
        salaryMaxNpr: i.isEven ? base + 2000 : null,
        salaryPeriod: 'month',
        durationText: i.isEven ? 'Evening (5pm – 6pm)' : '7:45 PM – 8:45 PM',
        genderPref: i % 3 == 0
            ? GenderPref.female
            : (i % 3 == 1 ? GenderPref.male : GenderPref.any),
        mode: i % 4 == 0 ? JobMode.online : JobMode.inPerson,
        notes: 'Posted by Home Tuition Nepal admin. '
            'Only nearby & experienced tutors are requested to apply.',
        createdAt: DateTime.now().subtract(Duration(hours: i * 3)),
      );
    });
  }
}
