import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/services/platform_settings_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../student_requests/domain/models/request_enums.dart';
import '../../../student_requests/presentation/enum_labels.dart';
import '../../domain/models/vacancy.dart';
import '../blocs/vacancies_bloc.dart';
import '../widgets/apply_to_vacancy_sheet.dart';

class VacancyDetailPage extends StatelessWidget {
  const VacancyDetailPage({super.key, required this.vacancyId});

  final String vacancyId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<VacanciesBloc, VacanciesState>(
      builder: (context, state) {
        final vacancy = state.vacancies.where((v) => v.id == vacancyId).firstOrNull;
        if (vacancy == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.vacancyTitleFallback)),
            body: Center(child: Text(l10n.vacancyNotFound)),
          );
        }
        final applied = state.appliedVacancyIds.contains(vacancy.id);
        return Scaffold(
          appBar: AppBar(title: Text(vacancy.code ?? l10n.vacancyTitleFallback)),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(vacancy.title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Row(children: [
                const Icon(Icons.place_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Flexible(child: Text(vacancy.areaLabel)),
              ]),
              const SizedBox(height: AppSpacing.lg),
              Card(
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.cardBorder),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(children: [
                    if (vacancy.grade != null)
                      _Row(icon: Icons.school_outlined, text: l10n.vacancyGradePrefix(vacancy.grade!)),
                    if (vacancy.subjects.isNotEmpty)
                      _Row(
                          icon: Icons.menu_book_outlined,
                          text: l10n.vacancySubjectsPrefix(vacancy.subjects.join(', '))),
                    _Row(icon: Icons.people_outline, text: l10n.vacancyNumStudentsPrefix(vacancy.numStudents)),
                    if (vacancy.durationText != null)
                      _Row(icon: Icons.schedule, text: l10n.vacancyTimePrefix(vacancy.durationText!)),
                    _Row(icon: Icons.payments_outlined, text: vacancy.formatSalary()),
                    _Row(
                      icon: Icons.wc_outlined,
                      text: l10n.vacancyGenderPrefPrefix(vacancy.genderPref.localized(l10n)),
                    ),
                    _Row(
                      icon: vacancy.mode == JobMode.online ? Icons.wifi : Icons.home_outlined,
                      text: l10n.vacancyModePrefix(vacancy.mode.localized(l10n)),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (vacancy.notes != null && vacancy.notes!.isNotEmpty) ...[
                Text(l10n.vacancyNotesHeader, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.cardBorder),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(vacancy.notes!),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text(
                l10n.vacancyPostedByAdmin,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: applied
                  ? OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check),
                      label: Text(l10n.vacancyAlreadyApplied),
                    )
                  : PrimaryButton(
                      label: l10n.vacancyApplyLabel,
                      onPressed: () => _showApply(context, vacancy),
                    ),
            ),
          ),
        );
      },
    );
  }

  void _showApply(BuildContext context, Vacancy vacancy) {
    final vacBloc = context.read<VacanciesBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: vacBloc,
        child: ApplyToVacancySheet(
          vacancy: vacancy,
          platformSettings: sl<PlatformSettingsService>(),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text)),
      ]),
    );
  }
}
