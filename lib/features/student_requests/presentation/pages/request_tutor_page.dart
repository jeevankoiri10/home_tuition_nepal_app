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
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../tutor_profile/domain/models/profile_enums.dart';
import '../../../tutor_profile/presentation/enum_labels.dart';
import '../../domain/models/request_enums.dart';
import '../../domain/models/vacancy_request.dart';
import '../blocs/student_requests_bloc.dart';
import '../enum_labels.dart';

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
  final _customSubject = TextEditingController();
  StudentLevel _level = StudentLevel.see;
  GenderPref _gender = GenderPref.any;
  JobMode _mode = JobMode.inPerson;
  Set<String> _subjects = {};
  // Subjects typed in by the user. Merged with [_kCommonSubjects] when the
  // chip selector renders so they can be toggled on/off like the rest.
  final List<String> _customSubjects = [];

  @override
  void dispose() {
    _details.dispose();
    _location.dispose();
    _duration.dispose();
    _salaryMin.dispose();
    _salaryMax.dispose();
    _customSubject.dispose();
    super.dispose();
  }

  void _addCustomSubject() {
    final l10n = AppLocalizations.of(context);
    final raw = _customSubject.text.trim();
    if (raw.isEmpty) return;
    if (PhoneBanRegex.isViolation(raw)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.phoneInTextValidation)),
      );
      return;
    }
    final exists = _kCommonSubjects.any((s) => s.toLowerCase() == raw.toLowerCase()) ||
        _customSubjects.any((s) => s.toLowerCase() == raw.toLowerCase());
    if (exists) {
      // Already in the list — just make sure it's selected.
      final match = [..._kCommonSubjects, ..._customSubjects]
          .firstWhere((s) => s.toLowerCase() == raw.toLowerCase());
      setState(() {
        _subjects = {..._subjects, match};
        _customSubject.clear();
      });
      return;
    }
    setState(() {
      _customSubjects.add(raw);
      _subjects = {..._subjects, raw};
      _customSubject.clear();
    });
  }

  String? _validateText(AppLocalizations l10n, String? v) =>
      (v == null || v.trim().isEmpty) ? l10n.requiredField : null;

  String? _validateNoPhone(AppLocalizations l10n, String? v) {
    if (v == null) return null;
    return PhoneBanRegex.isViolation(v) ? l10n.phoneInTextValidation : null;
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;
    if (!_formKey.currentState!.validate()) return;
    if (_subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.requestSubjectsRequired)),
      );
      return;
    }

    final vacancy = VacancyRequest(
      linkedStudent: user.id,
      // The vacancy title and grade are stored server-side; keep the English
      // label so admins/exports see a stable string. The user sees the
      // localised version through the UI.
      title: l10n.requestTitlePrefix(_location.text.trim()),
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
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.requestSuccessSnack)),
          );
          context.pop();
        }
      },
      builder: (context, state) {
        final l10n = AppLocalizations.of(context);
        final busy = state.status == StudentRequestsStatus.submitting;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.requestTutorCta)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionCard(
                    title: l10n.requestSectionDetails,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _details,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: l10n.requestDetailsHint,
                          ),
                          validator: (v) => _validateNoPhone(l10n, v),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        PhoneBanWarning(message: l10n.phoneBanFormHint),
                      ],
                    ),
                  ),
                  SectionCard(
                    title: l10n.requestSectionLocation,
                    child: AppTextField(
                      label: l10n.postJobAreaLabel,
                      controller: _location,
                      prefixIcon: Icons.place_outlined,
                      validator: (v) => _validateText(l10n, v),
                    ),
                  ),
                  SectionCard(
                    title: l10n.requestSectionSubjects,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ChipMultiSelect<String>(
                          options: [..._kCommonSubjects, ..._customSubjects],
                          selected: _subjects,
                          labelOf: (s) => s,
                          onChanged: (s) => setState(() => _subjects = s),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _customSubject,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  hintText: l10n.requestSubjectsCustomHint,
                                  prefixIcon: const Icon(Icons.add_outlined),
                                ),
                                onSubmitted: (_) => _addCustomSubject(),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            FilledButton.tonal(
                              onPressed: _addCustomSubject,
                              child: Text(l10n.requestSubjectsCustomAdd),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SectionCard(
                    title: l10n.requestSectionLevel,
                    child: DropdownButtonFormField<StudentLevel>(
                      initialValue: _level,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      items: [
                        for (final lvl in StudentLevel.values)
                          DropdownMenuItem(value: lvl, child: Text(lvl.localized(l10n))),
                      ],
                      onChanged: (v) => setState(() => _level = v ?? _level),
                    ),
                  ),
                  SectionCard(
                    title: l10n.postJobSectionPreferences,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          label: l10n.requestDurationLabel,
                          controller: _duration,
                        ),
                        Row(children: [
                          Expanded(
                            child: AppTextField(
                              label: l10n.requestMinSalaryLabel,
                              controller: _salaryMin,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AppTextField(
                              label: l10n.requestMaxSalaryLabel,
                              controller: _salaryMax,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ]),
                        DropdownButtonFormField<GenderPref>(
                          initialValue: _gender,
                          decoration: InputDecoration(labelText: l10n.requestGenderLabel),
                          items: [
                            for (final g in GenderPref.values)
                              DropdownMenuItem(value: g, child: Text(g.localized(l10n))),
                          ],
                          onChanged: (v) => setState(() => _gender = v ?? _gender),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        DropdownButtonFormField<JobMode>(
                          initialValue: _mode,
                          decoration: InputDecoration(labelText: l10n.postJobModeLabel),
                          items: [
                            for (final m in JobMode.values)
                              DropdownMenuItem(value: m, child: Text(m.localized(l10n))),
                          ],
                          onChanged: (v) => setState(() => _mode = v ?? _mode),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: busy ? l10n.applySending : l10n.requestSubmit,
                    busy: busy,
                    onPressed: busy ? null : _submit,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.requestFooter,
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
}
