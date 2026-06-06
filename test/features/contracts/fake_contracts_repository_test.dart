import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/contracts/data/fake_contracts_repository.dart';
import 'package:home_tuition_nepal_app/features/contracts/domain/contracts_repository.dart';
import 'package:home_tuition_nepal_app/features/contracts/domain/models/contract.dart';

void main() {
  group('FakeContractsRepository', () {
    late FakeContractsRepository repo;

    setUp(() => repo = FakeContractsRepository());

    Future<Contract> proposeSample() => repo.propose(
          threadId: 't1',
          studentId: 'student',
          tutorId: 'tutor',
          proposedBy: 'student',
          subject: 'Maths SEE',
          rateNpr: 8000,
          ratePeriod: ContractRatePeriod.month,
          scheduleText: 'Sun–Fri 5pm',
        );

    test('propose creates a proposed contract recorded against the thread', () async {
      final c = await proposeSample();
      expect(c.status, ContractStatus.proposed);
      expect(c.proposedBy, 'student');
      final latest = await repo.latestForThread('t1');
      expect(latest?.id, c.id);
    });

    test('accept moves proposed → active and stamps startedAt', () async {
      final c = await proposeSample();
      await repo.accept(c.id);
      final latest = await repo.latestForThread('t1');
      expect(latest?.status, ContractStatus.active);
      expect(latest?.startedAt, isNotNull);
    });

    test('end moves active → completed and stamps endedAt', () async {
      final c = await proposeSample();
      await repo.accept(c.id);
      await repo.end(c.id);
      final latest = await repo.latestForThread('t1');
      expect(latest?.status, ContractStatus.completed);
      expect(latest?.endedAt, isNotNull);
    });

    test('decline moves proposed → declined', () async {
      final c = await proposeSample();
      await repo.decline(c.id);
      final latest = await repo.latestForThread('t1');
      expect(latest?.status, ContractStatus.declined);
    });

    test('cancel moves proposed → cancelled', () async {
      final c = await proposeSample();
      await repo.cancel(c.id);
      final latest = await repo.latestForThread('t1');
      expect(latest?.status, ContractStatus.cancelled);
    });

    test('latestForThread returns the most recent proposal', () async {
      final first = await proposeSample();
      await repo.decline(first.id);
      final second = await proposeSample();
      final latest = await repo.latestForThread('t1');
      expect(latest?.id, second.id);
      expect(latest?.status, ContractStatus.proposed);
    });

    test('awaitingMyResponse is true only for the non-proposer', () async {
      final c = await proposeSample();
      expect(c.awaitingMyResponse('tutor'), isTrue);
      expect(c.awaitingMyResponse('student'), isFalse);
    });

    test('unknown contract id throws ContractsException', () async {
      expect(() => repo.accept('missing'), throwsA(isA<ContractsException>()));
    });
  });
}
