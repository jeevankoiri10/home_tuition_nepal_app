import 'package:flutter/material.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../app/router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../domain/models/request_enums.dart';
import '../blocs/student_requests_bloc.dart';
import '../enum_labels.dart';
import '../promote_job_action.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<StudentRequestsBloc, StudentRequestsState>(
      builder: (context, state) {
        final job = state.jobs.where((j) => j.id == jobId).firstOrNull;
        if (job == null) {
          return Scaffold(
            appBar: BrandAppBar(title: Text(l10n.postDetailTitle)),
            body: Center(child: Text(l10n.postNotFound)),
          );
        }
        final closed = job.status == JobStatus.closed || job.status == JobStatus.expired;
        return Scaffold(
          appBar: BrandAppBar(title: Text(l10n.postDetailTitle)),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (closed) _ClosedBanner(message: l10n.postClosedBanner),
              Text(job.title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.chatList),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text(l10n.viewMessages),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<StudentRequestsBloc>().add(StudentJobReposted(job.id!));
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.repostAction),
                  ),
                  if (!closed && job.id != null)
                    FilledButton.icon(
                      onPressed: () => showPromoteJobDialog(context, jobId: job.id!),
                      icon: const Icon(Icons.trending_up),
                      label: Text(l10n.promoteJobAction),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (job.subject != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(job.subject!, style: const TextStyle(color: AppColors.primary)),
                ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.cardBorder),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(children: [
                    if (job.areaLabel != null)
                      _DetailRow(icon: Icons.place_outlined, text: job.areaLabel!),
                    if (job.createdAt != null)
                      _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        text: l10n.postPostedPrefix(_formatDate(context, job.createdAt!)),
                      ),
                    if (job.engagementType != null)
                      _DetailRow(
                        icon: Icons.person_outline,
                        text: l10n.postRequiresPrefix(job.engagementType!.localized(l10n)),
                      ),
                    _DetailRow(
                      icon: Icons.account_circle_outlined,
                      text: l10n.postPostedByPrefix(_maskedPoster(context, l10n)),
                    ),
                    _DetailRow(
                      icon: Icons.verified_user_outlined,
                      iconColor: const Color(0xFF2E7D32),
                      text: l10n.postWhatsAppVerified,
                    ),
                    _DetailRow(
                      icon: Icons.wc_outlined,
                      text: l10n.vacancyGenderPrefPrefix(job.genderPref.localized(l10n)),
                    ),
                    _DetailRow(
                      icon: job.mode == JobMode.online ? Icons.wifi : Icons.wifi_off,
                      text: job.mode == JobMode.online
                          ? l10n.postModeOnlineYes
                          : (job.mode == JobMode.either
                              ? l10n.postModeEither
                              : l10n.postModeOnlineNo),
                    ),
                    _DetailRow(
                      icon: Icons.home_outlined,
                      text: job.mode != JobMode.online
                          ? l10n.postModeHomeYes
                          : l10n.postModeHomeNo,
                    ),
                    _DetailRow(
                      icon: job.canTravel ? Icons.directions_car : Icons.no_transfer,
                      text: job.canTravel ? l10n.postCanTravel : l10n.postCannotTravel,
                    ),
                    _DetailRow(
                      icon: Icons.payments_outlined,
                      text: job.formatBudget(),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.postDescriptionHeader, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Card(
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.cardBorder),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(job.description ?? l10n.postNoDescription),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(BuildContext context, DateTime d) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMMMd(locale).format(d);
  }

  String _maskedPoster(BuildContext context, AppLocalizations l10n) {
    final user = context.read<AuthBloc>().state.user;
    return user?.displayName ?? l10n.postYouFallback;
  }
}

class _ClosedBanner extends StatelessWidget {
  const _ClosedBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: AppRadii.cardBorder,
        border: Border.all(color: const Color(0xFFEF9A9A)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text, this.iconColor});
  final IconData icon;
  final String text;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(children: [
        Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text)),
      ]),
    );
  }
}
