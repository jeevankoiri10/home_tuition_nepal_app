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
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../domain/models/job_post.dart';
import '../../domain/models/request_enums.dart';
import '../blocs/student_requests_bloc.dart';

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

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _noPhone(String? v) {
    if (v == null) return null;
    return PhoneBanRegex.isViolation(v) ? 'Remove phone numbers or contact details.' : null;
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
              .showSnackBar(const SnackBar(content: Text('Job posted. Tutors will be notified.')));
          context.pop();
        }
      },
      builder: (context, state) {
        final busy = state.status == StudentRequestsStatus.submitting;
        return Scaffold(
          appBar: AppBar(title: const Text('Post a job')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionCard(
                    title: 'Type of job',
                    child: SegmentedButton<JobType>(
                      segments: const [
                        ButtonSegment(value: JobType.homeTuition, label: Text('Home tuition'), icon: Icon(Icons.home_outlined)),
                        ButtonSegment(value: JobType.onlineTuition, label: Text('Online'), icon: Icon(Icons.computer_outlined)),
                        ButtonSegment(value: JobType.assignmentHelp, label: Text('Assignment'), icon: Icon(Icons.assignment_outlined)),
                      ],
                      selected: {_type},
                      onSelectionChanged: (s) => setState(() => _type = s.first),
                    ),
                  ),
                  SectionCard(
                    title: 'Title',
                    child: AppTextField(
                      label: 'Headline (e.g., Maths tutor needed in Kapan)',
                      controller: _title,
                      validator: _required,
                    ),
                  ),
                  SectionCard(
                    title: 'Description',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _description,
                          maxLines: 4,
                          decoration:
                              const InputDecoration(hintText: 'Describe what you need.'),
                          validator: _noPhone,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const PhoneBanWarning(
                          message:
                              'Please don\'t share any contact details (phone, email, website etc) here.',
                        ),
                      ],
                    ),
                  ),
                  SectionCard(
                    title: 'Where & when',
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      AppTextField(label: 'Subject', controller: _subject),
                      AppTextField(label: 'Grade / Class', controller: _grade),
                      AppTextField(
                          label: 'Area / chowk',
                          controller: _area,
                          prefixIcon: Icons.place_outlined),
                      AppTextField(
                          label: 'Schedule (e.g., evenings, 5–6pm)',
                          controller: _schedule),
                      if (_type == JobType.assignmentHelp)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.calendar_today_outlined),
                          title: Text(_due == null
                              ? 'Due date — pick a date'
                              : 'Due ${_due!.toLocal().toString().split(' ').first}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _pickDueDate,
                        ),
                    ]),
                  ),
                  SectionCard(
                    title: 'Budget',
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Row(children: [
                        Expanded(
                            child: AppTextField(
                                label: 'Min (NPR)',
                                controller: _budgetMin,
                                keyboardType: TextInputType.number)),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                            child: AppTextField(
                                label: 'Max (NPR)',
                                controller: _budgetMax,
                                keyboardType: TextInputType.number)),
                      ]),
                      DropdownButtonFormField<BudgetPeriod>(
                        initialValue: _period,
                        decoration: const InputDecoration(labelText: 'Period'),
                        items: [
                          for (final p in BudgetPeriod.values)
                            DropdownMenuItem(value: p, child: Text(p.suffix.trim())),
                        ],
                        onChanged: (v) => setState(() => _period = v ?? _period),
                      ),
                    ]),
                  ),
                  SectionCard(
                    title: 'Preferences',
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      DropdownButtonFormField<JobMode>(
                        initialValue: _mode,
                        decoration: const InputDecoration(labelText: 'Mode'),
                        items: [
                          for (final m in JobMode.values)
                            DropdownMenuItem(value: m, child: Text(m.label)),
                        ],
                        onChanged: (v) => setState(() => _mode = v ?? _mode),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<GenderPref>(
                        initialValue: _gender,
                        decoration: const InputDecoration(labelText: 'Tutor gender'),
                        items: [
                          for (final g in GenderPref.values)
                            DropdownMenuItem(value: g, child: Text(g.label)),
                        ],
                        onChanged: (v) => setState(() => _gender = v ?? _gender),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<EngagementType?>(
                        initialValue: _engagement,
                        decoration:
                            const InputDecoration(labelText: 'Engagement type'),
                        items: [
                          const DropdownMenuItem<EngagementType?>(
                              value: null, child: Text('Any')),
                          for (final e in EngagementType.values)
                            DropdownMenuItem(value: e, child: Text(e.label)),
                        ],
                        onChanged: (v) => setState(() => _engagement = v),
                      ),
                    ]),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: busy ? 'Posting…' : 'Post job',
                    busy: busy,
                    onPressed: busy ? null : _submit,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Matching tutors are notified automatically. You\'ll see their bids in My Posts.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
}
