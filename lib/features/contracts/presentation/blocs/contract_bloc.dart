import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/contracts_repository.dart';
import '../../domain/models/contract.dart';

part 'contract_event.dart';
part 'contract_state.dart';

/// Drives the contract banner inside a single chat thread.
class ContractBloc extends Bloc<ContractEvent, ContractState> {
  ContractBloc(this._repo) : super(const ContractState()) {
    on<ContractThreadOpened>(_onOpen);
    on<ContractProposed>(_onPropose);
    on<ContractAccepted>(_onAccept);
    on<ContractDeclined>(_onDecline);
    on<ContractEnded>(_onEnd);
    on<ContractCancelled>(_onCancel);
  }

  final ContractsRepository _repo;
  String? _threadId;

  Future<void> _onOpen(ContractThreadOpened e, Emitter<ContractState> emit) async {
    _threadId = e.threadId;
    await _reload(emit);
  }

  Future<void> _reload(Emitter<ContractState> emit) async {
    final id = _threadId;
    if (id == null) return;
    emit(state.copyWith(status: ContractLoad.loading, clearError: true));
    try {
      final c = await _repo.latestForThread(id);
      emit(state.copyWith(status: ContractLoad.ready, contract: c, clearContractIfNull: c == null));
    } on ContractsException catch (err) {
      emit(state.copyWith(status: ContractLoad.error, errorMessage: err.message ?? err.code));
    }
  }

  Future<void> _onPropose(ContractProposed e, Emitter<ContractState> emit) async {
    final id = _threadId;
    if (id == null) return;
    try {
      await _repo.propose(
        threadId: id,
        studentId: e.studentId,
        tutorId: e.tutorId,
        proposedBy: e.proposedBy,
        subject: e.subject,
        rateNpr: e.rateNpr,
        ratePeriod: e.ratePeriod,
        scheduleText: e.scheduleText,
      );
      await _reload(emit);
    } on ContractsException catch (err) {
      emit(state.copyWith(errorMessage: err.message ?? err.code));
    }
  }

  Future<void> _act(
    Future<void> Function(String id) action,
    String contractId,
    Emitter<ContractState> emit,
  ) async {
    try {
      await action(contractId);
      await _reload(emit);
    } on ContractsException catch (err) {
      emit(state.copyWith(errorMessage: err.message ?? err.code));
    }
  }

  Future<void> _onAccept(ContractAccepted e, Emitter<ContractState> emit) =>
      _act(_repo.accept, e.contractId, emit);
  Future<void> _onDecline(ContractDeclined e, Emitter<ContractState> emit) =>
      _act(_repo.decline, e.contractId, emit);
  Future<void> _onEnd(ContractEnded e, Emitter<ContractState> emit) =>
      _act(_repo.end, e.contractId, emit);
  Future<void> _onCancel(ContractCancelled e, Emitter<ContractState> emit) =>
      _act(_repo.cancel, e.contractId, emit);
}
