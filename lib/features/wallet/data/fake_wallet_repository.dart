import 'dart:async';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/platform_settings_service.dart';
import '../domain/models/ledger_entry.dart';
import '../domain/wallet_repository.dart';

/// In-memory wallet for local dev. Mirrors the SQL RPC semantics:
///   - `unlock_contact` is idempotent per (student, tutor)
///   - debits throw `WalletException('insufficient_coins')` when balance < cost
class FakeWalletRepository implements WalletRepository {
  FakeWalletRepository(this._settings);

  final PlatformSettingsService _settings;
  final Map<String, _UserWallet> _wallets = {};
  final Map<String, StreamController<void>> _watchers = {};

  StreamController<void> _watcher(String userId) {
    return _watchers.putIfAbsent(
      userId,
      () => StreamController<void>.broadcast(),
    );
  }

  void _notifyChange(String userId) {
    _watchers[userId]?.add(null);
  }

  _UserWallet _ensure(String userId) {
    return _wallets.putIfAbsent(
      userId,
      () => _UserWallet(balance: 0)
        ..addCredit(
          AppConstants.defaultSignupCoinGrant,
          LedgerReason.signup,
          description: 'Welcome bonus on signup',
        ),
    );
  }

  @override
  Stream<void> watchLedger(String userId) => _watcher(userId).stream;

  @override
  Future<int> loadBalance(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _ensure(userId).balance;
  }

  @override
  Future<List<LedgerEntry>> loadHistory(String userId, {int limit = 50}) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _ensure(userId).entries.reversed.take(limit).toList();
  }

  @override
  Future<bool> hasUnlocked({required String studentId, required String tutorId}) async {
    final w = _wallets[studentId];
    if (w == null) return false;
    return w.entries.any(
      (e) => e.reason == LedgerReason.unlock && e.refId == tutorId,
    );
  }

  @override
  Future<String?> revealContact(
      {required String studentId, required String tutorId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!await hasUnlocked(studentId: studentId, tutorId: tutorId)) {
      throw WalletException('gate_not_met', 'Unlock the contact first.');
    }
    // Dev seam: return a deterministic demo number so the Call/WhatsApp links
    // are exercisable without a backend.
    return '+9779800000000';
  }

  @override
  Future<int> unlockContact({required String studentId, required String tutorId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final w = _ensure(studentId);

    // Idempotent — one unlock per (student, tutor).
    final already = w.entries.any(
      (e) => e.reason == LedgerReason.unlock && e.refId == tutorId,
    );
    if (already) return w.balance;

    final cost = _settings.unlockCoinCost;
    if (w.balance < cost) {
      throw WalletException('insufficient_coins',
          'Need $cost coins, you have ${w.balance}.');
    }
    w.addDebit(cost, LedgerReason.unlock,
        refType: 'tutor', refId: tutorId, description: 'Unlocked contact for tutor');
    _notifyChange(studentId);
    return w.balance;
  }

  @override
  Future<int> applyToVacancy({
    required String tutorId,
    required String vacancyId,
    int? cost,
  }) async {
    return _spendApplyCost(tutorId, refType: 'vacancy', refId: vacancyId, cost: cost);
  }

  @override
  Future<int> bidOnJob({required String tutorId, required String jobId, int? cost}) async {
    return _spendApplyCost(tutorId, refType: 'job', refId: jobId, cost: cost);
  }

  Future<int> _spendApplyCost(
    String userId, {
    required String refType,
    required String refId,
    int? cost,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final w = _ensure(userId);
    // Use the caller-computed percentage cost; fall back to the flat setting
    // when none was supplied (e.g. the dormant job-bid path).
    final resolvedCost = cost ?? _settings.applyCoinCost;
    if (w.balance < resolvedCost) {
      throw WalletException('insufficient_coins',
          'Need $resolvedCost coins, you have ${w.balance}.');
    }
    w.addDebit(resolvedCost, LedgerReason.apply,
        refType: refType, refId: refId, description: 'Applied to $refType');
    _notifyChange(userId);
    return w.balance;
  }

  /// Dev seam — used by FakeTopUpsRepository to simulate a verified payment
  /// crediting the wallet. Production credits go through the SQL
  /// `finalize_top_up` RPC.
  void injectCredit({
    required String userId,
    required int amount,
    String? description,
  }) {
    _ensure(userId).addCredit(amount, LedgerReason.topup, description: description);
    _notifyChange(userId);
  }
}

class _UserWallet {
  _UserWallet({required this.balance});
  int balance;
  final List<LedgerEntry> entries = [];

  void addCredit(int amount, LedgerReason reason, {String? description}) {
    balance += amount;
    entries.add(LedgerEntry(
      id: 'entry-${entries.length}',
      delta: amount,
      reason: reason,
      balanceAfter: balance,
      createdAt: DateTime.now(),
      description: description,
    ));
  }

  void addDebit(int amount, LedgerReason reason,
      {String? refType, String? refId, String? description}) {
    balance -= amount;
    entries.add(LedgerEntry(
      id: 'entry-${entries.length}',
      delta: -amount,
      reason: reason,
      balanceAfter: balance,
      createdAt: DateTime.now(),
      description: description,
      refType: refType,
      refId: refId,
    ));
  }
}
