import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/contract.dart';
import '../blocs/contract_bloc.dart';
import 'propose_contract_sheet.dart';
import 'review_sheet.dart';

/// Sits at the top of a chat thread. Renders the current contract state and
/// the actions available to the viewer (propose / accept / decline / end),
/// and pops a review sheet when the student ends an active contract.
class ContractBanner extends StatelessWidget {
  const ContractBanner({
    super.key,
    required this.threadId,
    required this.studentId,
    required this.tutorId,
    required this.viewerId,
    required this.counterpartyName,
  });

  final String threadId;
  final String studentId;
  final String tutorId;
  final String viewerId;
  final String counterpartyName;

  bool get _viewerIsStudent => viewerId == studentId;

  Future<void> _propose(BuildContext context) async {
    final result = await showModalBottomSheet<ProposeContractResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const ProposeContractSheet(),
    );
    if (result == null || !context.mounted) return;
    context.read<ContractBloc>().add(ContractProposed(
          studentId: studentId,
          tutorId: tutorId,
          proposedBy: viewerId,
          subject: result.subject,
          rateNpr: result.rateNpr,
          ratePeriod: result.ratePeriod,
          scheduleText: result.scheduleText,
        ));
  }

  Future<void> _endThenReview(BuildContext context, Contract contract) async {
    context.read<ContractBloc>().add(ContractEnded(contract.id));
    // The student reviews the tutor on completion. The tutor side just sees
    // the contract flip to completed.
    if (_viewerIsStudent) {
      await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => ReviewSheet(tutorId: tutorId, tutorName: counterpartyName),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<ContractBloc, ContractState>(
      listenWhen: (a, b) => a.errorMessage != b.errorMessage && b.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
      },
      builder: (context, state) {
        final contract = state.contract;
        // No live contract → offer to start one.
        if (contract == null || !contract.status.isOpen) {
          return _Shell(
            child: Row(
              children: [
                const Icon(Icons.handshake_outlined, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    contract?.status == ContractStatus.completed
                        ? l10n.contractCompletedHint
                        : l10n.contractNoneHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                TextButton(
                  onPressed: () => _propose(context),
                  child: Text(l10n.contractStartCta),
                ),
              ],
            ),
          );
        }

        // Proposed — either waiting on me or on the counterparty.
        if (contract.status == ContractStatus.proposed) {
          final awaitingMe = contract.awaitingMyResponse(viewerId);
          return _Shell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ContractSummary(contract: contract),
                const SizedBox(height: AppSpacing.sm),
                if (awaitingMe)
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () =>
                              context.read<ContractBloc>().add(ContractAccepted(contract.id)),
                          child: Text(l10n.contractAccept),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              context.read<ContractBloc>().add(ContractDeclined(contract.id)),
                          child: Text(l10n.contractDecline),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: Text(l10n.contractWaitingResponse,
                            style: const TextStyle(color: AppColors.textSecondary)),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.read<ContractBloc>().add(ContractCancelled(contract.id)),
                        child: Text(l10n.contractCancel),
                      ),
                    ],
                  ),
              ],
            ),
          );
        }

        // Active — show details + End.
        return _Shell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_outlined, color: AppColors.success, size: 18),
                  const SizedBox(width: 4),
                  Text(l10n.contractActiveLabel,
                      style: const TextStyle(
                          color: AppColors.success, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              _ContractSummary(contract: contract),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.flag_outlined, size: 16),
                  label: Text(l10n.contractEndCta),
                  onPressed: () => _endThenReview(context, contract),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Shell extends StatelessWidget {
  const _Shell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadii.cardBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _ContractSummary extends StatelessWidget {
  const _ContractSummary({required this.contract});
  final Contract contract;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(contract.subject, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        Text(
          '${contract.formatRate()}${contract.scheduleText != null ? ' · ${contract.scheduleText}' : ''}',
          style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
