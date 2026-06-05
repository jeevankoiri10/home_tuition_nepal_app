import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/services/platform_settings_service.dart';
import 'package:home_tuition_nepal_app/features/reviews/data/fake_reviews_repository.dart';
import 'package:home_tuition_nepal_app/features/reviews/domain/reviews_repository.dart';
import 'package:home_tuition_nepal_app/features/wallet/data/fake_wallet_repository.dart';

void main() {
  late FakeWalletRepository wallet;
  late FakeReviewsRepository reviews;

  setUp(() {
    final settings = PlatformSettingsService();
    wallet = FakeWalletRepository(settings);
    reviews = FakeReviewsRepository(wallet, settings);
  });

  group('FakeReviewsRepository', () {
    test('submit without prior unlock throws gate_not_met', () async {
      expect(
        () => reviews.submit(tutorId: 'tutor-9', stars: 5, text: 'Great tutor.'),
        throwsA(isA<ReviewsException>().having((e) => e.isGateNotMet, 'isGateNotMet', true)),
      );
    });

    test('submit after unlock persists and surfaces in listForTutor', () async {
      await wallet.loadBalance('fake-login');
      await wallet.unlockContact(studentId: 'fake-login', tutorId: 'tutor-1');
      final saved = await reviews.submit(tutorId: 'tutor-1', stars: 5, text: 'Clear teacher.');
      expect(saved.stars, 5);

      final list = await reviews.listForTutor('tutor-1');
      expect(list.length, 1);

      final summary = await reviews.summaryForTutor('tutor-1');
      expect(summary.count, 1);
      expect(summary.average, 5.0);
    });

    test('submit rejects phone numbers in text', () async {
      await wallet.unlockContact(studentId: 'fake-login', tutorId: 'tutor-2');
      expect(
        () => reviews.submit(
            tutorId: 'tutor-2', stars: 4, text: 'Call me at 9812345678'),
        throwsA(isA<ReviewsException>().having((e) => e.isPhoneInReview, 'isPhoneInReview', true)),
      );
    });

    test('replacing your own review keeps the count at 1', () async {
      await wallet.unlockContact(studentId: 'fake-login', tutorId: 'tutor-3');
      await reviews.submit(tutorId: 'tutor-3', stars: 3, text: 'OK.');
      await reviews.submit(tutorId: 'tutor-3', stars: 5, text: 'Actually great!');
      final summary = await reviews.summaryForTutor('tutor-3');
      expect(summary.count, 1);
      expect(summary.average, 5.0);
    });
  });

  group('FakeReviewsRepository — student reviews (tutor→student)', () {
    test('submitStudentReview persists and surfaces in listForStudent', () async {
      final saved =
          await reviews.submitStudentReview(studentId: 'student-1', stars: 4, text: 'Punctual.');
      expect(saved.stars, 4);
      expect(saved.studentId, 'student-1');

      final list = await reviews.listForStudent('student-1');
      expect(list.length, 1);

      final summary = await reviews.summaryForStudent('student-1');
      expect(summary.count, 1);
      expect(summary.average, 4.0);
    });

    test('submitStudentReview rejects phone numbers', () async {
      expect(
        () => reviews.submitStudentReview(
            studentId: 'student-2', stars: 5, text: 'reach me 9800000000'),
        throwsA(isA<ReviewsException>().having((e) => e.isPhoneInReview, 'isPhoneInReview', true)),
      );
    });

    test('replacing your own student review keeps the count at 1', () async {
      await reviews.submitStudentReview(studentId: 'student-3', stars: 2, text: 'Late.');
      await reviews.submitStudentReview(studentId: 'student-3', stars: 5, text: 'Improved!');
      final summary = await reviews.summaryForStudent('student-3');
      expect(summary.count, 1);
      expect(summary.average, 5.0);
    });
  });

  group('FakeReviewsRepository — promotions & boosts', () {
    // Default platform settings: promoted_job_cost=20, featured_listing_cost=50,
    // signup grant=1000.
    test('promoteJob debits the promoted-job cost and returns the new balance',
        () async {
      final before = await wallet.loadBalance('fake-login');
      final balance = await reviews.promoteJob(jobId: 'job-1');
      expect(balance, before - 20);
    });

    test('promoteJob twice debits twice', () async {
      await reviews.promoteJob(jobId: 'job-1');
      final balance = await reviews.promoteJob(jobId: 'job-2');
      expect(balance, 1000 - 40);
    });

    test('boostFeatured debits the featured-listing cost', () async {
      final balance = await reviews.boostFeatured();
      expect(balance, 1000 - 50);
    });
  });
}
