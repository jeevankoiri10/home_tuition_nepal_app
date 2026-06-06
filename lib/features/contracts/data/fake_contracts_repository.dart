import '../domain/contracts_repository.dart';
import '../domain/models/contract.dart';

/// In-memory contracts for local dev. Mirrors the SQL RPC transition rules.
class FakeContractsRepository implements ContractsRepository {
  final Map<String, Contract> _byId = {};
  int _counter = 0;

  @override
  Future<Contract?> latestForThread(String threadId) async {
    // _byId is insertion-ordered (Dart LinkedHashMap), so the last matching
    // entry is the most recently proposed — deterministic even when two
    // proposals share a createdAt millisecond.
    Contract? latest;
    for (final c in _byId.values) {
      if (c.threadId == threadId) latest = c;
    }
    return latest;
  }

  @override
  Future<Contract> propose({
    required String threadId,
    required String studentId,
    required String tutorId,
    required String proposedBy,
    required String subject,
    num? rateNpr,
    required ContractRatePeriod ratePeriod,
    String? scheduleText,
  }) async {
    final id = 'contract-${++_counter}';
    final c = Contract(
      id: id,
      threadId: threadId,
      studentId: studentId,
      tutorId: tutorId,
      proposedBy: proposedBy,
      subject: subject,
      rateNpr: rateNpr,
      ratePeriod: ratePeriod,
      scheduleText: scheduleText,
      status: ContractStatus.proposed,
      createdAt: DateTime.now(),
    );
    _byId[id] = c;
    return c;
  }

  @override
  Future<void> accept(String contractId) async =>
      _transition(contractId, ContractStatus.active, started: true);

  @override
  Future<void> decline(String contractId) async =>
      _transition(contractId, ContractStatus.declined, ended: true);

  @override
  Future<void> end(String contractId) async =>
      _transition(contractId, ContractStatus.completed, ended: true);

  @override
  Future<void> cancel(String contractId) async =>
      _transition(contractId, ContractStatus.cancelled, ended: true);

  void _transition(String id, ContractStatus to, {bool started = false, bool ended = false}) {
    final c = _byId[id];
    if (c == null) throw ContractsException('not_found');
    _byId[id] = Contract(
      id: c.id,
      threadId: c.threadId,
      studentId: c.studentId,
      tutorId: c.tutorId,
      proposedBy: c.proposedBy,
      subject: c.subject,
      rateNpr: c.rateNpr,
      ratePeriod: c.ratePeriod,
      scheduleText: c.scheduleText,
      status: to,
      createdAt: c.createdAt,
      startedAt: started ? DateTime.now() : c.startedAt,
      endedAt: ended ? DateTime.now() : c.endedAt,
    );
  }
}
