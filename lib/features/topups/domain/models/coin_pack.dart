import 'package:equatable/equatable.dart';

class CoinPack extends Equatable {
  const CoinPack({
    required this.id,
    required this.code,
    required this.label,
    required this.coinAmount,
    required this.bonusCoins,
    required this.priceNpr,
    required this.sortOrder,
  });

  final String id;
  final String code;
  final String label;
  final int coinAmount;
  final int bonusCoins;
  final num priceNpr;
  final int sortOrder;

  int get totalCoins => coinAmount + bonusCoins;

  String formatPrice() {
    final s = priceNpr.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return 'Rs. $buf';
  }

  String? bonusLabel() {
    if (bonusCoins <= 0) return null;
    return '+$bonusCoins bonus';
  }

  static CoinPack fromRow(Map<String, dynamic> row) => CoinPack(
        id: row['id'] as String,
        code: row['code'] as String,
        label: row['label'] as String,
        coinAmount: (row['coin_amount'] as num).toInt(),
        bonusCoins: ((row['bonus_coins'] as num?) ?? 0).toInt(),
        priceNpr: row['price_npr'] as num,
        sortOrder: ((row['sort_order'] as num?) ?? 0).toInt(),
      );

  @override
  List<Object?> get props => [id, code, coinAmount, bonusCoins, priceNpr];
}
