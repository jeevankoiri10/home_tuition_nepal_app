import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/topups/domain/models/top_up.dart';

void main() {
  group('PaymentProvider.fromString', () {
    test('parses a known provider', () {
      expect(PaymentProvider.fromString('khalti'), PaymentProvider.khalti);
      expect(PaymentProvider.fromString('ime_pay'), PaymentProvider.imePay);
    });

    test('falls back to eSewa for an unknown provider', () {
      expect(PaymentProvider.fromString('paypal'), PaymentProvider.esewa);
    });
  });

  group('TopUpStatus.fromString', () {
    test('parses known statuses', () {
      expect(TopUpStatus.fromString('succeeded'), TopUpStatus.succeeded);
      expect(TopUpStatus.fromString('failed'), TopUpStatus.failed);
    });

    test('falls back to pending for null or unknown', () {
      expect(TopUpStatus.fromString(null), TopUpStatus.pending);
      expect(TopUpStatus.fromString('weird'), TopUpStatus.pending);
    });
  });

  group('TopUp', () {
    test('fromRow parses a row and defaults a missing status to pending', () {
      final t = TopUp.fromRow({
        'id': 't1',
        'user_id': 'u1',
        'provider': 'esewa',
        'coin_amount': 500,
        'price_npr': 4500,
        // no status / receipt_url
      });
      expect(t.status, TopUpStatus.pending);
      expect(t.receiptUrl, isNull);
      expect(t.coinAmount, 500);
    });

    test('copyWith stamps a receipt and status, keeping other fields', () {
      final t = TopUp.fromRow({
        'id': 't1',
        'user_id': 'u1',
        'provider': 'esewa',
        'coin_amount': 500,
        'price_npr': 4500,
        'status': 'pending',
      });
      final stamped = t.copyWith(
        receiptUrl: 'https://x/receipt.jpg',
        status: TopUpStatus.succeeded,
      );
      expect(stamped.receiptUrl, 'https://x/receipt.jpg');
      expect(stamped.status, TopUpStatus.succeeded);
      expect(stamped.id, 't1');
      expect(stamped.coinAmount, 500);
    });
  });
}
