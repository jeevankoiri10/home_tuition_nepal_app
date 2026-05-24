part of 'contract_bloc.dart';

enum ContractLoad { initial, loading, ready, error }

class ContractState extends Equatable {
  const ContractState({
    this.status = ContractLoad.initial,
    this.contract,
    this.errorMessage,
  });

  final ContractLoad status;
  final Contract? contract;
  final String? errorMessage;

  ContractState copyWith({
    ContractLoad? status,
    Contract? contract,
    String? errorMessage,
    bool clearError = false,
    bool clearContractIfNull = false,
  }) {
    return ContractState(
      status: status ?? this.status,
      contract: clearContractIfNull ? contract : (contract ?? this.contract),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, contract, errorMessage];
}
