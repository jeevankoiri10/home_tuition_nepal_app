import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/phone_ban_regex.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/chip_multi_select.dart';
import '../../../../core/widgets/phone_ban_warning.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../tutor_profile/domain/models/profile_enums.dart';
import '../../domain/models/request_enums.dart';
import '../../domain/models/vacancy_request.dart';
import '../blocs/student_requests_bloc.dart';

const _kCommonSubjects = ['Maths', 'Science', 'English', 'Nepali', 'Computer', 'Social', 'Accountancy'];

class RequestTutorPage extends StatefulWidget {
  const RequestTutorPage({super.key});

  @override
  State<RequestTutorPage> createState() => _RequestTutorPageState();
}

class _RequestTutorPageState extends State<RequestTutorPage> {
  final _formKey = GlobalKey<FormState>();
  final _details = TextEditingController();
  final _location = TextEditingController();
  final _duration = TextEditingController();
  final _salaryMin = TextEditingController();
  final _salaryMax = TextEditingController();
  StudentLevel _level = StudentLevel.see;
  GenderPref _gender = GenderPref.any;
  JobMode _mode = JobMode.inPerson;
  Set<String> _subjects = {};

  @override
  void dispose() {
    _details.dispose();
    _location.dispose();
    _duration.dispose();
    _salaryMin.dispose();
    _salaryMax.dispose();
    super.dispose();
  }

  String? _validateText(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _validateLocation(String? v) {
    final required = _validateText(v);
    if (required != null) return required;
    return null;
  }

  String? _validateNoPhone(String? v) {
    if (v == null) return null;
    return PhoneBanRegex.isViolation(v) ? 'Remove phone numbers or contact details.' : null;
  }

  void _submit() {
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;
    if (!_formKey.currentState!.validate()) return;
    if (_subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick at least one subject.')),
      );
      return;
    }

    final vacancy = VacancyRequest(
      linkedStudent: user.id,
      title: 'Tutor needed in ${_location.text.trim()}',
      areaLabel: _location.text.trim(),
      grade: _level.label,
      subjects: _subjects.toList(),
      durationText: _duration.text.trim().isEmpty ? null : _duration.text.trim(),
      salaryMinNpr: num.tryParse(_salaryMin.text.trim()),
      salaryMaxNpr: num.tryParse(_salaryMax.text.trim()),
      genderPref: _gender,
      mode: _mode,
      notes: _details.text.trim(),
    );

    context.read<StudentRequestsBloc>().add(StudentVacancyRequested(vacancy));
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
        // Pop back when the submission lands.
        if (state.status == StudentRequestsStatus.ready &&
            state.vacancies.isNotEmpty &&
            state.vacancies.first.status == VacancyStatus.pendingAdminReview &&
            (DateTime.now().difference(state.vacancies.first.createdAt ?? DateTime.now()))
                    .inSeconds <
                3) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Request sent. Admin will review and publish soon.')));
          context.pop();
        }
      },
      builder: (context, state) {
        final busy = state.status == StudentRequestsStatus.submitting;
        return Scaffold(
          appBar: AppBar(title: const Text('Request a Tutor')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionCard(
                    title: 'Details of your requirement',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _details,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText:
                                'Hi,\nI need maths and Hindi tutors online.',
                          ),
                          validator: _validateNoPhone,
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
                    title: 'Location',
                    child: AppTextField(
                      label: 'Area / chowk',
                      controller: _location,
                      prefixIcon: Icons.place_outlined,
                      validator: _validateLocation,
                    ),
                  ),
                  SectionCard(
                    title: 'Subjects',
                    child: ChipMultiSelect<String>(
                      options: _kCommonSubjects,
                      selected: _subjects,
                      labelOf: (s) => s,
                      onChanged: (s) => setState(() => _subjects = s),
                    ),
                  ),
                  SectionCard(
                    title: 'Your Level',
                    child: DropdownButtonFormField<StudentLevel>(
                      initialValue: _level,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      items: [
                        for (final l in StudentLevel.values)
                          DropdownMenuItem(value: l, child: Text(l.label)),
                      ],
                      onChanged: (v) => setState(() => _level = v ?? _level),
                    ),
                  ),
                  SectionCard(
                    title: 'Preferences',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          label: 'Duration / preferred time (e.g., 5pm–6pm)',
                          controller: _duration,
                        ),
                        Row(children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Min salary (NPR)',
                              controller: _salaryMin,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AppTextField(
                              label: 'Max salary (NPR)',
                              controller: _salaryMax,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ]),
                        DropdownButtonFormField<GenderPref>(
                          initialValue: _gender,
                          decoration:
                              const InputDecoration(labelText: 'Gender preference'),
                          items: [
                            for (final g in GenderPref.values)
                              DropdownMenuItem(value: g, child: Text(g.label)),
                          ],
                          onChanged: (v) => setState(() => _gender = v ?? _gender),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        DropdownButtonFormField<JobMode>(
                          initialValue: _mode,
                          decoration: const InputDecoration(labelText: 'Mode'),
                          items: [
                            for (final m in JobMode.values)
                              DropdownMenuItem(value: m, child: Text(m.label)),
                          ],
                          onChanged: (v) => setState(() => _mode = v ?? _mode),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: busy ? 'Sending…' : 'Send request to admin',
                    busy: busy,
                    onPressed: busy ? null : _submit,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Admin reviews your request, assigns an HTN-NNNNN code, and notifies matching tutors. You\'ll get a push when it\'s live.',
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
