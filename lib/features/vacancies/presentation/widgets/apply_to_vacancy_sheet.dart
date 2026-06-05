import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/services/platform_settings_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/phone_ban_regex.dart';
import '../../../../core/widgets/phone_ban_warning.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/connect_cost.dart';
import '../../domain/models/vacancy.dart';
import '../blocs/vacancies_bloc.dart';

class ApplyToVacancySheet extends StatefulWidget {
  const ApplyToVacancySheet({
    super.key,
    required this.vacancy,
    required this.platformSettings,
  });

  final Vacancy vacancy;
  final PlatformSettingsService platformSettings;

  @override
  State<ApplyToVacancySheet> createState() => _ApplyToVacancySheetState();
}

class _ApplyToVacancySheetState extends State<ApplyToVacancySheet> {
  final _cover = TextEditingController();
  final _rate = TextEditingController();

  @override
  void dispose() {
    _cover.dispose();
    _rate.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (PhoneBanRegex.isViolation(_cover.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.applyCoverPhoneViolation)),
      );
      return;
    }
    if (_cover.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.applyCoverRequired)),
      );
      return;
    }
    context.read<VacanciesBloc>().add(VacancyApplied(
          vacancyId: widget.vacancy.id,
          coverNote: _cover.text.trim(),
          expectedRate: num.tryParse(_rate.text.trim()),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Connect cost scales with the job's salary (server-authoritative formula
    // mirrored in ConnectCost), not a flat per-apply price.
    final cost =
        ConnectCost.forVacancyWithSettings(widget.vacancy, widget.platformSettings);
    return BlocConsumer<VacanciesBloc, VacanciesState>(
      listenWhen: (a, b) => a.applyStatus != b.applyStatus,
      listener: (context, state) {
        if (state.applyStatus == ApplyStatus.success) {
          context.read<VacanciesBloc>().add(const VacancyApplyAcknowledged());
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.applySuccessSnack)),
          );
        }
      },
      builder: (context, state) {
        final busy = state.applyStatus == ApplyStatus.submitting;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.applySheetTitle(widget.vacancy.code ?? widget.vacancy.title),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(widget.vacancy.areaLabel,
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.lg),
                PhoneBanWarning(message: l10n.applyPhoneBanWarning),
                TextField(
                  controller: _cover,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: l10n.applyCoverLabel,
                    hintText: l10n.applyCoverHint,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _rate,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.applyRateLabel,
                    prefixIcon: const Icon(Icons.payments_outlined),
                  ),
                ),
                if (state.applyError != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _ApplyError(
                    message: state.applyError!,
                    // Offer a top-up shortcut only when the bloc flagged the
                    // failure as insufficient coins (structured signal, not a
                    // brittle match on the server's message text).
                    onTopUp: state.applyNeedsTopUp
                        ? () {
                            Navigator.of(context).pop();
                            context.push(AppRoutes.wallet);
                          }
                        : null,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: busy ? l10n.applySending : l10n.applyButtonLabel(cost),
                  busy: busy,
                  onPressed: busy ? null : () => _submit(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ApplyError extends StatelessWidget {
  const _ApplyError({required this.message, required this.onTopUp});
  final String message;
  final VoidCallback? onTopUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEF9A9A)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(message,
                style: const TextStyle(
                    color: Color(0xFFD32F2F), fontWeight: FontWeight.w500)),
            if (onTopUp != null) ...[
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: onTopUp,
                child: Text(AppLocalizations.of(context).buyCoinsLink),
              ),
            ],
          ]),
        ),
      ]),
    );
  }
}
