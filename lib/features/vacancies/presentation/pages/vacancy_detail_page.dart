import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/services/platform_settings_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/models/vacancy.dart';
import '../blocs/vacancies_bloc.dart';
import '../widgets/apply_to_vacancy_sheet.dart';

class VacancyDetailPage extends StatelessWidget {
  const VacancyDetailPage({super.key, required this.vacancyId});

  final String vacancyId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VacanciesBloc, VacanciesState>(
      builder: (context, state) {
        final vacancy = state.vacancies.where((v) => v.id == vacancyId).firstOrNull;
        if (vacancy == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Vacancy')),
            body: const Center(child: Text('Vacancy not found.')),
          );
        }
        final applied = state.appliedVacancyIds.contains(vacancy.id);
        return Scaffold(
          appBar: AppBar(title: Text(vacancy.code ?? 'Vacancy')),
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
                      _Row(icon: Icons.school_outlined, text: 'Grade: ${vacancy.grade!}'),
                    if (vacancy.subjects.isNotEmpty)
                      _Row(
                          icon: Icons.menu_book_outlined,
                          text: 'Subjects: ${vacancy.subjects.join(', ')}'),
                    _Row(icon: Icons.people_outline, text: 'No. of students: ${vacancy.numStudents}'),
                    if (vacancy.durationText != null)
                      _Row(icon: Icons.schedule, text: 'Time: ${vacancy.durationText!}'),
                    _Row(icon: Icons.payments_outlined, text: vacancy.formatSalary()),
                    _Row(
                      icon: Icons.wc_outlined,
                      text: 'Gender preference: ${vacancy.genderPref.label}',
                    ),
                    _Row(
                      icon: vacancy.mode.label == 'Online'
                          ? Icons.wifi
                          : Icons.home_outlined,
                      text: 'Mode: ${vacancy.mode.label}',
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (vacancy.notes != null && vacancy.notes!.isNotEmpty) ...[
                Text('Notes', style: Theme.of(context).textTheme.titleMedium),
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
              const Text(
                'Posted by Home Tuition Nepal admin.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
                      label: const Text('Already applied'),
                    )
                  : PrimaryButton(
                      label: 'Apply',
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
