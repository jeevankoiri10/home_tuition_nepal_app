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
}
