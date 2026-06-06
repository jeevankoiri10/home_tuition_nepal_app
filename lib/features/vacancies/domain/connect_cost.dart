import '../../../core/constants/app_constants.dart';
import '../../../core/services/platform_settings_service.dart';
import 'models/vacancy.dart';

/// Computes the connect (apply) coin cost for a vacancy as a percentage of the
/// job's salary, clamped to a floor and ceiling.
///
/// This mirrors the server-authoritative `vacancy_apply_cost` /
/// `tutor_apply_to_vacancy` formula (migration `0034_percentage_connect_cost`).
/// The wallet stays server-authoritative — this client-side calculation is for
/// display only (showing the tutor what an application will cost before they
/// commit). The two must stay in sync; change both together.
class ConnectCost {
  const ConnectCost._();

  /// Connect cost in coins for [vacancy] given the platform [percent]
  /// (e.g. `10` for 10%), [min] floor and [max] ceiling.
  ///
  /// Uses the upper salary band when present — the most a tutor could earn —
  /// falling back to the lower band. When the salary is unknown the cost is the
  /// [min] floor, so applying always costs at least something.
  /// Convenience overload reading the live percent/min/max from [settings] —
  /// the single place the UI should compute an apply cost from.
  static int forVacancyWithSettings(
    Vacancy vacancy,
    PlatformSettingsService settings,
  ) =>
      forVacancy(
        vacancy,
        percent: settings.applyCostPercent,
        min: settings.applyCostMin,
        max: settings.applyCostMax,
      );

  static int forVacancy(
    Vacancy vacancy, {
    required int percent,
    required int min,
    required int max,
  }) =>
      forSalary(
        vacancy.salaryMaxNpr ?? vacancy.salaryMinNpr,
        period: vacancy.salaryPeriod,
        percent: percent,
        min: min,
        max: max,
      );

  /// Connect cost for a raw [salary]/budget in NPR over the given [period]
  /// (`month` / `hour` / `day` / `session` / `fixed`). Hourly and daily pay are
  /// normalized to a monthly equivalent (via
  /// [AppConstants.applyCostHourlyMonthlyHours] /
  /// [AppConstants.applyCostDayMonthlyDays]) so the percentage is comparable
  /// across pay structures; `month`, `session` and `fixed` use the raw amount.
  ///
  /// Shared by vacancy applications and job-post bids — both charge a percentage
  /// of what the tutor stands to earn.
  static int forSalary(
    num? salary, {
    required String period,
    required int percent,
    required int min,
    required int max,
  }) {
    if (salary == null || salary <= 0) return min;
    final monthlyEquivalent = switch (period) {
      'hour' => salary * AppConstants.applyCostHourlyMonthlyHours,
      'day' => salary * AppConstants.applyCostDayMonthlyDays,
      _ => salary,
    };
    final raw = monthlyEquivalent * percent / 100;
    return raw.ceil().clamp(min, max);
  }
}
