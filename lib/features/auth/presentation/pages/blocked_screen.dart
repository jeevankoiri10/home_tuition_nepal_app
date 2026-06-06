import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/auth_repository.dart';

/// Support inbox shown to deactivated users — their only channel to appeal.
const String kSupportEmail = 'info.ktmacademy@gmail.com';

/// Full-screen, non-dismissable block shown whenever the signed-in account is
/// deactivated by an admin. The router guard traps the user here (every other
/// route redirects back), the system back button is disabled, and there is no
/// way into the app until an admin reactivates the account.
class BlockedScreen extends StatefulWidget {
  const BlockedScreen({super.key});

  @override
  State<BlockedScreen> createState() => _BlockedScreenState();
}

class _BlockedScreenState extends State<BlockedScreen> {
  bool _checking = false;

  Future<void> _emailUs() async {
    final uri = Uri(
      scheme: 'mailto',
      path: kSupportEmail,
      queryParameters: {'subject': 'Account reactivation appeal'},
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _checkAgain() async {
    setState(() => _checking = true);
    // Re-read the profile; if an admin has reactivated the account, the auth
    // stream emits and the router guard routes the user back into the app.
    await sl<AuthRepository>().reloadProfile();
    if (!mounted) return;
    setState(() => _checking = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).blockedScreenStillBlocked),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    // canPop:false swallows the Android back button so the screen can't be left.
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFEBEE),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.block, color: AppColors.danger, size: 72),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.blockedScreenTitle,
                    textAlign: TextAlign.center,
                    style: tt.headlineMedium?.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.blockedScreenMessage,
                    textAlign: TextAlign.center,
                    style: tt.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SelectableText(
                    kSupportEmail,
                    textAlign: TextAlign.center,
                    style: tt.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _emailUs,
                      icon: const Icon(Icons.email_outlined),
                      label: Text(l10n.blockedScreenEmailCta),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: _checking ? null : _checkAgain,
                    child: _checking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.blockedScreenRefresh),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
