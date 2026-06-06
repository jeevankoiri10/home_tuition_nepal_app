import 'package:flutter/material.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/services/platform_settings_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../wallet/presentation/blocs/wallet_bloc.dart';
import '../../domain/connect_cost.dart';
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
      child: Builder(builder: (context) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
        appBar: BrandAppBar(
          title: Text(l10n.vacanciesTitle),
          actions: [
            IconButton(
              tooltip: l10n.refreshTooltip,
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
                  child: Text(state.errorMessage ?? l10n.vacanciesLoadError,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.danger)),
                ),
              );
            }
            if (state.vacancies.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    l10n.vacanciesEmpty,
                    style: const TextStyle(color: AppColors.textSecondary),
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
                    connectCost: ConnectCost.forVacancyWithSettings(
                        v, sl<PlatformSettingsService>()),
                    onTap: () =>
                        context.push(AppRoutes.vacancyDetail.replaceAll(':id', v.id)),
                    onApply: () => _showApply(context, v),
                  );
                },
              ),
            );
          },
        ),
        );
      }),
    );
  }
}
