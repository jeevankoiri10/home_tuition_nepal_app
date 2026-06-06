import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/map_pin_picker.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../cubit/student_onboarding_cubit.dart';

/// First-run onboarding for students: contact details, then a map pin for their
/// location. Finishing opens the gate and the router guard routes to the map.
class StudentOnboardingPage extends StatefulWidget {
  const StudentOnboardingPage({super.key});

  static const int stepCount = 2;

  @override
  State<StudentOnboardingPage> createState() => _StudentOnboardingPageState();
}

class _StudentOnboardingPageState extends State<StudentOnboardingPage> {
  final _controller = PageController();
  final _contactFormKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();
  int _index = 0;
  bool _resumed = false;

  @override
  void dispose() {
    _controller.dispose();
    _phone.dispose();
    _whatsapp.dispose();
    super.dispose();
  }

  void _resumeIfNeeded(int savedStep) {
    if (_resumed) return;
    _resumed = true;
    final target = savedStep.clamp(0, StudentOnboardingPage.stepCount - 1);
    if (target == 0) return;
    setState(() => _index = target);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.jumpToPage(target);
    });
  }

  void _goTo(int next) {
    setState(() => _index = next);
    context.read<StudentOnboardingCubit>().goToStep(next);
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _onNext() {
    if (!_contactFormKey.currentState!.validate()) return;
    _goTo(1);
  }

  Future<void> _onDone() async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<StudentOnboardingCubit>();
    final ok = await cubit.complete(
      phone: '+977${_phone.text.trim()}',
      whatsapp: '+977${_whatsapp.text.trim()}',
    );
    if (!mounted || ok) return; // success → router guard navigates away
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<StudentOnboardingCubit, StudentOnboardingState>(
      builder: (context, state) {
        _resumeIfNeeded(state.step);
        final isLast = _index == StudentOnboardingPage.stepCount - 1;
        return Scaffold(
          appBar: BrandAppBar(
            title: Text(
              l10n.wizardAppBarTitle(
                _index + 1,
                StudentOnboardingPage.stepCount,
              ),
            ),
            leading: _index == 0
                ? null
                : IconButton(
                    tooltip: l10n.backAction,
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => _goTo(0),
                  ),
          ),
          body: Column(
            children: [
              LinearProgressIndicator(
                value: (_index + 1) / StudentOnboardingPage.stepCount,
                minHeight: 4,
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _ContactStep(
                      formKey: _contactFormKey,
                      phone: _phone,
                      whatsapp: _whatsapp,
                    ),
                    _LocationStep(
                      initialLat: state.lat ?? LocationService.fallbackLat,
                      initialLng: state.lng ?? LocationService.fallbackLng,
                      onChanged: context
                          .read<StudentOnboardingCubit>()
                          .setLocation,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: PrimaryButton(
                  label: isLast ? l10n.doneAction : l10n.nextAction,
                  busy: state.saving,
                  onPressed: state.saving ? null : (isLast ? _onDone : _onNext),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

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

class _LocationStep extends StatelessWidget {
  const _LocationStep({
    required this.initialLat,
    required this.initialLng,
    required this.onChanged,
  });

  final double initialLat;
  final double initialLng;
  final void Function(double lat, double lng) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SectionCard(
          title: l10n.onboardingLocationTitle,
          subtitle: l10n.onboardingLocationSubtitle,
          child: MapPinPicker(
            height: 320,
            initialLat: initialLat,
            initialLng: initialLng,
            onChanged: onChanged,
            showSelectButton: true,
          ),
        ),
      ],
    );
  }
}
