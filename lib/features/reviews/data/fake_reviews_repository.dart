import '../../../core/services/platform_settings_service.dart';
import '../../../core/utils/phone_ban_regex.dart';
import '../../wallet/domain/wallet_repository.dart';
import '../domain/models/review.dart';
import '../domain/reviews_repository.dart';

/// In-memory reviews + boosts. Mirrors the SQL contracts:
///   - submit gates on prior unlock (idempotent in-memory)
///   - boost flows debit the configured coin cost
class FakeReviewsRepository implements ReviewsRepository {
  FakeReviewsRepository(this._wallet, this._settings);

  final WalletRepository _wallet;
  final PlatformSettingsService _settings;

  final Map<String, List<Review>> _byTutor = {};
  final Map<String, List<Review>> _byStudent = {};
  int _counter = 0;

  // Dev seam: the bloc/UI runs as this id in fake mode.
  static const _demoSelf = 'fake-login';

  @override
  Future<List<Review>> listForTutor(String tutorId, {int limit = 50}) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return List<Review>.from(_byTutor[tutorId] ?? const []).take(limit).toList();
  }

  @override
  Future<TutorRatingSummary> summaryForTutor(String tutorId) async {
    final list = _byTutor[tutorId] ?? const <Review>[];
    if (list.isEmpty) return const TutorRatingSummary(average: 0, count: 0);
    final avg = list.map((r) => r.stars).reduce((a, b) => a + b) / list.length;
    return TutorRatingSummary(average: avg, count: list.length);
  }

  @override
  Future<Review> submit({
    required String tutorId,
    required int stars,
    String? text,
  }) async {
    if (stars < 1 || stars > 5) {
      throw ReviewsException('invalid_stars', 'Stars must be between 1 and 5.');
    }
    if (text != null && PhoneBanRegex.isViolation(text)) {
      throw ReviewsException('phone_in_review', 'Remove phone numbers or contact details.');
    }
    const demoStudent = 'fake-login';
    if (demoStudent == tutorId) {
      throw ReviewsException('cannot_review_self');
    }

    final unlocked = await _wallet.hasUnlocked(studentId: demoStudent, tutorId: tutorId);
    if (!unlocked) {
      throw ReviewsException('gate_not_met', 'Unlock the tutor first to leave a review.');
    }

    final existing = (_byTutor[tutorId] ?? const <Review>[])
        .where((r) => r.studentId == demoStudent)
        .toList();

    final saved = Review(
      id: existing.isEmpty ? 'rev-${++_counter}' : existing.first.id,
      tutorId: tutorId,
      studentId: demoStudent,
      stars: stars,
      text: text,
      createdAt: existing.isEmpty ? DateTime.now() : existing.first.createdAt,
    );

    final list = _byTutor.putIfAbsent(tutorId, () => []);
    list.removeWhere((r) => r.studentId == demoStudent);
    list.insert(0, saved);
    return saved;
  }

  @override
  Future<List<Review>> listForStudent(String studentId, {int limit = 50}) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return List<Review>.from(_byStudent[studentId] ?? const []).take(limit).toList();
  }

  @override
  Future<RatingSummary> summaryForStudent(String studentId) async {
    final list = _byStudent[studentId] ?? const <Review>[];
    if (list.isEmpty) return const RatingSummary(average: 0, count: 0);
    final avg = list.map((r) => r.stars).reduce((a, b) => a + b) / list.length;
    return RatingSummary(average: avg, count: list.length);
  }

  @override
  Future<Review> submitStudentReview({
    required String studentId,
    required int stars,
    String? text,
  }) async {
    if (stars < 1 || stars > 5) {
      throw ReviewsException('invalid_stars', 'Stars must be between 1 and 5.');
    }
    if (text != null && PhoneBanRegex.isViolation(text)) {
      throw ReviewsException('phone_in_review', 'Remove phone numbers or contact details.');
    }
    if (_demoSelf == studentId) {
      throw ReviewsException('cannot_review_self');
    }
    // The author is the current (tutor) user in fake mode.
    final existing = (_byStudent[studentId] ?? const <Review>[])
        .where((r) => r.tutorId == _demoSelf)
        .toList();
    final saved = Review(
      id: existing.isEmpty ? 'srev-${++_counter}' : existing.first.id,
      tutorId: _demoSelf,
      studentId: studentId,
      stars: stars,
      text: text,
      createdAt: existing.isEmpty ? DateTime.now() : existing.first.createdAt,
    );
    final list = _byStudent.putIfAbsent(studentId, () => []);
    list.removeWhere((r) => r.tutorId == _demoSelf);
    list.insert(0, saved);
    return saved;
  }

  @override
  Future<int> boostFeatured({int hours = 24}) async {
    const demoTutor = 'fake-login';
    final cost = _settings.getInt('featured_listing_cost', 50);
    // Reuse the wallet's apply path to debit (any non-zero debit). We don't
    // have a dedicated 'boost' route on FakeWalletRepository; piggyback on
    // applyToVacancy so the cost reflects in the ledger UI.
    if (cost <= _settings.applyCoinCost) {
      // Same path; small simplification for the demo.
    }
    // For correctness, perform N tiny debits to reach `cost`. The Fake wallet
    // throws insufficient_coins if balance < cost.
    for (int i = 0; i < cost; i++) {
      await _wallet.applyToVacancy(tutorId: demoTutor, vacancyId: 'boost-featured');
    }
    return await _wallet.loadBalance(demoTutor);
  }

  @override
  Future<int> promoteJob({required String jobId, int hours = 24}) async {
    const demoStudent = 'fake-login';
    final cost = _settings.getInt('promoted_job_cost', 20);
    for (int i = 0; i < cost; i++) {
      await _wallet.applyToVacancy(tutorId: demoStudent, vacancyId: 'promote-$jobId');
    }
    return await _wallet.loadBalance(demoStudent);
  }
}
