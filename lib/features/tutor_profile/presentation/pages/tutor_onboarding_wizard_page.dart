import 'package:flutter/material.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/phone_ban_regex.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/chip_multi_select.dart';
import '../../../../core/widgets/map_pin_picker.dart';
import '../../../../core/widgets/phone_ban_warning.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/domain/auth_repository.dart';
import '../../domain/models/profile_enums.dart';
import '../../domain/models/tutor_profile.dart';
import '../blocs/tutor_profile_bloc.dart';
import '../enum_labels.dart';
import '../widgets/availability_grid.dart';
import '../widgets/cv_upload_card.dart';
import '../widgets/draft_banner.dart';
import '../widgets/subjects_offered_editor.dart';
import '../widgets/teaching_mode_selector.dart';

const _kCommonLanguages = [
  'English',
  'Nepali',
  'Hindi',
  'Newari',
  'Maithili',
  'Bhojpuri',
];

class TutorOnboardingWizardPage extends StatefulWidget {
  const TutorOnboardingWizardPage({super.key});

  @override
  State<TutorOnboardingWizardPage> createState() =>
      _TutorOnboardingWizardPageState();
}

class _TutorOnboardingWizardPageState extends State<TutorOnboardingWizardPage> {
  final _controller = PageController();
  final _contactFormKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();
  int _index = 0;
  bool _resumed = false;

  // Step count is the total number of pages in the wizard. Step *labels*
  // are looked up per-locale via [_stepCount] / build time.
  static const int _stepCount = 8;

  @override
  void initState() {
    super.initState();
    // Phone + WhatsApp live on the profiles row (auth), not the tutor draft —
    // prefill from the cached user so a returning tutor sees what they entered.
    final user = sl<AuthRepository>().cachedUser;
    _phone.text = _stripCountryCode(user?.phone);
    _whatsapp.text = _stripCountryCode(user?.whatsapp);
  }

  @override
  void dispose() {
    _controller.dispose();
    _phone.dispose();
    _whatsapp.dispose();
    super.dispose();
  }

  /// Strip the +977 prefix for editing; it is re-added on save.
  String _stripCountryCode(String? raw) {
    final v = raw ?? '';
    return v.startsWith('+977') ? v.substring(4) : v;
  }

  void _resumeIfNeeded(TutorProfile profile) {
    if (_resumed) return;
    _resumed = true;
    final target = profile.wizardStep.clamp(0, _stepCount - 1);
    if (target == 0) return;
    setState(() => _index = target);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.jumpToPage(target);
    });
  }

  /// Push the new step index back into the draft so a relaunch resumes here.
  void _persistStep(BuildContext ctx, TutorProfile profile, int next) {
    if (profile.wizardStep == next) return;
    ctx.read<TutorProfileBloc>().add(
      TutorProfileDraftUpdated(profile.copyWith(wizardStep: next)),
    );
  }

  Future<void> _next(int total, BuildContext ctx, TutorProfile profile) async {
    // Step 0 is the contact step: validate and persist phone + WhatsApp to the
    // profiles row before advancing.
    if (_index == 0) {
      if (!_contactFormKey.currentState!.validate()) return;
      try {
        await sl<AuthRepository>().setTutorContact(
          phone: '+977${_phone.text.trim()}',
          whatsapp: '+977${_whatsapp.text.trim()}',
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorGeneric)),
        );
        return;
      }
      if (!mounted) return;
    }

    if (_index < total - 1) {
      setState(() => _index++);
      _persistStep(context, profile, _index);
      _controller.animateToPage(
        _index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      // Last step — open the onboarding gate, then return to tutor home. The
      // router guard keeps incomplete tutors out of home until this succeeds.
      try {
        await sl<AuthRepository>().completeTutorOnboarding();
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorGeneric)),
        );
        return;
      }
      if (!mounted) return;
      context.go(AppRoutes.tutorHome);
    }
  }

  void _prev(BuildContext ctx, TutorProfile profile) {
    if (_index == 0) return;
    setState(() => _index--);
    _persistStep(ctx, profile, _index);
    _controller.animateToPage(
      _index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<TutorProfileBloc, TutorProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        if (state.status == TutorProfileStatus.loading || profile == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        _resumeIfNeeded(profile);
        final isLast = _index == _stepCount - 1;
        return Scaffold(
          appBar: BrandAppBar(
            title: Text(l10n.wizardAppBarTitle(_index + 1, _stepCount)),
            leading: _index == 0
                ? null
                : IconButton(
                    tooltip: l10n.wizardPrevStepTooltip,
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => _prev(context, profile),
                  ),
          ),
          body: Column(
            children: [
              LinearProgressIndicator(
                value: (_index + 1) / _stepCount,
                minHeight: 4,
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) {
                    setState(() => _index = i);
                    _persistStep(context, profile, i);
                  },
                  children: [
                    _ContactStep(
                      formKey: _contactFormKey,
                      phone: _phone,
                      whatsapp: _whatsapp,
                    ),
                    _ServiceAreaStep(profile: profile),
                    _ResumeStep(profile: profile),
                    _TeachingModeStep(profile: profile),
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
                          onPressed: () => _prev(context, profile),
                          child: Text(l10n.backAction),
                        ),
                      ),
                    if (_index > 0) const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        label: isLast ? l10n.finishAction : l10n.continueAction,
                        onPressed: () => _next(_stepCount, context, profile),
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

// ─── Step 1: Contact — phone + WhatsApp, persisted to the profiles row ────────

class _ContactStep extends StatelessWidget {
  const _ContactStep({
    required this.formKey,
    required this.phone,
    required this.whatsapp,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController phone;
  final TextEditingController whatsapp;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          SectionCard(
            title: l10n.onboardingContactTitle,
            subtitle: l10n.onboardingContactSubtitle,
            child: Column(
              children: [
                AppTextField(
                  label: l10n.phoneNumberLabel,
                  hint: l10n.phoneNumberHint,
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: (v) => Validators.nepaliPhone(v) == null
                      ? null
                      : l10n.phoneInvalid,
                ),
                AppTextField(
                  label: l10n.whatsappLabel,
                  hint: l10n.phoneNumberHint,
                  controller: whatsapp,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.chat_outlined,
                  validator: (v) => Validators.nepaliPhone(v) == null
                      ? null
                      : l10n.phoneInvalid,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 3: Resume / CV upload ───────────────────────────────────────────────

class _ResumeStep extends StatelessWidget {
  const _ResumeStep({required this.profile});
  final TutorProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        DraftBanner(
          completion: profile.profileCompletion,
          isPublished: profile.isPublished,
        ),
        SectionCard(
          title: l10n.wizardCvUploadTitle,
          subtitle: l10n.wizardCvUploadSubtitle,
          child: CvUploadCard(profile: profile),
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
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<TutorProfileBloc>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        DraftBanner(
          completion: profile.profileCompletion,
          isPublished: profile.isPublished,
        ),
        SectionCard(
          title: l10n.wizardTeachingModeTitle,
          subtitle: l10n.wizardTeachingModeSubtitle,
          child: TeachingModeSelector(
            value: profile.teachingMode,
            onChanged: (m) => bloc.add(
              TutorProfileDraftUpdated(profile.copyWith(teachingMode: m)),
            ),
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
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<TutorProfileBloc>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        DraftBanner(
          completion: profile.profileCompletion,
          isPublished: profile.isPublished,
        ),
        SectionCard(
          title: l10n.wizardServiceAreaTitle,
          subtitle: l10n.wizardServiceAreaSubtitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: profile.city,
                decoration: InputDecoration(labelText: l10n.cityLabel),
                onChanged: (v) => bloc.add(
                  TutorProfileDraftUpdated(profile.copyWith(city: v)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                initialValue: profile.addressLine,
                decoration: InputDecoration(labelText: l10n.areaChowkLabel),
                onChanged: (v) => bloc.add(
                  TutorProfileDraftUpdated(profile.copyWith(addressLine: v)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.wizardServiceAreaPinHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              MapPinPicker(
                height: 240,
                initialLat: profile.lat ?? LocationService.fallbackLat,
                initialLng: profile.lng ?? LocationService.fallbackLng,
                onChanged: (lat, lng) => bloc.add(
                  TutorProfileDraftUpdated(
                    profile.copyWith(lat: lat, lng: lng),
                  ),
                ),
                showSelectButton: true,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.travelRadiusPrefix(profile.serviceRadiusKm.toInt())),
              Slider(
                value: profile.serviceRadiusKm.toDouble(),
                min: 1,
                max: 20,
                divisions: 19,
                label: l10n.kmSuffix(profile.serviceRadiusKm.toInt()),
                onChanged: (v) => bloc.add(
                  TutorProfileDraftUpdated(
                    profile.copyWith(serviceRadiusKm: v),
                  ),
                ),
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
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<TutorProfileBloc>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        DraftBanner(
          completion: profile.profileCompletion,
          isPublished: profile.isPublished,
        ),
        SectionCard(
          title: l10n.wizardLevelsTitle,
          subtitle: l10n.wizardLevelsSubtitle,
          child: ChipMultiSelect<StudentLevel>(
            options: StudentLevel.values,
            selected: profile.levelsTaught,
            labelOf: (l) => l.localized(l10n),
            onChanged: (set) {
              // Drop offerings whose level is no longer selected.
              final keptOfferings = profile.offerings
                  .where((o) => set.contains(o.level))
                  .toList();
              bloc.add(
                TutorProfileDraftUpdated(
                  profile.copyWith(levelsTaught: set, offerings: keptOfferings),
                ),
              );
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
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<TutorProfileBloc>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        DraftBanner(
          completion: profile.profileCompletion,
          isPublished: profile.isPublished,
        ),
        SectionCard(
          title: l10n.wizardSubjectsTitle,
          subtitle: l10n.wizardSubjectsSubtitle,
          child: SubjectsOfferedEditor(
            offerings: profile.offerings,
            allowedLevels: profile.levelsTaught,
            onChanged: (list) => bloc.add(
              TutorProfileDraftUpdated(profile.copyWith(offerings: list)),
            ),
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
  late final _aboutMe = TextEditingController(
    text: widget.profile.aboutMe ?? '',
  );
  late final _aboutSessions = TextEditingController(
    text: widget.profile.aboutSessions ?? '',
  );
  late final _qualifications = TextEditingController(
    text: widget.profile.qualifications ?? '',
  );

  @override
  void dispose() {
    _aboutMe.dispose();
    _aboutSessions.dispose();
    _qualifications.dispose();
    super.dispose();
  }

  String? _violationMessage(AppLocalizations l10n, String text) =>
      PhoneBanRegex.isViolation(text) ? l10n.phoneInTextValidation : null;

  void _emit() {
    context.read<TutorProfileBloc>().add(
      TutorProfileDraftUpdated(
        widget.profile.copyWith(
          aboutMe: _aboutMe.text,
          aboutSessions: _aboutSessions.text,
          qualifications: _qualifications.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<TutorProfileBloc>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        DraftBanner(
          completion: widget.profile.profileCompletion,
          isPublished: widget.profile.isPublished,
        ),
        PhoneBanWarning(message: l10n.tutorProfilePhoneBanWarning),
        SectionCard(
          title: l10n.aboutMeLabel,
          child: _aboutField(l10n, _aboutMe, l10n.aboutMeHintWizard),
        ),
        SectionCard(
          title: l10n.aboutSessionsLabel,
          child: _aboutField(
            l10n,
            _aboutSessions,
            l10n.aboutSessionsHintWizard,
          ),
        ),
        SectionCard(
          title: l10n.qualificationsLabel,
          child: _aboutField(
            l10n,
            _qualifications,
            l10n.qualificationsHintWizard,
          ),
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
                  bloc.add(
                    TutorProfileDraftUpdated(
                      widget.profile.copyWith(languagesKnown: next),
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _aboutField(
    AppLocalizations l10n,
    TextEditingController c,
    String hint,
  ) {
    return TextFormField(
      controller: c,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: hint,
        errorText: _violationMessage(l10n, c.text),
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
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<TutorProfileBloc>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        DraftBanner(
          completion: profile.profileCompletion,
          isPublished: profile.isPublished,
        ),
        SectionCard(
          title: l10n.wizardAvailabilityTitle,
          subtitle: l10n.wizardAvailabilitySubtitle,
          child: AvailabilityGrid(
            value: profile.availability,
            onChanged: (a) => bloc.add(
              TutorProfileDraftUpdated(profile.copyWith(availability: a)),
            ),
          ),
        ),
      ],
    );
  }
}
