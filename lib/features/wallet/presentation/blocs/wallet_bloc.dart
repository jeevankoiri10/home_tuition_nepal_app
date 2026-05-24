import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/ledger_entry.dart';
import '../../domain/wallet_repository.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc(this._repo) : super(const WalletState()) {
    on<WalletLoaded>(_onLoad);
    on<WalletRefreshRequested>(_onRefresh);
    on<WalletBalanceChanged>(_onBalanceChanged);
  }

  final WalletRepository _repo;
  String? _userId;
  StreamSubscription<void>? _watcher;

  Future<void> _onLoad(WalletLoaded event, Emitter<WalletState> emit) async {
    _userId = event.userId;
    await _watcher?.cancel();
    // Re-fetch whenever the server reports a wallet change so the UI stays
    // in sync without explicit refresh calls (referrals credited by a webhook,
    // top-ups confirmed server-side, etc.).
    _watcher = _repo
        .watchLedger(event.userId)
        .listen((_) => add(const WalletBalanceChanged()));
    await _reload(emit);
  }

  Future<void> _onRefresh(WalletRefreshRequested event, Emitter<WalletState> emit) =>
      _reload(emit);

  Future<void> _onBalanceChanged(WalletBalanceChanged event, Emitter<WalletState> emit) =>
      _reload(emit);

  Future<void> _reload(Emitter<WalletState> emit) async {
    final id = _userId;
    if (id == null) return;
    emit(state.copyWith(status: WalletStatus.loading, clearError: true));
    try {
      final balance = await _repo.loadBalance(id);
      final entries = await _repo.loadHistory(id);
      emit(state.copyWith(status: WalletStatus.ready, balance: balance, entries: entries));
    } on WalletException catch (e) {
      emit(state.copyWith(status: WalletStatus.error, errorMessage: e.message ?? e.code));
    }
  }

  @override
  Future<void> close() async {
    await _watcher?.cancel();
    return super.close();
  }
}
