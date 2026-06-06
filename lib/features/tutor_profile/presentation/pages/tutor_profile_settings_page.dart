import 'package:flutter/material.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/phone_ban_regex.dart';
import '../../../../core/widgets/chip_multi_select.dart';
import '../../../../core/widgets/phone_ban_warning.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/profile_enums.dart';
import '../../domain/models/tutor_profile.dart';
import '../blocs/tutor_profile_bloc.dart';
import '../enum_labels.dart';
import '../widgets/availability_grid.dart';
import '../widgets/credentials_section.dart';
import '../widgets/draft_banner.dart';
import '../widgets/subjects_offered_editor.dart';
import '../widgets/teaching_mode_selector.dart';

const _kCommonLanguages = ['English', 'Nepali', 'Hindi', 'Newari', 'Maithili', 'Bhojpuri'];

enum _Tab { personal, education, subjects, availability, verification }

class TutorProfileSettingsPage extends StatefulWidget {
  const TutorProfileSettingsPage({super.key});

  @override
  State<TutorProfileSettingsPage> createState() => _TutorProfileSettingsPageState();
}

class _TutorProfileSettingsPageState extends State<TutorProfileSettingsPage> {
  _Tab _active = _Tab.personal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: BrandAppBar(title: Text(l10n.settingsAppBarTitle)),
      body: BlocBuilder<TutorProfileBloc, TutorProfileState>(
        builder: (context, state) {
          final profile = state.profile;
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                child: DraftBanner(
                  completion: profile.profileCompletion,
                  isPublished: profile.isPublished,
                ),
              ),
              _TabBar(active: _active, onChanged: (t) => setState(() => _active = t)),
              Expanded(
                child: _tabView(profile),
              ),
              if (state.lastSavedAt != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(l10n.autoSavedLabel,
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: PrimaryButton(
                  label: profile.isPublishable ? l10n.saveAndPublishCta : l10n.saveChangesCta,
                  busy: state.status == TutorProfileStatus.saving,
                  onPressed: state.status == TutorProfileStatus.saving
                      ? null
                      : () {
                          context.read<TutorProfileBloc>().add(
                                profile.isPublishable
                                    ? const TutorProfilePublishRequested()
                                    : const TutorProfileSaveRequested(),
                              );
                        },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tabView(TutorProfile profile) {
    switch (_active) {
      case _Tab.personal:
        return _PersonalDetailsTab(profile: profile);
      case _Tab.education:
        return _EducationTab(profile: profile);
      case _Tab.subjects:
        return _SubjectsTab(profile: profile);
      case _Tab.availability:
        return _AvailabilityTab(profile: profile);
      case _Tab.verification:
        return const _VerificationTab();
    }
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.active, required this.onChanged});
  final _Tab active;
  final ValueChanged<_Tab> onChanged;

  String _labelFor(AppLocalizations l10n, _Tab tab) {
    switch (tab) {
      case _Tab.personal:
        return l10n.settingsTabPersonal;
      case _Tab.education:
        return l10n.settingsTabEducation;
      case _Tab.subjects:
        return l10n.settingsTabSubjects;
      case _Tab.availability:
        return l10n.settingsTabAvailability;
      case _Tab.verification:
        return l10n.settingsTabVerification;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          for (final tab in _Tab.values)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(_labelFor(l10n, tab)),
                selected: active == tab,
                onSelected: (_) => onChanged(tab),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Personal details ─────────────────────────────────────────────────────────

class _PersonalDetailsTab extends StatefulWidget {
  const _PersonalDetailsTab({required this.profile});
  final TutorProfile profile;

  @override
  State<_PersonalDetailsTab> createState() => _PersonalDetailsTabState();
}

class _PersonalDetailsTabState extends State<_PersonalDetailsTab> {
  late final _tagline = TextEditingController(text: widget.profile.tagline ?? '');
  late final _aboutMe = TextEditingController(text: widget.profile.aboutMe ?? '');
  late final _aboutSessions = TextEditingController(text: widget.profile.aboutSessions ?? '');
  late final _qualifications = TextEditingController(text: widget.profile.qualifications ?? '');
  late final _city = TextEditingController(text: widget.profile.city ?? '');
  late final _addr = TextEditingController(text: widget.profile.addressLine ?? '');

  @override
  void dispose() {
    _tagline.dispose();
    _aboutMe.dispose();
    _aboutSessions.dispose();
    _qualifications.dispose();
    _city.dispose();
    _addr.dispose();
    super.dispose();
  }

  void _emit() {
    context.read<TutorProfileBloc>().add(TutorProfileDraftUpdated(widget.profile.copyWith(
          tagline: _tagline.text,
          aboutMe: _aboutMe.text,
          aboutSessions: _aboutSessions.text,
          qualifications: _qualifications.text,
          city: _city.text,
          addressLine: _addr.text,
        )));
  }

  String? _violation(AppLocalizations l10n, String text) =>
      PhoneBanRegex.isViolation(text) ? l10n.phoneInTextValidation : null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = widget.profile;
    final bloc = context.read<TutorProfileBloc>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SectionCard(
          title: l10n.taglineLabel,
          subtitle: l10n.taglineSubtitle,
          child: TextField(controller: _tagline, onChanged: (_) => _emit()),
        ),
        SectionCard(
          title: l10n.postJobModeLabel,
          child: TeachingModeSelector(
            value: p.teachingMode,
            onChanged: (m) => bloc.add(TutorProfileDraftUpdated(p.copyWith(teachingMode: m))),
          ),
        ),
        SectionCard(
          title: l10n.settingsAddressTitle,
          subtitle: l10n.settingsAddressSubtitle,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextField(controller: _city, decoration: InputDecoration(labelText: l10n.cityLabel), onChanged: (_) => _emit()),
            const SizedBox(height: AppSpacing.sm),
            TextField(controller: _addr, decoration: InputDecoration(labelText: l10n.areaChowkLabelShort), onChanged: (_) => _emit()),
          ]),
        ),
        SectionCard(
          title: l10n.settingsLanguagesTitle,
          child: ChipMultiSelect<String>(
            options: _kCommonLanguages,
            selected: p.languagesKnown.toSet(),
            labelOf: (s) => s,
            onChanged: (set) =>
                bloc.add(TutorProfileDraftUpdated(p.copyWith(languagesKnown: set.toList()))),
          ),
        ),
        PhoneBanWarning(message: l10n.tutorProfilePhoneBanWarningBio),
        SectionCard(
          title: l10n.aboutMeLabel,
          child: TextFormField(
            controller: _aboutMe,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n.aboutMeHintShort,
              errorText: _violation(l10n, _aboutMe.text),
            ),
            onChanged: (_) {
              setState(() {});
              _emit();
            },
          ),
        ),
        SectionCard(
          title: l10n.aboutSessionsLabel,
          child: TextFormField(
            controller: _aboutSessions,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n.aboutSessionsHintShort,
              errorText: _violation(l10n, _aboutSessions.text),
            ),
            onChanged: (_) {
              setState(() {});
              _emit();
            },
          ),
        ),
        SectionCard(
          title: l10n.qualificationsLabel,
          child: TextFormField(
            controller: _qualifications,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n.qualificationsHintShort,
              errorText: _violation(l10n, _qualifications.text),
            ),
            onChanged: (_) {
              setState(() {});
              _emit();
            },
          ),
        ),
      ],
    );
  }
}

// ─── Education tab (Education / Experience / Certificates — all optional) ─────

class _EducationTab extends StatelessWidget {
  const _EducationTab({required this.profile});
  final TutorProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<TutorProfileBloc>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SectionCard(
          title: l10n.settingsTabEducation,
          subtitle: l10n.settingsEducationSubtitle,
          child: EducationEditor(
            items: profile.education,
            onChanged: (list) =>
                bloc.add(TutorProfileDraftUpdated(profile.copyWith(education: list))),
          ),
        ),
        SectionCard(
          title: l10n.settingsExperienceTitle,
          subtitle: l10n.settingsExperienceSubtitle,
          child: ExperienceEditor(
            items: profile.experience,
            onChanged: (list) =>
                bloc.add(TutorProfileDraftUpdated(profile.copyWith(experience: list))),
          ),
        ),
        SectionCard(
          title: l10n.settingsCertificatesTitle,
          subtitle: l10n.settingsCertificatesSubtitle,
          child: CertificatesEditor(
            items: profile.certificates,
            onChanged: (list) =>
                bloc.add(TutorProfileDraftUpdated(profile.copyWith(certificates: list))),
          ),
        ),
      ],
    );
  }
}

// ─── Subjects ────────────────────────────────────────────────────────────────

class _SubjectsTab extends StatelessWidget {
  const _SubjectsTab({required this.profile});
  final TutorProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<TutorProfileBloc>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SectionCard(
          title: l10n.wizardStepLevelsYouTeach,
          child: ChipMultiSelect<StudentLevel>(
            options: StudentLevel.values,
            selected: profile.levelsTaught,
            labelOf: (l) => l.localized(l10n),
            onChanged: (set) {
              final kept = profile.offerings.where((o) => set.contains(o.level)).toList();
              bloc.add(TutorProfileDraftUpdated(
                profile.copyWith(levelsTaught: set, offerings: kept),
              ));
            },
          ),
        ),
        SectionCard(
          title: l10n.wizardSubjectsTitle,
          subtitle: l10n.settingsSubjectsListedSubtitle,
          child: SubjectsOfferedEditor(
            offerings: profile.offerings,
            allowedLevels: profile.levelsTaught,
            onChanged: (list) =>
                bloc.add(TutorProfileDraftUpdated(profile.copyWith(offerings: list))),
          ),
        ),
      ],
    );
  }
}

// ─── Availability ────────────────────────────────────────────────────────────

class _AvailabilityTab extends StatelessWidget {
  const _AvailabilityTab({required this.profile});
  final TutorProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<TutorProfileBloc>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SectionCard(
          title: l10n.settingsAvailabilityTitle,
          subtitle: l10n.settingsAvailabilitySubtitle,
          child: AvailabilityGrid(
            value: profile.availability,
            onChanged: (a) =>
                bloc.add(TutorProfileDraftUpdated(profile.copyWith(availability: a))),
          ),
        ),
      ],
    );
  }
}

// ─── Identity verification (UI scaffold; storage wiring lands when buckets exist) ─

class _VerificationTab extends StatelessWidget {
  const _VerificationTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SectionCard(
          title: l10n.verifyCitizenshipTitle,
          subtitle: l10n.verifyCitizenshipSubtitle,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(l10n.verifyUploadCitizenship),
            onPressed: () => _uploadStub(context, 'citizenship'),
          ),
        ),
        SectionCard(
          title: l10n.verifySelfieTitle,
          subtitle: l10n.verifySelfieSubtitle,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(l10n.verifyUploadSelfie),
            onPressed: () => _uploadStub(context, 'selfie'),
          ),
        ),
        SectionCard(
          title: l10n.verifyStatusTitle,
          subtitle: l10n.verifyStatusNotStarted,
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _uploadStub(BuildContext context, String kind) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.verifyUploadNotReady(kind))),
    );
  }
}
