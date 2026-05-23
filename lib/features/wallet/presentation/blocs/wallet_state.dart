part of 'wallet_bloc.dart';

enum WalletStatus { initial, loading, ready, error }

class WalletState extends Equatable {
  const WalletState({
    this.status = WalletStatus.initial,
    this.balance = 0,
    this.entries = const [],
    this.errorMessage,
  });

  final WalletStatus status;
  final int balance;
  final List<LedgerEntry> entries;
  final String? errorMessage;

  WalletState copyWith({
    WalletStatus? status,
    int? balance,
    List<LedgerEntry>? entries,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WalletState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      entries: entries ?? this.entries,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, balance, entries, errorMessage];
}
