import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../config/env.dart';
import '../constants/app_constants.dart';

/// Read-only snapshot of `platform_settings`. Refreshed on app launch and
/// cached for the lifetime of the session. When Supabase credentials are
/// absent, falls back to the defaults in [AppConstants].
class PlatformSettingsService {
  PlatformSettingsService();

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

  int get unlockCoinCost =>
      getInt('unlock_coin_cost', AppConstants.defaultUnlockCoinCost);

  int get signupCoinGrant =>
      getInt('signup_coin_grant', AppConstants.defaultSignupCoinGrant);

  String get adminWhatsapp =>
      getString('admin_whatsapp') ?? AppConstants.defaultAdminWhatsapp;
}
