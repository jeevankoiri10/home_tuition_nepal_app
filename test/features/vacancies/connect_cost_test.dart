import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/constants/app_constants.dart';
import 'package:home_tuition_nepal_app/core/services/platform_settings_service.dart';
import 'package:home_tuition_nepal_app/features/vacancies/domain/connect_cost.dart';
import 'package:home_tuition_nepal_app/features/vacancies/domain/models/vacancy.dart';

Vacancy _vacancy({
  num? salaryMin,
  num? salaryMax,
  String period = 'month',
}) =>
    Vacancy(
      id: 'v1',
      title: 'Maths tutor',
      areaLabel: 'Lalitpur',
      salaryMinNpr: salaryMin,
      salaryMaxNpr: salaryMax,
      salaryPeriod: period,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  // Defaults from AppConstants: 10%, min 1, max 25.
  const percent = AppConstants.defaultApplyCostPercent;
  const min = AppConstants.defaultApplyCostMin;
  const max = AppConstants.defaultApplyCostMax;

  int cost(num? salary, {String period = 'month'}) => ConnectCost.forSalary(
        salary,
        period: period,
        percent: percent,
        min: min,
        max: max,
      );

  group('ConnectCost.forSalary', () {
    test('falls back to the floor when salary is unknown or non-positive', () {
      expect(cost(null), min);
      expect(cost(0), min);
      expect(cost(-500), min);
    });

    test('charges the floor for very small salaries', () {
      // 10% of Rs 5 = 0.5 → ceil 1, already the floor.
      expect(cost(5), 1);
    });

    test('scales with salary below the ceiling', () {
      // 10% of Rs 150 = 15.
      expect(cost(150), 15);
      // 10% of Rs 201 = 20.1 → ceil 21.
      expect(cost(201), 21);
    });

    test('clamps to the ceiling for realistic monthly salaries', () {
      // 10% of Rs 8000 = 800 → clamped to 25.
      expect(cost(8000), max);
      expect(cost(250), max); // 10% = 25, exactly the cap.
    });

    test('rounds up so the cost is never below the raw percentage', () {
      // 10% of Rs 11 = 1.1 → ceil 2.
      expect(cost(11), 2);
    });

    test('normalizes hourly pay to a monthly equivalent', () {
      // Rs 4/hr × 30 hrs = 120/mo → 10% = 12.
      expect(cost(4, period: 'hour'), 12);
      // Rs 500/hr × 30 = 15000/mo → 10% = 1500 → clamped to 25.
      expect(cost(500, period: 'hour'), max);
    });

    test('treats session pay like a flat per-period amount', () {
      // 10% of Rs 100 = 10, no hourly normalization.
      expect(cost(100, period: 'session'), 10);
    });

    test('normalizes daily pay to a monthly equivalent (job budgets)', () {
      // Rs 5/day × 26 days = 130/mo → 10% = 13.
      expect(cost(5, period: 'day'), 13);
    });

    test('treats a fixed budget as a one-off amount (job budgets)', () {
      // 10% of a Rs 80 fixed budget = 8, no normalization.
      expect(cost(80, period: 'fixed'), 8);
      // Realistic fixed project clamps to the ceiling.
      expect(cost(5000, period: 'fixed'), max);
    });
  });

  group('ConnectCost.forVacancy', () {
    test('prefers the upper salary band', () {
      final v = _vacancy(salaryMin: 50, salaryMax: 120);
      // Uses 120 → 10% = 12.
      expect(
        ConnectCost.forVacancy(v, percent: percent, min: min, max: max),
        12,
      );
    });

    test('falls back to the lower band when no upper band is set', () {
      final v = _vacancy(salaryMin: 80);
      expect(
        ConnectCost.forVacancy(v, percent: percent, min: min, max: max),
        8,
      );
    });

    test('charges the floor when the vacancy has no salary', () {
      final v = _vacancy();
      expect(
        ConnectCost.forVacancy(v, percent: percent, min: min, max: max),
        min,
      );
    });
  });

  group('ConnectCost.forVacancyWithSettings', () {
    test('reads percent/min/max from platform settings', () {
      // Empty settings → falls back to AppConstants defaults (10% / 1 / 25).
      final defaults = PlatformSettingsService.withValues(const {});
      expect(
        ConnectCost.forVacancyWithSettings(_vacancy(salaryMax: 120), defaults),
        12,
      );

      // Overridden knobs are honored: 5% of Rs 120 = 6, cap raised to 100.
      final tuned = PlatformSettingsService.withValues(const {
        'apply_cost_percent': '5',
        'apply_cost_min': '1',
        'apply_cost_max': '100',
      });
      expect(
        ConnectCost.forVacancyWithSettings(_vacancy(salaryMax: 120), tuned),
        6,
      );
    });
  });
}
