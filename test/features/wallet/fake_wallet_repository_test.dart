import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/services/platform_settings_service.dart';
import 'package:home_tuition_nepal_app/features/wallet/data/fake_wallet_repository.dart';
import 'package:home_tuition_nepal_app/features/wallet/domain/models/ledger_entry.dart';
import 'package:home_tuition_nepal_app/features/wallet/domain/wallet_repository.dart';

void main() {
  late FakeWalletRepository repo;

  setUp(() {
    repo = FakeWalletRepository(PlatformSettingsService());
  });

  group('FakeWalletRepository', () {
    test('first balance read for a new user is the signup grant', () async {
      expect(await repo.loadBalance('u1'), 1000);
    });

    test('signup entry is the first ledger row', () async {
      await repo.loadBalance('u1');
      final history = await repo.loadHistory('u1');
      expect(history, isNotEmpty);
      expect(history.first.reason, LedgerReason.signup);
      expect(history.first.delta, 1000);
    });

    test('unlock debits the unlock cost and records ledger row', () async {
      await repo.loadBalance('u1');
      final balance = await repo.unlockContact(studentId: 'u1', tutorId: 't1');
      expect(balance, 995);
      final history = await repo.loadHistory('u1');
      final unlock = history.firstWhere((e) => e.reason == LedgerReason.unlock);
      expect(unlock.delta, -5);
      expect(unlock.refId, 't1');
    });

    test('second unlock for the same tutor is idempotent (no second debit)', () async {
      await repo.unlockContact(studentId: 'u1', tutorId: 't1');
      final balance = await repo.unlockContact(studentId: 'u1', tutorId: 't1');
      expect(balance, 995);
    });

    test('apply_to_vacancy debits the apply cost (default 1)', () async {
      await repo.loadBalance('u2');
      final balance = await repo.applyToVacancy(tutorId: 'u2', vacancyId: 'v1');
      expect(balance, 999);
    });

    test('watchLedger emits when the balance changes', () async {
      await repo.loadBalance('w1');
      final events = <void>[];
      final sub = repo.watchLedger('w1').listen(events.add);
      await repo.unlockContact(studentId: 'w1', tutorId: 't1');
      await repo.applyToVacancy(tutorId: 'w1', vacancyId: 'v1');
      // Let the broadcast stream flush.
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await sub.cancel();
      expect(events.length, greaterThanOrEqualTo(2));
    });

    test('insufficient funds throw WalletException', () async {
      await repo.loadBalance('poor');
      // Drain the wallet by repeatedly unlocking different tutors.
      for (int i = 0; i < 199; i++) {
        await repo.unlockContact(studentId: 'poor', tutorId: 't$i');
      }
      // Balance is now 5; next unlock should succeed, then drain again.
      await repo.unlockContact(studentId: 'poor', tutorId: 't199');
      expect(await repo.loadBalance('poor'), 0);
      expect(
        () => repo.unlockContact(studentId: 'poor', tutorId: 't_new'),
        throwsA(isA<WalletException>().having((e) => e.isInsufficient, 'isInsufficient', true)),
      );
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('revealContact throws gate_not_met before any unlock', () async {
      await repo.loadBalance('u1');
      expect(
        () => repo.revealContact(studentId: 'u1', tutorId: 't1'),
        throwsA(isA<WalletException>().having((e) => e.code, 'code', 'gate_not_met')),
      );
    });

    test('revealContact returns a number once the contact is unlocked', () async {
      await repo.loadBalance('u1');
      await repo.unlockContact(studentId: 'u1', tutorId: 't1');
      final phone = await repo.revealContact(studentId: 'u1', tutorId: 't1');
      expect(phone, isNotNull);
      expect(phone, isNotEmpty);
    });
  });
}
