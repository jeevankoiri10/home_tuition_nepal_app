part of 'contract_bloc.dart';

sealed class ContractEvent extends Equatable {
  const ContractEvent();
  @override
  List<Object?> get props => [];
}

class ContractThreadOpened extends ContractEvent {
  const ContractThreadOpened(this.threadId);
  final String threadId;
  @override
  List<Object?> get props => [threadId];
}

class ContractProposed extends ContractEvent {
  const ContractProposed({
    required this.studentId,
    required this.tutorId,
    required this.proposedBy,
    required this.subject,
    required this.ratePeriod,
    this.rateNpr,
    this.scheduleText,
  });

  final String studentId;
  final String tutorId;
  final String proposedBy;
  final String subject;
  final ContractRatePeriod ratePeriod;
  final num? rateNpr;
  final String? scheduleText;

  @override
  List<Object?> get props => [studentId, tutorId, proposedBy, subject, ratePeriod, rateNpr, scheduleText];
}

class ContractAccepted extends ContractEvent {
  const ContractAccepted(this.contractId);
  final String contractId;
  @override
  List<Object?> get props => [contractId];
}

class ContractDeclined extends ContractEvent {
  const ContractDeclined(this.contractId);
  final String contractId;
  @override
  List<Object?> get props => [contractId];
}

class ContractEnded extends ContractEvent {
  const ContractEnded(this.contractId);
  final String contractId;
  @override
  List<Object?> get props => [contractId];
}

class ContractCancelled extends ContractEvent {
  const ContractCancelled(this.contractId);
  final String contractId;
  @override
  List<Object?> get props => [contractId];
}
