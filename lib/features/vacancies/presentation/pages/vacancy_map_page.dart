import 'package:flutter/material.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/platform_settings_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/coin_chip.dart';
import '../../../../core/widgets/map_error_banner.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../../wallet/presentation/blocs/wallet_bloc.dart';
import '../../domain/connect_cost.dart';
import '../../domain/models/vacancy.dart';
import '../../domain/vacancy_sort.dart';
import '../blocs/vacancy_map_bloc.dart';

// NOTE: "Boost listing" is intentionally hidden from the UI for now — it
// returns in a later version. The backend (ReviewsRepository.boostFeatured)
// and its strings are left intact so re-enabling is just adding the menu item.
enum _TutorMenuAction { completeProfile }

/// Tutor Home: open vacancies plotted on an OpenStreetMap. Pins and the
/// bottom list both deep-link to the vacancy detail page where the tutor can
/// apply. Mirrors the student map's interaction model. The app-bar overflow
/// menu carries the tutor quick-actions (complete profile, boost) that used
/// to live on the old dashboard home.
class VacancyMapPage extends StatefulWidget {
  const VacancyMapPage({super.key});

  @override
  State<VacancyMapPage> createState() => _VacancyMapPageState();
}

class _VacancyMapPageState extends State<VacancyMapPage> {
  final _mapController = MapController();
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_started) return;
      _started = true;
      context.read<VacancyMapBloc>().add(const VacancyMapStarted());
    });
  }

  void _openDetail(String id) =>
      context.push(AppRoutes.vacancyDetail.replaceAll(':id', id));

  /// Tapping a pin selects the vacancy (highlighting it and floating it to the
  /// top of the nearby list) and flies the camera to it — the list row's own
  /// tap still opens the detail page. Mirrors the student map's pin↔card sync.
  void _onPinTap(String id) {
    final bloc = context.read<VacancyMapBloc>();
    bloc.add(VacancyMapSelected(id));
    final match = bloc.state.vacancies.where((v) => v.id == id);
    if (match.isNotEmpty && match.first.hasLocation) {
      _mapController.move(
        LatLng(match.first.lat!, match.first.lng!),
        _mapController.camera.zoom,
      );
    }
  }

  void _onMenu(_TutorMenuAction action) {
    switch (action) {
      case _TutorMenuAction.completeProfile:
        context.push(AppRoutes.tutorOnboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<VacancyMapBloc, VacancyMapState>(
      builder: (context, state) {
        final bloc = context.read<VacancyMapBloc>();
        return Scaffold(
          appBar: BrandAppBar(
            title: Text(AppConstants.appName),
            actions: [
              const NotificationBell(),
              BlocBuilder<WalletBloc, WalletState>(
                builder: (_, w) => CoinChip(
                  balance: w.balance,
                  onTap: () => context.push(AppRoutes.wallet),
                ),
              ),
              PopupMenuButton<_TutorMenuAction>(
                onSelected: _onMenu,
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: _TutorMenuAction.completeProfile,
                    child: Text(l10n.tutorActionCompleteProfileTitle),
                  ),
                ],
              ),
            ],
          ),
          body: state.centerLat == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    _MapLayer(
                      controller: _mapController,
                      state: state,
                      onPinTap: _onPinTap,
                      onMapTap: () => bloc.add(const VacancyMapSelected(null)),
                      onCameraIdle: (c) =>
                          bloc.add(VacancyMapCameraMoved(lat: c.latitude, lng: c.longitude)),
                    ),
                    if (state.status == VacancyMapStatus.loading)
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    if (state.status == VacancyMapStatus.error)
                      Positioned(
                        top: AppSpacing.md,
                        left: AppSpacing.md,
                        right: AppSpacing.md,
                        child: MapErrorBanner(
                          message: l10n.vacanciesLoadError,
                          onRetry: () =>
                              bloc.add(const VacancyMapRefreshRequested()),
                        ),
                      ),
                    _NearbySheet(
                      vacancies: state.vacancies,
                      selectedId: state.selectedId,
                      sort: state.sort,
                      platformSettings: sl<PlatformSettingsService>(),
                      onTap: _openDetail,
                    ),
                    Positioned(
                      right: AppSpacing.lg,
                      bottom: MediaQuery.of(context).size.height * 0.30 + 12,
                      child: FloatingActionButton(
                        heroTag: 'vacancy-recenter',
                        tooltip: l10n.mapRecenterTooltip,
                        onPressed: () {
                          if (state.centerLat != null && state.centerLng != null) {
                            _mapController.move(
                              LatLng(state.centerLat!, state.centerLng!),
                              _mapController.camera.zoom,
                            );
                          }
                          bloc.add(const VacancyMapRefreshRequested());
                        },
                        child: const Icon(Icons.my_location),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _MapLayer extends StatelessWidget {
  const _MapLayer({
    required this.controller,
    required this.state,
    required this.onPinTap,
    required this.onMapTap,
    required this.onCameraIdle,
  });

  final MapController controller;
  final VacancyMapState state;
  final void Function(String vacancyId) onPinTap;
  final VoidCallback onMapTap;
  final void Function(LatLng center) onCameraIdle;

  @override
  Widget build(BuildContext context) {
    final located = state.vacancies.where((v) => v.hasLocation).toList();
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: LatLng(state.centerLat!, state.centerLng!),
        initialZoom: 13,
        onTap: (_, _) => onMapTap(),
        onPositionChanged: (pos, hasGesture) {
          if (hasGesture) onCameraIdle(pos.center);
        },
        interactionOptions:
            const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'app.htn.home_tuition_nepal',
        ),
        MarkerLayer(markers: [
          Marker(
            point: LatLng(state.centerLat!, state.centerLng!),
            width: 16,
            height: 16,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
          ),
          for (final v in located)
            Marker(
              point: LatLng(v.lat!, v.lng!),
              width: 48,
              height: 48,
              child: GestureDetector(
                onTap: () => onPinTap(v.id),
                child: _VacancyPin(selected: v.id == state.selectedId),
              ),
            ),
        ]),
      ],
    );
  }
}

class _VacancyPin extends StatelessWidget {
  const _VacancyPin({this.selected = false});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    // The selected pin grows and switches to the primary colour with a thicker
    // ring so it stands out from the rest while a tutor inspects it.
    final size = selected ? 38.0 : 30.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : AppColors.accent,
        border: Border.all(color: Colors.white, width: selected ? 3 : 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(Icons.work_outline,
          color: Colors.white, size: selected ? 20 : 16),
    );
  }
}

/// Sort control for the nearby-vacancy list — re-orders in place via
/// [VacancyMapSortChanged] (no re-query). Vacancies support a real "Newest"
/// since they carry a created timestamp.
class _VacancySortDropdown extends StatelessWidget {
  const _VacancySortDropdown({required this.sort});

  final VacancySort sort;

  static String _label(AppLocalizations l10n, VacancySort s) => switch (s) {
        VacancySort.distance => l10n.mapSortNearest,
        VacancySort.salaryHighLow => l10n.vacancyMapSortSalary,
        VacancySort.newest => l10n.vacancyMapSortNewest,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<VacancySort>(
      initialValue: sort,
      onSelected: (s) =>
          context.read<VacancyMapBloc>().add(VacancyMapSortChanged(s)),
      itemBuilder: (_) => [
        for (final s in VacancySort.values)
          PopupMenuItem(value: s, child: Text(_label(l10n, s))),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sort, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(_label(l10n, sort),
              style: const TextStyle(color: AppColors.textSecondary)),
          const Icon(Icons.arrow_drop_down,
              size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

/// Compact pill showing the coin cost to apply to a vacancy, with a tooltip
/// spelling it out ("Apply — N coins"). Lets a tutor weigh connect cost against
/// distance and salary right in the nearby list.
class _ConnectCostPill extends StatelessWidget {
  const _ConnectCostPill({required this.cost, required this.label});

  final int cost;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.monetization_on_outlined,
                size: 13, color: AppColors.primary),
            const SizedBox(width: 2),
            Text(
              '$cost',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbySheet extends StatelessWidget {
  const _NearbySheet({
    required this.vacancies,
    required this.selectedId,
    required this.sort,
    required this.platformSettings,
    required this.onTap,
  });
  final List<Vacancy> vacancies;
  final String? selectedId;
  final VacancySort sort;
  final PlatformSettingsService platformSettings;
  final void Function(String vacancyId) onTap;

  /// Vacancies ordered for display: the pin-selected one floats to the top so
  /// it's always visible in the sheet without needing to scroll to find it.
  List<Vacancy> get _ordered {
    if (selectedId == null) return vacancies;
    final list = [...vacancies];
    final idx = list.indexWhere((v) => v.id == selectedId);
    if (idx > 0) list.insert(0, list.removeAt(idx));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.30,
      minChildSize: 0.12,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2))],
          ),
          child: vacancies.isEmpty
              ? ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        const Icon(Icons.work_off_outlined,
                            size: 44, color: AppColors.textSecondary),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.vacancyMapEmpty,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // No vacancies in range — the full feed isn't distance-
                        // limited, so it's the most useful next step for a tutor
                        // looking for work.
                        OutlinedButton.icon(
                          onPressed: () => context.push(AppRoutes.vacancies),
                          icon: const Icon(Icons.list_alt_outlined, size: 18),
                          label: Text(l10n.vacancyMapBrowseAll),
                        ),
                      ],
                    ),
                  ],
                )
              : ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  itemCount: vacancies.length + 1,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.sm),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                  l10n.vacancyMapNearbyCount(vacancies.length),
                                  style: Theme.of(context).textTheme.titleMedium),
                            ),
                            _VacancySortDropdown(sort: sort),
                          ],
                        ),
                      );
                    }
                    final v = _ordered[i - 1];
                    final isSelected = v.id == selectedId;
                    // Connect cost a tutor would spend to apply — same server-
                    // authoritative formula shown on the vacancy card/detail, so
                    // they can weigh cost vs distance before tapping in.
                    final cost =
                        ConnectCost.forVacancyWithSettings(v, platformSettings);
                    return ListTile(
                      selected: isSelected,
                      selectedTileColor:
                          AppColors.primary.withValues(alpha: 0.08),
                      leading: const Icon(Icons.work_outline, color: AppColors.accent),
                      title: Text('${v.code ?? ''} · ${v.areaLabel}',
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        '${v.formatSalary()}'
                        '${v.formatDistance() != null ? ' · ${v.formatDistance()}' : ''}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ConnectCostPill(cost: cost, label: l10n.applyButtonLabel(cost)),
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: () => onTap(v.id),
                    );
                  },
                ),
        );
      },
    );
  }
}
