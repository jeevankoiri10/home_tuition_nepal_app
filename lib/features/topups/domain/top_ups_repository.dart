import 'models/coin_pack.dart';
import 'models/top_up.dart';

class TopUpsException implements Exception {
  TopUpsException(this.code, [this.message]);
  final String code;
  final String? message;

  @override
  String toString() => 'TopUpsException($code, $message)';
}

abstract class TopUpsRepository {
  Future<List<CoinPack>> listPacks();

  /// Creates a pending top-up row and returns the local id the client passes
  /// to the provider SDK as `merchantTransactionId`. Production then defers
  /// to the provider; on webhook callback the server flips status via
  /// `finalize_top_up`.
  Future<TopUp> startTopUp({required CoinPack pack, required PaymentProvider provider});

  /// User backed out of the provider's flow.
  Future<void> cancelTopUp(String topUpId);

  Future<TopUp> getTopUp(String topUpId);

  Future<List<TopUp>> listMine(String userId, {int limit = 25});

  /// Dev-only helper used by the FakeTopUpsRepository to simulate the
  /// provider's webhook arriving with `ok=true`. The SupabaseTopUpsRepository
  /// throws — production must go through the real webhook.
  Future<TopUp> debugSimulateSuccess(String topUpId);
}
