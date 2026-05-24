import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../services/platform_settings_service.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

/// Shown by callers that catch an `account_blocked` server error (returned by
/// every gated RPC after Phase 12). Tappable — links to the admin WhatsApp
/// stored in `platform_settings.admin_whatsapp` so the user can appeal.
class AccountBlockedBanner extends StatelessWidget {
  const AccountBlockedBanner({
    super.key,
    required this.settings,
    this.reason,
  });

  final PlatformSettingsService settings;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: AppRadii.cardBorder,
        border: Border.all(color: const Color(0xFFEF9A9A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            const Icon(Icons.block, color: Color(0xFFD32F2F)),
            const SizedBox(width: AppSpacing.sm),
            Text(l10n.accountBlockedTitle,
                style: const TextStyle(
                    color: Color(0xFFD32F2F),
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Text(reason ?? l10n.accountBlockedReason),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l10n.openThisUrl(settings.adminWhatsapp)),
              ));
            },
            icon: const Icon(Icons.chat_outlined),
            label: Text(l10n.contactAdminOnWhatsApp),
          ),
        ],
      ),
    );
  }
}
