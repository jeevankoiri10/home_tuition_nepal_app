import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../domain/models/job_post.dart';
import '../../domain/models/request_enums.dart';
import '../blocs/student_requests_bloc.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentRequestsBloc, StudentRequestsState>(
      builder: (context, state) {
        final job = state.jobs.where((j) => j.id == jobId).firstOrNull;
        if (job == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Post Detail')),
            body: const Center(child: Text('Post not found.')),
          );
        }
        final closed = job.status == JobStatus.closed || job.status == JobStatus.expired;
        return Scaffold(
          appBar: AppBar(title: const Text('Post Detail')),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (closed) const _ClosedBanner(),
              Text(job.title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Row(children: [
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('In-app chat ships in Phase 9.')),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('View Messages'),
                ),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<StudentRequestsBloc>().add(StudentJobReposted(job.id!));
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Repost'),
                ),
              ]),
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
                        text: 'Posted: ${_date(job.createdAt!)}',
                      ),
                    if (job.engagementType != null)
                      _DetailRow(
                        icon: Icons.person_outline,
                        text: 'Requires: ${job.engagementType!.label}',
                      ),
                    _DetailRow(
                      icon: Icons.account_circle_outlined,
                      text: 'Posted by: ${_maskedPoster(context)}',
                    ),
                    _DetailRow(
                      icon: Icons.verified_user_outlined,
                      iconColor: const Color(0xFF2E7D32),
                      text: 'WhatsApp verified ✓ (number hidden until match)',
                    ),
                    _DetailRow(
                      icon: Icons.wc_outlined,
                      text: 'Gender preference: ${job.genderPref.label}',
                    ),
                    _DetailRow(
                      icon: job.mode == JobMode.online ? Icons.wifi : Icons.wifi_off,
                      text: job.mode == JobMode.online
                          ? 'Available online'
                          : (job.mode == JobMode.either ? 'Online or in-person' : 'Not available online'),
                    ),
                    _DetailRow(
                      icon: Icons.home_outlined,
                      text: job.mode != JobMode.online
                          ? 'Available for home tutoring'
                          : 'Online only — no home tutoring',
                    ),
                    _DetailRow(
                      icon: job.canTravel ? Icons.directions_car : Icons.no_transfer,
                      text: job.canTravel ? 'Can travel' : 'Cannot travel',
                    ),
                    _DetailRow(
                      icon: Icons.payments_outlined,
                      text: job.formatBudget(),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Description', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Card(
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.cardBorder),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(job.description ?? 'No description.'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _date(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _maskedPoster(BuildContext context) {
    final user = context.read<AuthBloc>().state.user;
    return user?.displayName ?? 'You';
  }
}

class _ClosedBanner extends StatelessWidget {
  const _ClosedBanner();

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
      child: Row(children: const [
        Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 20),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'This requirement is closed.',
            style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w600),
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
