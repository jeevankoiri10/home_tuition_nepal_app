import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/topups/domain/models/coin_pack.dart';

CoinPack _pack({int coins = 100, int bonus = 0, num price = 1000}) => CoinPack(
      id: 'p1',
      code: 'PACK',
      label: 'Starter',
      coinAmount: coins,
      bonusCoins: bonus,
      priceNpr: price,
      sortOrder: 0,
    );

void main() {
  group('CoinPack', () {
    test('totalCoins is base plus bonus', () {
      expect(_pack(coins: 100, bonus: 20).totalCoins, 120);
      expect(_pack(coins: 100, bonus: 0).totalCoins, 100);
    });

    test('formatPrice groups thousands with an Rs. prefix', () {
      expect(_pack(price: 1000).formatPrice(), 'Rs. 1,000');
      expect(_pack(price: 500).formatPrice(), 'Rs. 500');
      expect(_pack(price: 1500000).formatPrice(), 'Rs. 1,500,000');
    });

    test('bonusLabel is null without a bonus and "+N bonus" with one', () {
      expect(_pack(bonus: 0).bonusLabel(), isNull);
      expect(_pack(bonus: -5).bonusLabel(), isNull);
      expect(_pack(bonus: 25).bonusLabel(), '+25 bonus');
    });

    test('fromRow parses a full row', () {
      final pack = CoinPack.fromRow({
        'id': 'x',
        'code': 'BIG',
        'label': 'Big pack',
        'coin_amount': 500,
        'bonus_coins': 100,
        'price_npr': 4500,
        'sort_order': 3,
      });
      expect(pack.totalCoins, 600);
      expect(pack.sortOrder, 3);
    });

    test('fromRow defaults missing bonus_coins and sort_order to zero', () {
      final pack = CoinPack.fromRow({
        'id': 'x',
        'code': 'MIN',
        'label': 'Minimal',
        'coin_amount': 50,
        'price_npr': 600,
      });
      expect(pack.bonusCoins, 0);
      expect(pack.sortOrder, 0);
      expect(pack.bonusLabel(), isNull);
    });
  });
}
