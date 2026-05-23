import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/phone_ban_regex.dart';
import '../../../../core/widgets/chip_multi_select.dart';
import '../../../../core/widgets/phone_ban_warning.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain/models/profile_enums.dart';
import '../../domain/models/tutor_profile.dart';
import '../blocs/tutor_profile_bloc.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Profile settings')),
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
                  child: Text('Auto-saved',
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: PrimaryButton(
                  label: profile.isPublishable ? 'Save & Publish' : 'Save changes',
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

  static const _items = {
    _Tab.personal: 'Personal',
    _Tab.education: 'Education',
    _Tab.subjects: 'Subjects',
    _Tab.availability: 'Availability',
    _Tab.verification: 'Verification',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          for (final entry in _items.entries)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(entry.value),
                selected: active == entry.key,
                onSelected: (_) => onChanged(entry.key),
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

  String? _violation(String text) =>
      PhoneBanRegex.isViolation(text) ? 'Remove phone numbers or contact details.' : null;

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final bloc = context.read<TutorProfileBloc>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SectionCard(
          title: 'Tagline',
          subtitle: 'A one-line headline shown on your card.',
          child: TextField(controller: _tagline, onChanged: (_) => _emit()),
        ),
        SectionCard(
          title: 'Teaching mode',
          child: TeachingModeSelector(
            value: p.teachingMode,
            onChanged: (m) => bloc.add(TutorProfileDraftUpdated(p.copyWith(teachingMode: m))),
          ),
        ),
        SectionCard(
          title: 'Address',
          subtitle: 'The full address is private. Only the area name is shown publicly.',
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextField(controller: _city, decoration: const InputDecoration(labelText: 'City'), onChanged: (_) => _emit()),
            const SizedBox(height: AppSpacing.sm),
            TextField(controller: _addr, decoration: const InputDecoration(labelText: 'Area / chowk'), onChanged: (_) => _emit()),
          ]),
        ),
        SectionCard(
          title: 'Languages I know',
          child: ChipMultiSelect<String>(
            options: _kCommonLanguages,
            selected: p.languagesKnown.toSet(),
            labelOf: (s) => s,
            onChanged: (set) =>
                bloc.add(TutorProfileDraftUpdated(p.copyWith(languagesKnown: set.toList()))),
          ),
        ),
        const PhoneBanWarning(
          message:
              'Do not include phone numbers, WhatsApp links, or email addresses in the bio fields. Accounts that do will be blocked.',
        ),
        SectionCard(
          title: 'About me',
          child: TextFormField(
            controller: _aboutMe,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'A short bio',
              errorText: _violation(_aboutMe.text),
            ),
            onChanged: (_) {
              setState(() {});
              _emit();
            },
          ),
        ),
        SectionCard(
          title: 'About my sessions',
          child: TextFormField(
            controller: _aboutSessions,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'How you teach',
              errorText: _violation(_aboutSessions.text),
            ),
            onChanged: (_) {
              setState(() {});
              _emit();
            },
          ),
        ),
        SectionCard(
          title: 'Qualifications',
          child: TextFormField(
            controller: _qualifications,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Degrees, certifications',
              errorText: _violation(_qualifications.text),
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
    final bloc = context.read<TutorProfileBloc>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SectionCard(
          title: 'Education',
          subtitle: 'Optional. Degrees, schools, fields of study.',
          child: EducationEditor(
            items: profile.education,
            onChanged: (list) =>
                bloc.add(TutorProfileDraftUpdated(profile.copyWith(education: list))),
          ),
        ),
        SectionCard(
          title: 'Experience',
          subtitle: 'Optional. Past teaching or work roles.',
          child: ExperienceEditor(
            items: profile.experience,
            onChanged: (list) =>
                bloc.add(TutorProfileDraftUpdated(profile.copyWith(experience: list))),
          ),
        ),
        SectionCard(
          title: 'Certificates & Awards',
          subtitle: 'Optional. Boosts the verified-badge review.',
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
    final bloc = context.read<TutorProfileBloc>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SectionCard(
          title: 'Levels you teach',
          child: ChipMultiSelect<StudentLevel>(
            options: StudentLevel.values,
            selected: profile.levelsTaught,
            labelOf: (l) => l.label,
            onChanged: (set) {
              final kept = profile.offerings.where((o) => set.contains(o.level)).toList();
              bloc.add(TutorProfileDraftUpdated(
                profile.copyWith(levelsTaught: set, offerings: kept),
              ));
            },
          ),
        ),
        SectionCard(
          title: 'Subjects offered',
          subtitle: 'For each level, list the subjects and prices.',
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
    final bloc = context.read<TutorProfileBloc>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SectionCard(
          title: 'Weekly availability',
          subtitle: 'Tap a cell to toggle. Row labels toggle the entire row.',
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
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SectionCard(
          title: 'Citizenship',
          subtitle: 'Upload front + back. Stored in a private Supabase Storage bucket; '
              'only the admin can view it.',
          child: OutlinedButton.icon(
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Upload citizenship'),
            onPressed: () => _uploadStub(context, 'citizenship'),
          ),
        ),
        SectionCard(
          title: 'Selfie holding citizenship',
          subtitle: 'Anti-spoof check used by the admin during verification.',
          child: OutlinedButton.icon(
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Upload selfie'),
            onPressed: () => _uploadStub(context, 'selfie'),
          ),
        ),
        const SectionCard(
          title: 'Status',
          subtitle: 'Not started — submit your documents to begin review.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }

  void _uploadStub(BuildContext context, String kind) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$kind upload UI wires to Supabase Storage when buckets are configured.')),
    );
  }
}
