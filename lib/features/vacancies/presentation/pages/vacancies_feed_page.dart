import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/services/platform_settings_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../wallet/presentation/blocs/wallet_bloc.dart';
import '../../domain/models/vacancy.dart';
import '../blocs/vacancies_bloc.dart';
import '../widgets/apply_to_vacancy_sheet.dart';
import '../widgets/vacancy_card.dart';

class VacanciesFeedPage extends StatelessWidget {
  const VacanciesFeedPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<VacanciesBloc, VacanciesState>(
      listenWhen: (a, b) => a.applyStatus != b.applyStatus,
      listener: (context, state) {
        if (state.applyStatus == ApplyStatus.success) {
          // Wallet might be in scope too — refresh it.
          try {
            context.read<WalletBloc>().add(const WalletBalanceChanged());
          } catch (_) {/* no wallet bloc above */}
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vacancies'),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<VacanciesBloc>().add(const VacanciesRefreshed()),
            ),
          ],
        ),
        body: BlocBuilder<VacanciesBloc, VacanciesState>(
          builder: (context, state) {
            if (state.status == VacanciesStatus.loading && state.vacancies.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == VacanciesStatus.error && state.vacancies.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(state.errorMessage ?? 'Could not load vacancies.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.danger)),
                ),
              );
            }
            if (state.vacancies.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'No open vacancies right now. Pull to refresh.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<VacanciesBloc>().add(const VacanciesRefreshed());
                await Future<void>.delayed(const Duration(milliseconds: 300));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: state.vacancies.length,
                itemBuilder: (_, i) {
                  final v = state.vacancies[i];
                  final applied = state.appliedVacancyIds.contains(v.id);
                  return VacancyCard(
                    vacancy: v,
                    alreadyApplied: applied,
                    onTap: () =>
                        context.push(AppRoutes.vacancyDetail.replaceAll(':id', v.id)),
                    onApply: () => _showApply(context, v),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
