import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/services/platform_settings_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../app/di.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../map/domain/models/map_tutor.dart';
import '../../../reviews/domain/reviews_repository.dart';
import '../../../reviews/presentation/widgets/submit_review_sheet.dart';
import '../../domain/wallet_repository.dart';
import '../blocs/wallet_bloc.dart';

/// Shows the unlock confirm flow, then on success an actionable Call /
/// WhatsApp surface (Phase 5 stops short of launching `tel:` / `wa.me/<num>`
/// because the real phone number lookup ships in Phase 9 chat / Phase 7 admin
/// match; for now we surface the unlocked state and update the wallet).
class ContactUnlockSheet extends StatefulWidget {
  const ContactUnlockSheet({
    super.key,
    required this.tutor,
    required this.walletRepository,
    required this.platformSettings,
  });

  final MapTutor tutor;
  final WalletRepository walletRepository;
  final PlatformSettingsService platformSettings;

  @override
  State<ContactUnlockSheet> createState() => _ContactUnlockSheetState();
}

class _ContactUnlockSheetState extends State<ContactUnlockSheet> {
  bool _busy = false;
  String? _error;
  bool _unlocked = false;
  int? _newBalance;

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context);
    final user = context.read<AuthBloc>().state.user;
    if (user == null) {
      setState(() => _error = l10n.unlockNotSignedIn);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final balance = await widget.walletRepository.unlockContact(
        studentId: user.id,
        tutorId: widget.tutor.tutorId,
      );
      if (!mounted) return;
      // Tell the wallet bloc to refresh in case the wallet page is also open.
      context.read<WalletBloc>().add(const WalletBalanceChanged());
      setState(() {
        _unlocked = true;
        _newBalance = balance;
        _busy = false;
      });
    } on WalletException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.isInsufficient
            ? l10n.unlockNeedMoreCoins
            : (e.message ?? l10n.unlockFailedGeneric);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cost = widget.platformSettings.unlockCoinCost;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(tutor: widget.tutor),
            const SizedBox(height: AppSpacing.lg),
            if (!_unlocked) ...[
              Text(l10n.unlockTitle(cost),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.unlockBody,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                _ErrorBox(
                  message: _error!,
                  showTopUp: _error == l10n.unlockNeedMoreCoins,
                  onTopUp: () {
                    Navigator.of(context).pop();
                    context.push(AppRoutes.wallet);
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: _busy ? l10n.workingEllipsis : l10n.unlockConfirmCta(cost),
                busy: _busy,
                onPressed: _busy ? null : _confirm,
              ),
            ] else
              _UnlockedView(
                newBalance: _newBalance ?? 0,
                tutorId: widget.tutor.tutorId,
                tutorName: widget.tutor.maskedName,
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.tutor});
  final MapTutor tutor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryLight,
            border: Border.all(
              color: tutor.verified ? const Color(0xFFFFD54F) : Colors.transparent,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.person_outline, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tutor.maskedName, style: Theme.of(context).textTheme.titleLarge),
              Text('${tutor.areaLabel} · ${tutor.formatDistance()}',
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({
    required this.message,
    required this.showTopUp,
    required this.onTopUp,
  });

  final String message;
  final bool showTopUp;
  final VoidCallback onTopUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEF9A9A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message,
                    style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w500)),
                if (showTopUp) ...[
                  const SizedBox(height: AppSpacing.xs),
                  TextButton(
                    onPressed: onTopUp,
                    child: Text(AppLocalizations.of(context).buyCoinsLink),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockedView extends StatelessWidget {
  const _UnlockedView({
    required this.newBalance,
    required this.tutorId,
    required this.tutorName,
  });

  final int newBalance;
  final String tutorId;
  final String tutorName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
            const SizedBox(width: AppSpacing.sm),
            Text(l10n.unlockSuccess,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.unlockNewBalance(newBalance),
            style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: l10n.openChat,
          onPressed: () {
            Navigator.of(context).pop();
            final encoded = Uri.encodeComponent(tutorName);
            context.push('/chat/$tutorId?name=$encoded');
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.unlockCallPhase7Hint)),
                  );
                },
                icon: const Icon(Icons.phone_outlined),
                label: Text(l10n.callLabel),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.unlockWhatsAppPhase7Hint)),
                  );
                },
                icon: const Icon(Icons.chat_outlined),
                label: Text(l10n.whatsAppLabel),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          Expanded(
            child: TextButton.icon(
              icon: const Icon(Icons.star_border_rounded),
              label: Text(l10n.leaveReview),
              onPressed: () {
                Navigator.of(context).pop();
                showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => SubmitReviewSheet(
                    tutorId: tutorId,
                    tutorMaskedName: tutorName,
                    reviews: sl<ReviewsRepository>(),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.doneLabel),
            ),
          ),
        ]),
      ],
    );
  }
}
