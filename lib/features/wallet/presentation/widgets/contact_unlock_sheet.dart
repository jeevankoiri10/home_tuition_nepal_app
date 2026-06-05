import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router.dart';
import '../../../../core/services/platform_settings_service.dart';
import '../../../../core/utils/contact_links.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../app/di.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../map/domain/models/map_tutor.dart';
import '../../../reviews/domain/reviews_repository.dart';
import '../../../reviews/presentation/widgets/reviews_sheet.dart';
import '../../../reviews/presentation/widgets/star_rating_input.dart';
import '../../../reviews/presentation/widgets/submit_review_sheet.dart';
import '../../domain/wallet_repository.dart';
import '../blocs/wallet_bloc.dart';

/// Shows the unlock confirm flow, then on success an actionable Call / WhatsApp
/// / Chat surface. The tutor's phone is fetched via the server-gated
/// `revealContact` (only returns a number once the contact is unlocked) and the
/// Call/WhatsApp buttons launch `tel:` / `wa.me` via [ContactLinks].
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
  // True only when the last failure was insufficient coins — drives the
  // "top up" shortcut. Captured from the exception type, not by matching the
  // (localized) error text.
  bool _needsTopUp = false;
  bool _unlocked = false;
  int? _newBalance;
  String? _phone;

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
      _needsTopUp = false;
    });
    try {
      final balance = await widget.walletRepository.unlockContact(
        studentId: user.id,
        tutorId: widget.tutor.tutorId,
      );
      if (!mounted) return;
      // Tell the wallet bloc to refresh in case the wallet page is also open.
      context.read<WalletBloc>().add(const WalletBalanceChanged());
      // Reveal the now-unlocked phone so Call/WhatsApp can launch. A reveal
      // failure must not undo the (already-committed) unlock, so swallow it —
      // the buttons fall back to a "no number" message.
      String? phone;
      try {
        phone = await widget.walletRepository.revealContact(
          studentId: user.id,
          tutorId: widget.tutor.tutorId,
        );
      } on WalletException {
        phone = null;
      }
      if (!mounted) return;
      setState(() {
        _unlocked = true;
        _newBalance = balance;
        _phone = phone;
        _busy = false;
      });
    } on WalletException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _needsTopUp = e.isInsufficient;
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
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                StarRatingBadge(
                  average: widget.tutor.rating.toDouble(),
                  count: widget.tutor.ratingCount,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => ReviewsSheet.showForTutor(
                    context,
                    tutorId: widget.tutor.tutorId,
                  ),
                  icon: const Icon(Icons.reviews_outlined, size: 18),
                  label: Text(l10n.seeReviewsAction),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
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
                  showTopUp: _needsTopUp,
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
                phone: _phone,
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
              Row(
                children: [
                  Flexible(
                    child: Text(tutor.maskedName,
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (tutor.verified) ...[
                    const SizedBox(width: AppSpacing.xs),
                    VerifiedBadge(
                      size: 18,
                      semanticLabel: AppLocalizations.of(context).verifiedTutorLabel,
                    ),
                  ],
                ],
              ),
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
    required this.phone,
  });

  final int newBalance;
  final String tutorId;
  final String tutorName;
  final String? phone;

  Future<void> _launch(
      BuildContext context, Uri Function(String phone) buildUri) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final number = phone;
    if (number == null || number.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.contactNoNumber)));
      return;
    }
    final ok =
        await launchUrl(buildUri(number), mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.contactLaunchFailed)));
    }
  }

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
                onPressed: () => _launch(context, ContactLinks.tel),
                icon: const Icon(Icons.phone_outlined),
                label: Text(l10n.callLabel),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _launch(context, ContactLinks.whatsApp),
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
