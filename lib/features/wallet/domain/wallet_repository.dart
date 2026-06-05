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

  /// Emits each time the server reports a wallet change for [userId] (insert
  /// into `wallet_ledger`). The bloc uses this to keep balance & history in
  /// sync without polling. Implementations may emit `void` ticks; the bloc
  /// reacts by re-fetching, so the payload type carries no information.
  Stream<void> watchLedger(String userId);

  /// Atomically debits `unlock_coin_cost` and records a `wallet_ledger` row.
  /// Returns the new balance. Idempotent per (student, tutor) — calling twice
  /// for the same tutor returns the current balance without a second debit.
  Future<int> unlockContact({required String studentId, required String tutorId});

  /// Non-mutating gate check used by chat / reviews to confirm the caller
  /// has previously unlocked the tutor. Server-side this is a row probe; the
  /// fake reads the ledger.
  Future<bool> hasUnlocked({required String studentId, required String tutorId});

  /// Returns the tutor's phone number — but only if [studentId] has previously
  /// unlocked [tutorId]. The gate is enforced server-side (SECURITY DEFINER
  /// RPC), so the private phone never leaves the database without an unlock.
  /// Returns `null` when the tutor has no phone on file. Throws
  /// [WalletException] (`gate_not_met`) if the contact was never unlocked.
  Future<String?> revealContact({required String studentId, required String tutorId});

  /// Debits the connect cost for applying to a vacancy and returns the new
  /// balance. [cost] is the percentage-based price computed from the vacancy's
  /// salary (see `ConnectCost`). The Supabase implementation ignores it — the
  /// server recomputes authoritatively — but the in-memory fake honors it so
  /// the demo charges the same amount the UI shows.
  Future<int> applyToVacancy({
    required String tutorId,
    required String vacancyId,
    int? cost,
  });

  Future<int> bidOnJob({required String tutorId, required String jobId, int? cost});
}
