import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../config/env.dart';
import '../constants/app_constants.dart';

/// Read-only snapshot of `platform_settings`. Refreshed on app launch and
/// cached for the lifetime of the session. When Supabase credentials are
/// absent, falls back to the defaults in [AppConstants].
class PlatformSettingsService {
  PlatformSettingsService();

  /// Test-only: seed the cached values directly without hitting Supabase.
  @visibleForTesting
  PlatformSettingsService.withValues(Map<String, String> values)
      : _values = values;

  Map<String, String> _values = const {};

  Future<void> refresh() async {
    if (!Env.hasSupabase) {
      _values = const {};
      return;
    }
    try {
      final rows = await sb.Supabase.instance.client
          .from('platform_settings')
          .select('key, value');
      _values = {
        for (final row in (rows as List).cast<Map<String, dynamic>>())
          row['key'] as String: (row['value'] as String?) ?? '',
      };
    } catch (_) {
      // Use cached values on failure — never break the app on settings load.
    }
  }

  String? getString(String key) => _values[key];

  int getInt(String key, int fallback) {
    final raw = _values[key];
    if (raw == null) return fallback;
    return int.tryParse(raw) ?? fallback;
  }

  int get applyCoinCost =>
      getInt('apply_coin_cost', AppConstants.defaultApplyCoinCost);

  /// Percentage-based connect cost knobs. The apply price is
  /// `ceil(salary × applyCostPercent%)` clamped to `[applyCostMin, applyCostMax]`.
  /// See [AppConstants.defaultApplyCostPercent] and `ConnectCost`.
  int get applyCostPercent =>
      getInt('apply_cost_percent', AppConstants.defaultApplyCostPercent);

  int get applyCostMin =>
      getInt('apply_cost_min', AppConstants.defaultApplyCostMin);

  int get applyCostMax =>
      getInt('apply_cost_max', AppConstants.defaultApplyCostMax);

  int get unlockCoinCost =>
      getInt('unlock_coin_cost', AppConstants.defaultUnlockCoinCost);

  int get signupCoinGrant =>
      getInt('signup_coin_grant', AppConstants.defaultSignupCoinGrant);

  String get adminWhatsapp =>
      getString('admin_whatsapp') ?? AppConstants.defaultAdminWhatsapp;
}
