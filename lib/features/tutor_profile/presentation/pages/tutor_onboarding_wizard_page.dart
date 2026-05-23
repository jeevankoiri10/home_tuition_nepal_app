import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
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
import '../widgets/draft_banner.dart';
import '../widgets/subjects_offered_editor.dart';
import '../widgets/teaching_mode_selector.dart';

const _kCommonLanguages = ['English', 'Nepali', 'Hindi', 'Newari', 'Maithili', 'Bhojpuri'];

class TutorOnboardingWizardPage extends StatefulWidget {
  const TutorOnboardingWizardPage({super.key});

  @override
  State<TutorOnboardingWizardPage> createState() => _TutorOnboardingWizardPageState();
}

class _TutorOnboardingWizardPageState extends State<TutorOnboardingWizardPage> {
  final _controller = PageController();
  int _index = 0;

  static const _stepLabels = [
    'Identity',
    'Teaching mode',
    'Where you teach',
    'Levels you teach',
    'Subjects & prices',
    'About you',
    'Availability',
  ];

  void _next(int total) {
    if (_index < total - 1) {
      setState(() => _index++);
      _controller.animateToPage(_index, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      // Last step — finish onboarding and return to tutor home.
      context.go(AppRoutes.tutorHome);
    }
  }

  void _prev() {
    if (_index == 0) return;
    setState(() => _index--);
    _controller.animateToPage(_index, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TutorProfileBloc, TutorProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        if (state.status == TutorProfileStatus.loading || profile == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Tutor onboarding — ${_index + 1}/${_stepLabels.length}'),
            leading: _index == 0 ? null : IconButton(icon: const Icon(Icons.arrow_back), onPressed: _prev),
          ),
          body: Column(
            children: [
              LinearProgressIndicator(value: (_index + 1) / _stepLabels.length, minHeight: 4),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _index = i),
                  children: [
                    _IdentityStep(profile: profile),
                    _TeachingModeStep(profile: profile),
                    _ServiceAreaStep(profile: profile),
                    _LevelsStep(profile: profile),
                    _SubjectsStep(profile: profile),
                    _AboutStep(profile: profile),
                    _AvailabilityStep(profile: profile),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    if (_index > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _prev,
                          child: const Text('Back'),
                        ),
                      ),
                    if (_index > 0) const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        label: _index == _stepLabels.length - 1 ? 'Finish' : 'Continue',
                        onPressed: () => _next(_stepLabels.length),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Step 1: Identity (placeholder — Phase 2 form already captured first/last
// name; the wizard can later collect avatar + gender + DOB). For now this step
// just confirms identity and shows the draft banner. ───────────────────────────

class _IdentityStep extends StatelessWidget {
  const _IdentityStep({required this.profile});
  final TutorProfile profile;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        DraftBanner(completion: profile.profileCompletion, isPublished: profile.isPublished),
        const SectionCard(
          title: 'Identity',
          subtitle: 'Your name and contact were captured at registration. '
              'Add a photo and demographic details from Profile Settings later — they\'re optional now.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ─── Step 2: Teaching mode ────────────────────────────────────────────────────

class _TeachingModeStep extends StatelessWidget {
  const _TeachingModeStep({required this.profile});
  final TutorProfile profile;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TutorProfileBloc>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        DraftBanner(completion: profile.profileCompletion, isPublished: profile.isPublished),
        SectionCard(
          title: 'How do you teach?',
          subtitle: 'Online-only tutors are not pinned on the map — they still appear in search.',
          child: TeachingModeSelector(
            value: profile.teachingMode,
            onChanged: (m) => bloc.add(TutorProfileDraftUpdated(profile.copyWith(teachingMode: m))),
          ),
        ),
      ],
    );
  }
}

// ─── Step 3: Service area — only if mode is offline or both ───────────────────

class _ServiceAreaStep extends StatelessWidget {
  const _ServiceAreaStep({required this.profile});
  final TutorProfile profile;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TutorProfileBloc>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        DraftBanner(completion: profile.profileCompletion, isPublished: profile.isPublished),
        if (profile.teachingMode == TeachingMode.online)
          const SectionCard(
            title: 'Online-only — no service area needed',
            subtitle: 'You teach online. Skip this step.',
            child: SizedBox.shrink(),
          )
        else
          SectionCard(
            title: 'Where do you teach?',
            subtitle: 'Used to match students near you. The exact address is private.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: profile.city,
                  decoration: const InputDecoration(labelText: 'City'),
                  onChanged: (v) => bloc.add(TutorProfileDraftUpdated(profile.copyWith(city: v))),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  initialValue: profile.addressLine,
                  decoration: const InputDecoration(labelText: 'Area / chowk (e.g., Baneshwor)'),
                  onChanged: (v) => bloc.add(TutorProfileDraftUpdated(profile.copyWith(addressLine: v))),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Travel radius: ${profile.serviceRadiusKm.toStringAsFixed(0)} km'),
                Slider(
                  value: profile.serviceRadiusKm.toDouble(),
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: '${profile.serviceRadiusKm.toStringAsFixed(0)} km',
                  onChanged: (v) =>
                      bloc.add(TutorProfileDraftUpdated(profile.copyWith(serviceRadiusKm: v))),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Step 4: Levels you teach ─────────────────────────────────────────────────

class _LevelsStep extends StatelessWidget {
  const _LevelsStep({required this.profile});
  final TutorProfile profile;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TutorProfileBloc>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        DraftBanner(completion: profile.profileCompletion, isPublished: profile.isPublished),
        SectionCard(
          title: 'Which student levels can you teach?',
          subtitle: 'Pick all that apply. Students filter the map by their own level.',
          child: ChipMultiSelect<StudentLevel>(
            options: StudentLevel.values,
            selected: profile.levelsTaught,
            labelOf: (l) => l.label,
            onChanged: (set) {
              // Drop offerings whose level is no longer selected.
              final keptOfferings = profile.offerings.where((o) => set.contains(o.level)).toList();
              bloc.add(TutorProfileDraftUpdated(
                profile.copyWith(levelsTaught: set, offerings: keptOfferings),
              ));
            },
          ),
        ),
      ],
    );
  }
}

// ─── Step 5: Subjects & prices ────────────────────────────────────────────────

class _SubjectsStep extends StatelessWidget {
  const _SubjectsStep({required this.profile});
  final TutorProfile profile;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TutorProfileBloc>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        DraftBanner(completion: profile.profileCompletion, isPublished: profile.isPublished),
        SectionCard(
          title: 'Subjects offered',
          subtitle:
              'For each level you teach, add the subjects and the price (per hour, day, month, or session). '
              'The lowest price across your offerings is shown as the "from" rate on tutor cards.',
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

// ─── Step 6: About sections ───────────────────────────────────────────────────

class _AboutStep extends StatefulWidget {
  const _AboutStep({required this.profile});
  final TutorProfile profile;

  @override
  State<_AboutStep> createState() => _AboutStepState();
}

class _AboutStepState extends State<_AboutStep> {
  late final _aboutMe = TextEditingController(text: widget.profile.aboutMe ?? '');
  late final _aboutSessions = TextEditingController(text: widget.profile.aboutSessions ?? '');
  late final _qualifications = TextEditingController(text: widget.profile.qualifications ?? '');

  @override
  void dispose() {
    _aboutMe.dispose();
    _aboutSessions.dispose();
    _qualifications.dispose();
    super.dispose();
  }

  String? _violationMessage(String text) =>
      PhoneBanRegex.isViolation(text) ? 'Remove phone numbers or contact details.' : null;

  void _emit() {
    context.read<TutorProfileBloc>().add(TutorProfileDraftUpdated(widget.profile.copyWith(
          aboutMe: _aboutMe.text,
          aboutSessions: _aboutSessions.text,
          qualifications: _qualifications.text,
        )));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TutorProfileBloc>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        DraftBanner(completion: widget.profile.profileCompletion, isPublished: widget.profile.isPublished),
        const PhoneBanWarning(
          message:
              'Do not include phone numbers, WhatsApp links, or email addresses. Accounts that do will be blocked.',
        ),
        SectionCard(
          title: 'About me',
          child: _aboutField(_aboutMe, 'A short bio (min 100 chars for completion)'),
        ),
        SectionCard(
          title: 'About my sessions',
          child: _aboutField(_aboutSessions, 'How you teach (min 50 chars)'),
        ),
        SectionCard(
          title: 'Qualifications',
          child: _aboutField(_qualifications, 'Degrees, certifications (min 30 chars)'),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final lang in _kCommonLanguages)
              FilterChip(
                label: Text(lang),
                selected: widget.profile.languagesKnown.contains(lang),
                onSelected: (yes) {
                  final next = List<String>.from(widget.profile.languagesKnown);
                  if (yes) {
                    next.add(lang);
                  } else {
                    next.remove(lang);
                  }
                  bloc.add(TutorProfileDraftUpdated(
                      widget.profile.copyWith(languagesKnown: next)));
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _aboutField(TextEditingController c, String hint) {
    return TextFormField(
      controller: c,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: hint,
        errorText: _violationMessage(c.text),
      ),
      onChanged: (_) {
        setState(() {}); // re-render to show / clear the error text
        _emit();
      },
    );
  }
}

// ─── Step 7: Availability ─────────────────────────────────────────────────────

class _AvailabilityStep extends StatelessWidget {
  const _AvailabilityStep({required this.profile});
  final TutorProfile profile;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TutorProfileBloc>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        DraftBanner(completion: profile.profileCompletion, isPublished: profile.isPublished),
        SectionCard(
          title: 'When are you available?',
          subtitle:
              'Tap a cell to toggle. Tap a row label (e.g., "Pre 10 am") to toggle the whole row.',
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
