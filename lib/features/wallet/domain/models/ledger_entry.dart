import 'package:equatable/equatable.dart';

/// Closed set of reasons mirrored in supabase/migrations/0004_phase5_wallet.sql.
enum LedgerReason {
  signup('signup', 'Welcome bonus'),
  apply('apply', 'Application / bid'),
  unlock('unlock', 'Contact unlock'),
  boost('boost', 'Boost / featured listing'),
  topup('topup', 'Coin top-up'),
  reward('reward', 'Reward'),
  refund('refund', 'Refund'),
  admin('admin', 'Admin adjustment');

  const LedgerReason(this.value, this.label);

  final String value;
  final String label;

  static LedgerReason fromString(String raw) => LedgerReason.values.firstWhere(
        (r) => r.value == raw,
        orElse: () => LedgerReason.admin,
      );
}

/// Single immutable row from `wallet_ledger`.
class LedgerEntry extends Equatable {
  const LedgerEntry({
    required this.id,
    required this.delta,
    required this.reason,
    required this.balanceAfter,
    required this.createdAt,
    this.description,
    this.refType,
    this.refId,
  });

  final String id;
  final int delta;
  final LedgerReason reason;
  final int balanceAfter;
  final DateTime createdAt;
  final String? description;
  final String? refType;
  final String? refId;

  bool get isCredit => delta > 0;
  bool get isDebit => delta < 0;

  static LedgerEntry fromRow(Map<String, dynamic> row) => LedgerEntry(
        id: row['id'] as String,
        delta: row['delta'] as int,
        reason: LedgerReason.fromString(row['reason'] as String),
        balanceAfter: row['balance_after'] as int,
        createdAt: DateTime.parse(row['created_at'] as String),
        description: row['description'] as String?,
        refType: row['ref_type'] as String?,
        refId: row['ref_id'] as String?,
      );

  @override
  List<Object?> get props => [id, delta, reason, balanceAfter, createdAt];
}
