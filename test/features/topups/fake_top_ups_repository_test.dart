import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/services/platform_settings_service.dart';
import 'package:home_tuition_nepal_app/features/topups/data/fake_top_ups_repository.dart';
import 'package:home_tuition_nepal_app/features/topups/domain/models/top_up.dart';
import 'package:home_tuition_nepal_app/features/topups/domain/top_ups_repository.dart';
import 'package:home_tuition_nepal_app/features/wallet/data/fake_wallet_repository.dart';

void main() {
  late FakeWalletRepository wallet;
  late FakeTopUpsRepository topups;

  setUp(() {
    final settings = PlatformSettingsService();
    wallet = FakeWalletRepository(settings);
    topups = FakeTopUpsRepository(wallet, settings);
  });

  group('FakeTopUpsRepository', () {
    test('listPacks returns the four seeded packs sorted', () async {
      final packs = await topups.listPacks();
      expect(packs.length, 4);
      expect(packs.first.code, 'PACK-100');
      expect(packs.last.code, 'PACK-5000');
    });

    test('startTopUp creates a pending row', () async {
      final packs = await topups.listPacks();
      final pending = await topups.startTopUp(pack: packs[1], provider: PaymentProvider.khalti);
      expect(pending.status, TopUpStatus.pending);
      expect(pending.coinAmount, packs[1].totalCoins);
      expect(pending.provider, PaymentProvider.khalti);
    });

    test('debugSimulateSuccess credits the wallet with totalCoins', () async {
      final packs = await topups.listPacks();
      final start = await wallet.loadBalance('fake-login');
      final pending = await topups.startTopUp(pack: packs[2], provider: PaymentProvider.esewa);
      await topups.debugSimulateSuccess(pending.id);
      final end = await wallet.loadBalance('fake-login');
      expect(end - start, packs[2].totalCoins);
      final after = await topups.getTopUp(pending.id);
      expect(after.status, TopUpStatus.succeeded);
    });

    test('cancelTopUp marks pending row cancelled', () async {
      final packs = await topups.listPacks();
      final pending = await topups.startTopUp(pack: packs.first, provider: PaymentProvider.imePay);
      await topups.cancelTopUp(pending.id);
      final after = await topups.getTopUp(pending.id);
      expect(after.status, TopUpStatus.cancelled);
    });

    test('attachReceipt stamps receiptUrl on the top-up', () async {
      final packs = await topups.listPacks();
      final pending = await topups.startTopUp(pack: packs.first, provider: PaymentProvider.esewa);
      final updated = await topups.attachReceipt(
        topUpId: pending.id,
        bytes: Uint8List.fromList(List<int>.filled(1024, 0)),
        fileName: 'receipt.jpg',
      );
      expect(updated.receiptUrl, isNotNull);
      final fetched = await topups.getTopUp(pending.id);
      expect(fetched.receiptUrl, isNotNull);
    });

    test('attachReceipt rejects an oversized file', () async {
      final packs = await topups.listPacks();
      final pending = await topups.startTopUp(pack: packs.first, provider: PaymentProvider.esewa);
      expect(
        () => topups.attachReceipt(
          topUpId: pending.id,
          bytes: Uint8List(6 * 1024 * 1024),
          fileName: 'big.pdf',
        ),
        throwsA(isA<TopUpsException>()),
      );
    });
  });
}
