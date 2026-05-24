import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/phone_ban_regex.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/phone_ban_warning.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../domain/models/job_post.dart';
import '../../domain/models/request_enums.dart';
import '../blocs/student_requests_bloc.dart';
import '../enum_labels.dart';

class PostJobPage extends StatefulWidget {
  const PostJobPage({super.key});

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _subject = TextEditingController();
  final _grade = TextEditingController();
  final _area = TextEditingController();
  final _schedule = TextEditingController();
  final _budgetMin = TextEditingController();
  final _budgetMax = TextEditingController();
  JobType _type = JobType.homeTuition;
  JobMode _mode = JobMode.inPerson;
  GenderPref _gender = GenderPref.any;
  BudgetPeriod _period = BudgetPeriod.month;
  EngagementType? _engagement;
  DateTime? _due;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _subject.dispose();
    _grade.dispose();
    _area.dispose();
    _schedule.dispose();
    _budgetMin.dispose();
    _budgetMax.dispose();
    super.dispose();
  }

  String? _required(AppLocalizations l10n, String? v) =>
      (v == null || v.trim().isEmpty) ? l10n.requiredField : null;

  String? _noPhone(AppLocalizations l10n, String? v) {
    if (v == null) return null;
    return PhoneBanRegex.isViolation(v) ? l10n.phoneInTextValidation : null;
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _due = picked);
  }

  void _submit() {
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;
    if (!_formKey.currentState!.validate()) return;

    final job = JobPost(
      studentId: user.id,
      title: _title.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      jobType: _type,
      subject: _subject.text.trim().isEmpty ? null : _subject.text.trim(),
      gradeLevel: _grade.text.trim().isEmpty ? null : _grade.text.trim(),
      areaLabel: _area.text.trim().isEmpty ? null : _area.text.trim(),
      schedule: _schedule.text.trim().isEmpty ? null : _schedule.text.trim(),
      budgetMinNpr: num.tryParse(_budgetMin.text.trim()),
      budgetMaxNpr: num.tryParse(_budgetMax.text.trim()),
      budgetPeriod: _period,
      mode: _mode,
      genderPref: _gender,
      engagementType: _engagement,
      dueDate: _type == JobType.assignmentHelp ? _due : null,
    );

    context.read<StudentRequestsBloc>().add(StudentJobSubmitted(job));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<StudentRequestsBloc, StudentRequestsState>(
      listener: (context, state) {
        if (state.status == StudentRequestsStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
        if (state.status == StudentRequestsStatus.ready &&
            state.jobs.isNotEmpty &&
            (DateTime.now().difference(state.jobs.first.createdAt ?? DateTime.now())).inSeconds < 3) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.postJobSuccessSnack)));
          context.pop();
        }
      },
      builder: (context, state) {
        final busy = state.status == StudentRequestsStatus.submitting;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.postJobAppBar)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionCard(
                    title: l10n.postJobSectionType,
                    child: SegmentedButton<JobType>(
                      segments: [
                        ButtonSegment(
                            value: JobType.homeTuition,
                            label: Text(l10n.postJobTypeHome),
                            icon: const Icon(Icons.home_outlined)),
                        ButtonSegment(
                            value: JobType.onlineTuition,
                            label: Text(l10n.postJobTypeOnline),
                            icon: const Icon(Icons.computer_outlined)),
                        ButtonSegment(
                            value: JobType.assignmentHelp,
                            label: Text(l10n.postJobTypeAssignment),
                            icon: const Icon(Icons.assignment_outlined)),
                      ],
                      selected: {_type},
                      onSelectionChanged: (s) => setState(() => _type = s.first),
                    ),
                  ),
                  SectionCard(
                    title: l10n.postJobSectionTitle,
                    child: AppTextField(
                      label: l10n.postJobTitleHint,
                      controller: _title,
                      validator: (v) => _required(l10n, v),
                    ),
                  ),
                  SectionCard(
                    title: l10n.postJobSectionDescription,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _description,
                          maxLines: 4,
                          decoration:
                              InputDecoration(hintText: l10n.postJobDescriptionHint),
                          validator: (v) => _noPhone(l10n, v),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        PhoneBanWarning(message: l10n.phoneBanFormHint),
                      ],
                    ),
                  ),
                  SectionCard(
                    title: l10n.postJobSectionWhereWhen,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      AppTextField(label: l10n.postJobSubjectLabel, controller: _subject),
                      AppTextField(label: l10n.postJobGradeLabel, controller: _grade),
                      AppTextField(
                          label: l10n.postJobAreaLabel,
                          controller: _area,
                          prefixIcon: Icons.place_outlined),
                      AppTextField(
                          label: l10n.postJobScheduleLabel,
                          controller: _schedule),
                      if (_type == JobType.assignmentHelp)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.calendar_today_outlined),
                          title: Text(_due == null
                              ? l10n.postJobDueDatePick
                              : l10n.postJobDueOnPrefix(_formatDate(context, _due!))),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _pickDueDate,
                        ),
                    ]),
                  ),
                  SectionCard(
                    title: l10n.postJobSectionBudget,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Row(children: [
                        Expanded(
                            child: AppTextField(
                                label: l10n.postJobBudgetMinLabel,
                                controller: _budgetMin,
                                keyboardType: TextInputType.number)),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                            child: AppTextField(
                                label: l10n.postJobBudgetMaxLabel,
                                controller: _budgetMax,
                                keyboardType: TextInputType.number)),
                      ]),
                      DropdownButtonFormField<BudgetPeriod>(
                        initialValue: _period,
                        decoration: InputDecoration(labelText: l10n.postJobPeriodLabel),
                        items: [
                          for (final p in BudgetPeriod.values)
                            DropdownMenuItem(value: p, child: Text(p.localized(l10n))),
                        ],
                        onChanged: (v) => setState(() => _period = v ?? _period),
                      ),
                    ]),
                  ),
                  SectionCard(
                    title: l10n.postJobSectionPreferences,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      DropdownButtonFormField<JobMode>(
                        initialValue: _mode,
                        decoration: InputDecoration(labelText: l10n.postJobModeLabel),
                        items: [
                          for (final m in JobMode.values)
                            DropdownMenuItem(value: m, child: Text(m.localized(l10n))),
                        ],
                        onChanged: (v) => setState(() => _mode = v ?? _mode),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<GenderPref>(
                        initialValue: _gender,
                        decoration: InputDecoration(labelText: l10n.postJobTutorGenderLabel),
                        items: [
                          for (final g in GenderPref.values)
                            DropdownMenuItem(value: g, child: Text(g.localized(l10n))),
                        ],
                        onChanged: (v) => setState(() => _gender = v ?? _gender),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<EngagementType?>(
                        initialValue: _engagement,
                        decoration:
                            InputDecoration(labelText: l10n.postJobEngagementLabel),
                        items: [
                          DropdownMenuItem<EngagementType?>(
                              value: null, child: Text(l10n.postJobEngagementAny)),
                          for (final e in EngagementType.values)
                            DropdownMenuItem(value: e, child: Text(e.localized(l10n))),
                        ],
                        onChanged: (v) => setState(() => _engagement = v),
                      ),
                    ]),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: busy ? l10n.postJobPostingEllipsis : l10n.postJobSubmit,
                    busy: busy,
                    onPressed: busy ? null : _submit,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.postJobFooter,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(BuildContext context, DateTime d) {
    // Reuse the locale's short date — yMMMd gives "Jan 15, 2026" / "जन ५, २०२६".
    return MaterialLocalizations.of(context).formatShortDate(d);
  }
}
