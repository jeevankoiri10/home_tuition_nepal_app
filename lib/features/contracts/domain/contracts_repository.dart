import 'models/contract.dart';

class ContractsException implements Exception {
  ContractsException(this.code, [this.message]);
  final String code;
  final String? message;

  @override
  String toString() => 'ContractsException($code, $message)';
}

abstract class ContractsRepository {
  /// Most recent contract for a chat thread, or null if none yet.
  Future<Contract?> latestForThread(String threadId);

  /// Propose a new contract. [proposedBy] must be the current user id and one
  /// of [studentId] / [tutorId] (enforced server-side by RLS).
  Future<Contract> propose({
    required String threadId,
    required String studentId,
    required String tutorId,
    required String proposedBy,
    required String subject,
    num? rateNpr,
    required ContractRatePeriod ratePeriod,
    String? scheduleText,
  });

  Future<void> accept(String contractId);
  Future<void> decline(String contractId);
  Future<void> end(String contractId);
  Future<void> cancel(String contractId);
}
