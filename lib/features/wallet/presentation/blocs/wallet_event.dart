part of 'wallet_bloc.dart';

sealed class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object?> get props => const [];
}

class WalletLoaded extends WalletEvent {
  const WalletLoaded(this.userId);
  final String userId;
  @override
  List<Object?> get props => [userId];
}

class WalletRefreshRequested extends WalletEvent {
  const WalletRefreshRequested();
}

/// Notifies the bloc that a debit / credit happened outside its scope (e.g.,
/// the unlock sheet called `WalletRepository.unlockContact` directly). The
/// bloc reloads so the wallet UI stays accurate.
class WalletBalanceChanged extends WalletEvent {
  const WalletBalanceChanged();
}
