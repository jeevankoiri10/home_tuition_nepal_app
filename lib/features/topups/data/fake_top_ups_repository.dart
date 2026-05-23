import '../../../core/services/platform_settings_service.dart';
import '../../wallet/data/fake_wallet_repository.dart';
import '../../wallet/domain/wallet_repository.dart';
import '../domain/models/coin_pack.dart';
import '../domain/models/top_up.dart';
import '../domain/top_ups_repository.dart';

/// In-memory top-ups for local dev. Mirrors the SQL lifecycle:
///   start_top_up → (provider webhook) → finalize_top_up
/// For Flutter dev without a real merchant account, `debugSimulateSuccess`
/// stands in for the webhook and credits the wallet via the underlying repo.
class FakeTopUpsRepository implements TopUpsRepository {
  FakeTopUpsRepository(this._wallet, this._settings);

  final WalletRepository _wallet;
  // ignore: unused_field — settings reserved for future pack pricing overrides
  final PlatformSettingsService _settings;
  final Map<String, TopUp> _byId = {};
  int _counter = 0;

  static final _packs = <CoinPack>[
    const CoinPack(id: 'pack-100',  code: 'PACK-100',  label: 'Starter',
        coinAmount: 100,  bonusCoins: 0,   priceNpr: 99,   sortOrder: 1),
    const CoinPack(id: 'pack-500',  code: 'PACK-500',  label: 'Popular',
        coinAmount: 500,  bonusCoins: 50,  priceNpr: 449,  sortOrder: 2),
    const CoinPack(id: 'pack-2000', code: 'PACK-2000', label: 'Pro',
        coinAmount: 2000, bonusCoins: 300, priceNpr: 1699, sortOrder: 3),
    const CoinPack(id: 'pack-5000', code: 'PACK-5000', label: 'Power user',
        coinAmount: 5000, bonusCoins: 900, priceNpr: 3999, sortOrder: 4),
  ];

  @override
  Future<List<CoinPack>> listPacks() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return List<CoinPack>.from(_packs);
  }

  @override
  Future<TopUp> startTopUp({required CoinPack pack, required PaymentProvider provider}) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final id = 'topup-${++_counter}';
    final t = TopUp(
      id: id,
      userId: 'fake-login',
      packId: pack.id,
      provider: provider,
      coinAmount: pack.totalCoins,
      priceNpr: pack.priceNpr,
      status: TopUpStatus.pending,
      createdAt: DateTime.now(),
    );
    _byId[id] = t;
    return t;
  }

  @override
  Future<void> cancelTopUp(String topUpId) async {
    final t = _byId[topUpId];
    if (t == null || t.status != TopUpStatus.pending) return;
    _byId[topUpId] = TopUp(
      id: t.id,
      userId: t.userId,
      packId: t.packId,
      provider: t.provider,
      coinAmount: t.coinAmount,
      priceNpr: t.priceNpr,
      status: TopUpStatus.cancelled,
      providerRef: t.providerRef,
      createdAt: t.createdAt,
    );
  }

  @override
  Future<TopUp> getTopUp(String topUpId) async {
    final t = _byId[topUpId];
    if (t == null) throw TopUpsException('not_found');
    return t;
  }

  @override
  Future<List<TopUp>> listMine(String userId, {int limit = 25}) async {
    return _byId.values
        .where((t) => t.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<TopUp> debugSimulateSuccess(String topUpId) async {
    final t = _byId[topUpId];
    if (t == null) throw TopUpsException('not_found');
    if (t.status == TopUpStatus.succeeded) return t;

    // Credit through the wallet. FakeWalletRepository ledgers a credit by
    // calling a helper we don't expose — for the demo we simulate by calling
    // applyToVacancy in reverse (not ideal). Cleanest path: bypass the repo
    // and add a debug entry directly. We'll cast and use a dev hook.
    if (_wallet is FakeWalletRepository) {
      (_wallet as dynamic).injectCredit(
        userId: t.userId,
        amount: t.coinAmount,
        description: 'Coin pack via ${t.provider.label}',
      );
    }

    final updated = TopUp(
      id: t.id,
      userId: t.userId,
      packId: t.packId,
      provider: t.provider,
      coinAmount: t.coinAmount,
      priceNpr: t.priceNpr,
      status: TopUpStatus.succeeded,
      providerRef: 'demo-${DateTime.now().millisecondsSinceEpoch}',
      ledgerEntryId: 'demo-ledger',
      createdAt: t.createdAt,
    );
    _byId[topUpId] = updated;
    return updated;
  }
}
