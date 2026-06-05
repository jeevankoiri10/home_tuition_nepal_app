import 'package:flutter/material.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/subject_chips.dart';
import '../promote_job_action.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/job_post.dart';
import '../../domain/models/request_enums.dart';
import '../../domain/models/vacancy_request.dart';
import '../blocs/student_requests_bloc.dart';
import '../enum_labels.dart';

class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<StudentRequestsBloc, StudentRequestsState>(
      builder: (context, state) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: BrandAppBar(
              title: Text(l10n.myPostsTitle),
              bottom: TabBar(
                tabs: [
                  Tab(text: l10n.myPostsTabJobs(state.jobs.length)),
                  Tab(text: l10n.myPostsTabVacancies(state.vacancies.length)),
                ],
              ),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: l10n.postRequirementCta,
                          onPressed: () => context.push(AppRoutes.postJob),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.push(AppRoutes.requestTutor),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: const RoundedRectangleBorder(borderRadius: AppRadii.inputBorder),
                          ),
                          child: Text(l10n.requestTutorCta),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _JobsList(jobs: state.jobs, loading: state.status == StudentRequestsStatus.loading),
                      _VacanciesList(vacancies: state.vacancies),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Jobs ─────────────────────────────────────────────────────────────────────

class _JobsList extends StatelessWidget {
  const _JobsList({required this.jobs, required this.loading});
  final List<JobPost> jobs;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading && jobs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (jobs.isEmpty) {
      return _EmptyState(
        icon: Icons.work_outline,
        message: AppLocalizations.of(context).myJobsEmpty,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: jobs.length,
      itemBuilder: (_, i) => _JobCard(job: jobs[i]),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job});
  final JobPost job;

  void _repost(BuildContext context) {
    if (job.id != null) {
      context.read<StudentRequestsBloc>().add(StudentJobReposted(job.id!));
    }
  }

  void _close(BuildContext context) {
    if (job.id != null) {
      context.read<StudentRequestsBloc>().add(
            StudentJobStatusChanged(jobId: job.id!, status: JobStatus.closed),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: AppRadii.cardBorder,
        onTap: () {
          if (job.id != null) {
            context.push(AppRoutes.postDetail.replaceAll(':id', job.id!));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(job.title, style: tt.titleMedium)),
              _StatusBadge.forJob(job.status, l10n),
            ]),
            if (job.description != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(job.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodySmall),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(job.formatBudget(),
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            if (job.areaLabel != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(children: [
                const Icon(Icons.place_outlined, size: 14),
                const SizedBox(width: 2),
                Flexible(child: Text(job.areaLabel!, style: tt.bodySmall)),
              ]),
            ],
            const Divider(height: AppSpacing.xl),
            Row(children: [
              TextButton.icon(
                onPressed: () => context.push(AppRoutes.chatList),
                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                label: Text(l10n.viewMessages),
              ),
              const Spacer(),
              if (job.status == JobStatus.open && job.id != null)
                IconButton(
                  tooltip: l10n.promoteJobAction,
                  icon: const Icon(Icons.trending_up, size: 18),
                  onPressed: () => showPromoteJobDialog(context, jobId: job.id!),
                ),
              if (job.status == JobStatus.open)
                TextButton(onPressed: () => _close(context), child: Text(l10n.closeAction)),
              TextButton.icon(
                onPressed: () => _repost(context),
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(l10n.repostAction),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ─── Vacancies ────────────────────────────────────────────────────────────────

class _VacanciesList extends StatelessWidget {
  const _VacanciesList({required this.vacancies});
  final List<VacancyRequest> vacancies;

  @override
  Widget build(BuildContext context) {
    if (vacancies.isEmpty) {
      return _EmptyState(
        icon: Icons.assignment_outlined,
        message: AppLocalizations.of(context).myVacanciesEmpty,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: vacancies.length,
      itemBuilder: (_, i) => _VacancyCard(v: vacancies[i]),
    );
  }
}

class _VacancyCard extends StatelessWidget {
  const _VacancyCard({required this.v});
  final VacancyRequest v;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(v.code ?? l10n.vacancyPendingReview,
                  style: tt.labelMedium?.copyWith(color: AppColors.primary)),
            ),
            _StatusBadge.forVacancy(v.status, l10n),
          ]),
          const SizedBox(height: AppSpacing.xs),
          Text(v.title, style: tt.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          SubjectChips(subjects: v.subjects),
          const SizedBox(height: AppSpacing.sm),
          Text(v.formatSalary(), style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          if (v.areaLabel.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(children: [
              const Icon(Icons.place_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 2),
              Flexible(child: Text(v.areaLabel, style: tt.bodySmall)),
            ]),
          ],
        ]),
      ),
    );
  }
}

// ─── Reusable bits ────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});
  final String label;
  final Color color;

  factory _StatusBadge.forJob(JobStatus s, AppLocalizations l10n) {
    final color = switch (s) {
      JobStatus.open => AppColors.primary,
      JobStatus.shortlisting => const Color(0xFFED6C02),
      JobStatus.hired => const Color(0xFF2E7D32),
      JobStatus.closed => const Color(0xFFD32F2F),
      JobStatus.expired => AppColors.textSecondary,
    };
    return _StatusBadge(label: s.localized(l10n), color: color);
  }

  factory _StatusBadge.forVacancy(VacancyStatus s, AppLocalizations l10n) {
    final color = switch (s) {
      VacancyStatus.pendingAdminReview => const Color(0xFFED6C02),
      VacancyStatus.open => AppColors.primary,
      VacancyStatus.applicationsClosed => AppColors.textSecondary,
      VacancyStatus.filled => const Color(0xFF2E7D32),
      VacancyStatus.cancelled => const Color(0xFFD32F2F),
    };
    return _StatusBadge(label: s.localized(l10n), color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 48),
        const SizedBox(height: AppSpacing.md),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary)),
      ]),
    );
  }
}
