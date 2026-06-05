import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/contracts/data/fake_contracts_repository.dart';
import 'package:home_tuition_nepal_app/features/contracts/domain/models/contract.dart';
import 'package:home_tuition_nepal_app/features/contracts/presentation/blocs/contract_bloc.dart';

void main() {
  group('ContractBloc', () {
    blocTest<ContractBloc, ContractState>(
      'opening an empty thread resolves to ready with no contract',
      build: () => ContractBloc(FakeContractsRepository()),
      act: (b) => b.add(const ContractThreadOpened('t1')),
      wait: const Duration(milliseconds: 50),
      verify: (b) {
        expect(b.state.status, ContractLoad.ready);
        expect(b.state.contract, isNull);
      },
    );

    blocTest<ContractBloc, ContractState>(
      'proposing then accepting surfaces an active contract',
      build: () => ContractBloc(FakeContractsRepository()),
      act: (b) async {
        b.add(const ContractThreadOpened('t1'));
        await Future<void>.delayed(const Duration(milliseconds: 20));
        b.add(const ContractProposed(
          studentId: 'student',
          tutorId: 'tutor',
          proposedBy: 'student',
          subject: 'Science',
          ratePeriod: ContractRatePeriod.month,
          rateNpr: 6000,
        ));
        await Future<void>.delayed(const Duration(milliseconds: 20));
        final id = b.state.contract!.id;
        b.add(ContractAccepted(id));
      },
      wait: const Duration(milliseconds: 100),
      verify: (b) {
        expect(b.state.contract, isNotNull);
        expect(b.state.contract!.status, ContractStatus.active);
      },
    );

    blocTest<ContractBloc, ContractState>(
      'ending an active contract marks it completed',
      build: () => ContractBloc(FakeContractsRepository()),
      act: (b) async {
        b.add(const ContractThreadOpened('t1'));
        await Future<void>.delayed(const Duration(milliseconds: 20));
        b.add(const ContractProposed(
          studentId: 'student',
          tutorId: 'tutor',
          proposedBy: 'tutor',
          subject: 'English',
          ratePeriod: ContractRatePeriod.session,
        ));
        await Future<void>.delayed(const Duration(milliseconds: 20));
        final id = b.state.contract!.id;
        b.add(ContractAccepted(id));
        await Future<void>.delayed(const Duration(milliseconds: 20));
        b.add(ContractEnded(id));
      },
      wait: const Duration(milliseconds: 120),
      verify: (b) {
        expect(b.state.contract!.status, ContractStatus.completed);
      },
    );
  });
}
