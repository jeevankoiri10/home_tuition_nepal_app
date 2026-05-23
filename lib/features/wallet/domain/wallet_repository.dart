import 'models/ledger_entry.dart';

class WalletException implements Exception {
  WalletException(this.code, [this.message]);
  final String code;
  final String? message;

  bool get isInsufficient => code == 'insufficient_coins';

  @override
  String toString() => 'WalletException($code, $message)';
}

abstract class WalletRepository {
  Future<int> loadBalance(String userId);

  Future<List<LedgerEntry>> loadHistory(String userId, {int limit = 50});

  /// Atomically debits `unlock_coin_cost` and records a `wallet_ledger` row.
  /// Returns the new balance. Idempotent per (student, tutor) — calling twice
  /// for the same tutor returns the current balance without a second debit.
  Future<int> unlockContact({required String studentId, required String tutorId});

  Future<int> applyToVacancy({required String tutorId, required String vacancyId});

  Future<int> bidOnJob({required String tutorId, required String jobId});
}
