import 'package:equatable/equatable.dart';

enum PaymentProvider {
  esewa('esewa', 'eSewa'),
  khalti('khalti', 'Khalti'),
  imePay('ime_pay', 'IME Pay');

  const PaymentProvider(this.value, this.label);
  final String value;
  final String label;

  static PaymentProvider fromString(String raw) => PaymentProvider.values
      .firstWhere((p) => p.value == raw, orElse: () => PaymentProvider.esewa);
}

enum TopUpStatus {
  pending,
  succeeded,
  failed,
  cancelled;

  String get value => name;

  static TopUpStatus fromString(String? raw) =>
      TopUpStatus.values.firstWhere((s) => s.name == raw, orElse: () => TopUpStatus.pending);
}

class TopUp extends Equatable {
  const TopUp({
    required this.id,
    required this.userId,
    required this.packId,
    required this.provider,
    required this.coinAmount,
    required this.priceNpr,
    required this.status,
    this.providerRef,
    this.ledgerEntryId,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String? packId;
  final PaymentProvider provider;
  final int coinAmount;
  final num priceNpr;
  final TopUpStatus status;
  final String? providerRef;
  final String? ledgerEntryId;
  final DateTime createdAt;

  static TopUp fromRow(Map<String, dynamic> row) => TopUp(
        id: row['id'] as String,
        userId: row['user_id'] as String,
        packId: row['pack_id'] as String?,
        provider: PaymentProvider.fromString(row['provider'] as String),
        coinAmount: (row['coin_amount'] as num).toInt(),
        priceNpr: row['price_npr'] as num,
        status: TopUpStatus.fromString(row['status'] as String?),
        providerRef: row['provider_ref'] as String?,
        ledgerEntryId: row['ledger_entry_id'] as String?,
        createdAt: row['created_at'] == null
            ? DateTime.now()
            : DateTime.parse(row['created_at'] as String),
      );

  @override
  List<Object?> get props => [id, userId, provider, coinAmount, priceNpr, status];
}
