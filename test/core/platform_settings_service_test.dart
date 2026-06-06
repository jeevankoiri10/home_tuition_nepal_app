import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/constants/app_constants.dart';
import 'package:home_tuition_nepal_app/core/services/platform_settings_service.dart';

void main() {
  group('PlatformSettingsService — fallback (unconfigured)', () {
    final svc = PlatformSettingsService.withValues(const {});

    test('getInt returns the supplied fallback for a missing key', () {
      expect(svc.getInt('whatever', 7), 7);
    });

    test('getString returns null for a missing key', () {
      expect(svc.getString('whatever'), isNull);
    });

    test('typed getters return the AppConstants defaults', () {
      expect(svc.applyCoinCost, AppConstants.defaultApplyCoinCost);
      expect(svc.unlockCoinCost, AppConstants.defaultUnlockCoinCost);
      expect(svc.signupCoinGrant, AppConstants.defaultSignupCoinGrant);
      expect(svc.adminWhatsapp, AppConstants.defaultAdminWhatsapp);
    });
  });

  group('PlatformSettingsService — configured values', () {
    test('reads and parses server-provided overrides', () {
      final svc = PlatformSettingsService.withValues(const {
        'apply_coin_cost': '3',
        'unlock_coin_cost': '9',
        'signup_coin_grant': '500',
        'admin_whatsapp': 'https://wa.me/123',
      });
      expect(svc.applyCoinCost, 3);
      expect(svc.unlockCoinCost, 9);
      expect(svc.signupCoinGrant, 500);
      expect(svc.adminWhatsapp, 'https://wa.me/123');
    });

    test('a non-numeric value falls back rather than throwing', () {
      final svc = PlatformSettingsService.withValues(const {
        'apply_coin_cost': 'not-a-number',
      });
      expect(svc.applyCoinCost, AppConstants.defaultApplyCoinCost);
    });
  });
}
