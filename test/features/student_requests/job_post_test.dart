import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/student_requests/domain/models/job_post.dart';
import 'package:home_tuition_nepal_app/features/student_requests/domain/models/request_enums.dart';

JobPost _job({
  num? min,
  num? max,
  BudgetPeriod period = BudgetPeriod.month,
}) =>
    JobPost(
      studentId: 's1',
      title: 'Need a Maths tutor',
      budgetMinNpr: min,
      budgetMaxNpr: max,
      budgetPeriod: period,
    );

void main() {
  group('JobPost.formatBudget', () {
    test('returns a dash when no minimum budget is set', () {
      expect(_job(min: null).formatBudget(), '—');
    });

    test('single amount appends the period suffix and groups thousands', () {
      expect(_job(min: 10000).formatBudget(), 'Rs. 10,000/month');
      expect(_job(min: 500, period: BudgetPeriod.hour).formatBudget(),
          'Rs. 500/hour');
    });

    test('a distinct min/max renders a range', () {
      expect(_job(min: 8000, max: 12000).formatBudget(), 'Rs. 8,000–12,000/month');
    });

    test('max equal to min collapses to a single amount', () {
      expect(_job(min: 9000, max: 9000).formatBudget(), 'Rs. 9,000/month');
    });

    test('fixed period uses the (fixed) label, not a per-suffix', () {
      expect(_job(min: 15000, period: BudgetPeriod.fixed).formatBudget(),
          'Rs. 15,000 (fixed)');
    });
  });

  group('BudgetPeriod.fromString', () {
    test('parses a known value', () {
      expect(BudgetPeriod.fromString('hour'), BudgetPeriod.hour);
    });

    test('falls back to month for an unknown value', () {
      expect(BudgetPeriod.fromString('fortnight'), BudgetPeriod.month);
      expect(BudgetPeriod.fromString(null), BudgetPeriod.month);
    });
  });
}
