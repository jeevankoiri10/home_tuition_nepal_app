import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/contracts/domain/models/contract.dart';

Contract _contract({
  num? rate,
  ContractRatePeriod period = ContractRatePeriod.month,
  ContractStatus status = ContractStatus.proposed,
}) =>
    Contract(
      id: 'c1',
      threadId: 't1',
      studentId: 's1',
      tutorId: 'tu1',
      proposedBy: 's1',
      subject: 'Physics',
      rateNpr: rate,
      ratePeriod: period,
      status: status,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  group('Contract.formatRate', () {
    test('returns a dash when no rate is set', () {
      expect(_contract(rate: null).formatRate(), '—');
    });

    test('renders the amount with the period', () {
      expect(_contract(rate: 8000).formatRate(), 'Rs. 8000 / month');
      expect(_contract(rate: 600, period: ContractRatePeriod.hour).formatRate(),
          'Rs. 600 / hour');
    });
  });

  group('ContractStatus', () {
    test('proposed and active are open; terminal states are not', () {
      expect(ContractStatus.proposed.isOpen, isTrue);
      expect(ContractStatus.active.isOpen, isTrue);
      expect(ContractStatus.completed.isOpen, isFalse);
      expect(ContractStatus.declined.isOpen, isFalse);
      expect(ContractStatus.cancelled.isOpen, isFalse);
    });

    test('fromString parses known values and falls back to proposed', () {
      expect(ContractStatus.fromString('active'), ContractStatus.active);
      expect(ContractStatus.fromString('completed'), ContractStatus.completed);
      expect(ContractStatus.fromString('weird'), ContractStatus.proposed);
      expect(ContractStatus.fromString(null), ContractStatus.proposed);
    });
  });
}
