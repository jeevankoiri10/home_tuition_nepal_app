import 'package:flutter/material.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/services/platform_settings_service.dart';
import '../../../../core/services/presence_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/widgets/coin_chip.dart';
import '../../../../core/widgets/map_error_banner.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../../wallet/domain/wallet_repository.dart';
import '../../../wallet/presentation/blocs/wallet_bloc.dart';
import '../../../wallet/presentation/widgets/contact_unlock_sheet.dart';
import '../../domain/map_sort.dart';
import '../../domain/models/map_filters.dart';
import '../../domain/models/map_tutor.dart';
import '../blocs/map_bloc.dart';
import '../widgets/map_filter_bar.dart';
import '../widgets/map_pin.dart';
import '../widgets/tutor_carousel.dart';
import '../widgets/tutor_map_card.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _mapController = MapController();
  final _carouselController = PageController(viewportFraction: 0.85);
  final _sheetController = DraggableScrollableController();
  String? _lastSelectedId;
  int _lastRecenterSeq = 0;

  @override
  void dispose() {
    _carouselController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _onMapTap(MapBloc bloc) => bloc.add(const MapTutorSelected(null));

  void _onPinTap(MapBloc bloc, MapTutor tutor, int index) {
    bloc.add(MapTutorSelected(tutor.tutorId));
    if (_carouselController.hasClients) {
      _carouselController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
    _mapController.move(
      LatLng(tutor.lat, tutor.lng),
      _mapController.camera.zoom,
    );
  }

  void _onSearchHere(BuildContext context, MapBloc bloc, LatLng point) {
    bloc.add(MapSearchHere(lat: point.latitude, lng: point.longitude));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).mapSearchHereSnack),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onContactTap(BuildContext context, MapTutor t) {
    final walletBloc = context.read<WalletBloc>();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: walletBloc,
        child: ContactUnlockSheet(
          tutor: t,
          walletRepository: sl<WalletRepository>(),
          platformSettings: sl<PlatformSettingsService>(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapBloc, MapState>(
      listenWhen: (a, b) =>
          a.selectedTutorId != b.selectedTutorId ||
          a.recenterSeq != b.recenterSeq,
      listener: (context, state) {
        // Move the camera once when a recenter completes.
        if (state.recenterSeq != _lastRecenterSeq) {
          _lastRecenterSeq = state.recenterSeq;
          if (state.centerLat != null && state.centerLng != null) {
            _mapController.move(
              LatLng(state.centerLat!, state.centerLng!),
              _mapController.camera.zoom,
            );
          }
          return;
        }
        final id = state.selectedTutorId;
        if (id == null || id == _lastSelectedId) return;
        _lastSelectedId = id;
        final idx = state.tutors.indexWhere((t) => t.tutorId == id);
        if (idx == -1 || !_carouselController.hasClients) return;
        _carouselController.animateToPage(
          idx,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      },
      builder: (context, state) {
        final bloc = context.read<MapBloc>();
        return Scaffold(
          appBar: BrandAppBar(
            title: Text(AppConstants.appName),
            actions: [
              // Keep notifications and the coin balance up front; everything
              // else moves into the overflow menu to keep the bar uncluttered.
              const NotificationBell(),
              BlocBuilder<WalletBloc, WalletState>(
                builder: (_, w) => CoinChip(
                  balance: w.balance,
                  onTap: () => context.push(AppRoutes.wallet),
                ),
              ),
              const _StudentOptionsMenu(),
            ],
          ),
          body: state.centerLat == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    _MapLayer(
                      controller: _mapController,
                      state: state,
                      onTap: () => _onMapTap(bloc),
                      onLongPress: (point) => _onSearchHere(context, bloc, point),
                      onPinTap: (t, i) => _onPinTap(bloc, t, i),
                      onCameraIdle: (pos) {
                        bloc.add(
                          MapCameraMoved(lat: pos.latitude, lng: pos.longitude),
                        );
                      },
                    ),
                    // Top stack: filter bar, then the loading bar / error banner
                    // flow directly beneath it in a Column — so they always sit
                    // below the filter bar at its real (text-scale-dependent)
                    // height instead of a fixed magic offset that would collide
                    // with taller chips at large font sizes.
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          MapFilterBar(
                            filters: state.filters,
                            onChanged: (f) => bloc.add(MapFiltersChanged(f)),
                          ),
                          if (state.status == MapStatus.loading)
                            const LinearProgressIndicator(minHeight: 2),
                          if (state.status == MapStatus.error)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.md,
                                AppSpacing.sm,
                                AppSpacing.md,
                                0,
                              ),
                              child: MapErrorBanner(
                                message:
                                    AppLocalizations.of(context).mapLoadError,
                                onRetry: () =>
                                    bloc.add(const MapRefreshRequested()),
                              ),
                            ),
                        ],
                      ),
                    ),
                    _BottomSheet(
                      controller: _sheetController,
                      state: state,
                      carouselController: _carouselController,
                      onCardTap: (t, i) => _onPinTap(bloc, t, i),
                      onContact: (t) => _onContactTap(context, t),
                      onExpandRadius: () => bloc.add(
                        MapFiltersChanged(state.filters.expandedRadius()),
                      ),
                    ),
                    _SheetTrackingFabs(
                      controller: _sheetController,
                      minSize: _BottomSheet.minSize,
                      maxSize: _BottomSheet.maxSize,
                    ),
                    _SheetTrackingRecenterFab(
                      controller: _sheetController,
                      minSize: _BottomSheet.minSize,
                      maxSize: _BottomSheet.maxSize,
                      loading: state.recentering,
                      onPressed: () => context.read<MapBloc>().add(
                        const MapRecenterRequested(),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

// ─── Map layer ────────────────────────────────────────────────────────────────

class _MapLayer extends StatelessWidget {
  const _MapLayer({
    required this.controller,
    required this.state,
    required this.onTap,
    required this.onLongPress,
    required this.onPinTap,
    required this.onCameraIdle,
  });

  final MapController controller;
  final MapState state;
  final VoidCallback onTap;
  final void Function(LatLng point) onLongPress;
  final void Function(MapTutor, int) onPinTap;
  final void Function(LatLng center) onCameraIdle;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: LatLng(state.centerLat!, state.centerLng!),
        initialZoom: 13,
        onTap: (_, _) => onTap(),
        onLongPress: (_, point) => onLongPress(point),
        onPositionChanged: (pos, hasGesture) {
          if (hasGesture) onCameraIdle(pos.center);
        },
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'app.htn.home_tuition_nepal',
        ),
        // Active search radius — a soft transparent circle so the student can
        // see how far the current results reach (student_UI.md §4.3.2). Only
        // drawn when a radius filter is set; "Any distance" shows no circle.
        if (state.filters.radiusMeters != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: LatLng(state.centerLat!, state.centerLng!),
                radius: state.filters.radiusMeters!,
                useRadiusInMeter: true,
                color: AppColors.primary.withValues(alpha: 0.08),
                borderColor: AppColors.primary.withValues(alpha: 0.35),
                borderStrokeWidth: 1.5,
              ),
            ],
          ),
        // "You are here" marker
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(state.centerLat!, state.centerLng!),
              width: 18,
              height: 18,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
          ],
        ),
        // Tutor pins — rebuilt when the online set changes so the green
        // presence badge tracks Realtime Presence live.
        ValueListenableBuilder<Set<String>>(
          valueListenable: sl<PresenceService>().online,
          builder: (context, onlineIds, _) {
            return MarkerLayer(
              markers: [
                for (int i = 0; i < state.tutors.length; i++)
                  Marker(
                    point: LatLng(state.tutors[i].lat, state.tutors[i].lng),
                    width: 64,
                    height: 68,
                    child: GestureDetector(
                      onTap: () => onPinTap(state.tutors[i], i),
                      child: MapPin(
                        tutor: state.tutors[i],
                        selected:
                            state.tutors[i].tutorId == state.selectedTutorId,
                        online: onlineIds.contains(state.tutors[i].tutorId),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ─── Bottom sheet (carousel collapsed, list expanded) ──────────────────────────

class _BottomSheet extends StatelessWidget {
  const _BottomSheet({
    required this.controller,
    required this.state,
    required this.carouselController,
    required this.onCardTap,
    required this.onContact,
    required this.onExpandRadius,
  });

  // Exposed so other widgets (FABs) can mirror the same bounds.
  static const double minSize = 0.12;
  static const double initialSize = 0.34;
  static const double maxSize = 0.92;

  final DraggableScrollableController controller;
  final MapState state;
  final PageController carouselController;
  final void Function(MapTutor, int) onCardTap;
  final void Function(MapTutor) onContact;
  final VoidCallback onExpandRadius;

  void _toggle() {
    final size = controller.size;
    // If close to max, collapse back to initial; else expand to max.
    final target = size > (initialSize + 0.1) ? initialSize : maxSize;
    controller.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: initialSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      // No `snap` — drags settle wherever the user lets go, so the sheet
      // never feels yanked between two fixed positions.
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              _DragHandleHeader(
                tutorCount: state.tutors.length,
                onTap: _toggle,
                sheetController: controller,
              ),
              Expanded(
                child: state.tutors.isEmpty
                    ? _EmptyState(
                        filters: state.filters,
                        onExpandRadius: onExpandRadius,
                      )
                    : _SheetBody(
                        state: state,
                        scrollController: scrollController,
                        carouselController: carouselController,
                        onCardTap: onCardTap,
                        onContact: onContact,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A tall, obviously-tappable header that drives the sheet via drag gestures
/// AND a tap-to-toggle. Sized to be a comfortable thumb target on phones.
class _DragHandleHeader extends StatelessWidget {
  const _DragHandleHeader({
    required this.tutorCount,
    required this.onTap,
    required this.sheetController,
  });

  final int tutorCount;
  final VoidCallback onTap;
  final DraggableScrollableController sheetController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Rebuild the semantics label whenever the sheet's size crosses the
    // halfway mark so screen readers always reflect "expanded" vs
    // "collapsed" without spamming on every drag delta.
    return AnimatedBuilder(
      animation: sheetController,
      builder: (context, child) {
        final size = sheetController.isAttached
            ? sheetController.size
            : _BottomSheet.initialSize;
        final isExpanded =
            size >= (_BottomSheet.initialSize + _BottomSheet.maxSize) / 2;
        final state = isExpanded
            ? l10n.mapSheetExpanded
            : l10n.mapSheetCollapsed;
        final action = isExpanded
            ? l10n.mapSheetActionCollapse
            : l10n.mapSheetActionExpand;
        return Semantics(
          button: true,
          label: l10n.mapSheetHandleSemantics(state, action),
          excludeSemantics: true,
          child: child,
        );
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onVerticalDragUpdate: (details) {
          // Translate finger movement into sheet-size delta. The sheet's `size`
          // is a fraction of screen height; positive primaryDelta is downward.
          final screenHeight = MediaQuery.of(context).size.height;
          final next =
              (sheetController.size - details.primaryDelta! / screenHeight)
                  .clamp(_BottomSheet.minSize, _BottomSheet.maxSize);
          sheetController.jumpTo(next);
        },
        child: Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.sm,
            bottom: AppSpacing.xs,
          ),
          child: Column(
            children: [
              // Pill — bigger than the original 36×4 so it reads as a control.
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context).mapTutorCount(tutorCount),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    AnimatedBuilder(
                      animation: sheetController,
                      builder: (_, _) {
                        final t = sheetController.isAttached
                            ? ((sheetController.size - _BottomSheet.minSize) /
                                      (_BottomSheet.maxSize -
                                          _BottomSheet.minSize))
                                  .clamp(0.0, 1.0)
                            : 0.0;
                        // 0 → expand-less (pointing up to invite expansion);
                        // 1 → expand-more (pointing down to invite collapse).
                        return Transform.rotate(
                          angle: t * 3.14159,
                          child: const Icon(
                            Icons.expand_less,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Repositions floating action buttons so they always sit just above the
/// bottom sheet's current top edge, instead of a fixed magic offset that
/// would clip when the sheet expands.
class _SheetTrackingFabs extends StatelessWidget {
  const _SheetTrackingFabs({
    required this.controller,
    required this.minSize,
    required this.maxSize,
  });

  final DraggableScrollableController controller;
  final double minSize;
  final double maxSize;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final size = controller.isAttached
            ? controller.size.clamp(minSize, maxSize)
            : minSize;
        // The sheet covers `size * screenHeight` from the bottom; sit the
        // FABs 12px above the top edge of that.
        final bottomInset = size * screenHeight + 12;
        return Positioned(
          left: AppSpacing.lg,
          bottom: bottomInset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FloatingActionButton.extended(
                heroTag: 'fab-post-job',
                onPressed: () => context.push(AppRoutes.postJob),
                icon: const Icon(Icons.post_add_outlined),
                label: Text(AppLocalizations.of(context).mapPostJobFab),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Bottom-right recenter FAB that tracks the sheet so it always sits just
/// above the sheet's top edge — same pattern as [_SheetTrackingFabs].
class _SheetTrackingRecenterFab extends StatelessWidget {
  const _SheetTrackingRecenterFab({
    required this.controller,
    required this.minSize,
    required this.maxSize,
    required this.onPressed,
    this.loading = false,
  });

  final DraggableScrollableController controller;
  final double minSize;
  final double maxSize;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final size = controller.isAttached
            ? controller.size.clamp(minSize, maxSize)
            : minSize;
        final bottomInset = size * screenHeight + 12;
        return Positioned(
          right: AppSpacing.lg,
          bottom: bottomInset,
          child: FloatingActionButton(
            heroTag: 'fab-recenter',
            tooltip: l10n.mapRecenterTooltip,
            onPressed: loading ? null : onPressed,
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.my_location),
          ),
        );
      },
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({
    required this.state,
    required this.scrollController,
    required this.carouselController,
    required this.onCardTap,
    required this.onContact,
  });

  final MapState state;
  final ScrollController scrollController;
  final PageController carouselController;
  final void Function(MapTutor, int) onCardTap;
  final void Function(MapTutor) onContact;

  @override
  Widget build(BuildContext context) {
    // The carousel and the list both render the same data; CustomScrollView
    // lets us nest them inside the DraggableScrollableSheet's scroll controller.
    // BouncingScrollPhysics gives a smoother handoff between inner scroll and
    // the sheet's own drag: when the user keeps dragging past offset 0 the
    // sheet collapses instead of the list hitting a hard stop.
    return CustomScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: TutorCarousel(
            tutors: state.tutors,
            selectedTutorId: state.selectedTutorId,
            controller: carouselController,
            onCardTap: onCardTap,
            onContact: onContact,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Text(AppLocalizations.of(context).mapAllMatchesHeader),
                const Spacer(),
                _SortDropdown(sort: state.sort),
              ],
            ),
          ),
        ),
        SliverList.builder(
          itemCount: state.tutors.length,
          itemBuilder: (context, i) {
            final t = state.tutors[i];
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: TutorMapCard(
                tutor: t,
                selected: t.tutorId == state.selectedTutorId,
                listMode: true,
                onTap: () => onCardTap(t, i),
                onContact: () => onContact(t),
              ),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
      ],
    );
  }
}

/// Shown in the sheet when no tutors match. Per `student_UI.md` §4.3.5 it
/// offers two ways forward: widen the search radius, or ask the admin to
/// source a tutor (Request a tutor).
/// Sort control for the "All matches" list (student_UI.md §4.3.6). Re-orders
/// the tutors in place via [MapSortChanged] — no re-query.
class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.sort});

  final MapSort sort;

  static String _label(AppLocalizations l10n, MapSort s) => switch (s) {
        MapSort.distance => l10n.mapSortNearest,
        MapSort.priceLowHigh => l10n.mapSortPriceLowHigh,
        MapSort.rating => l10n.mapSortTopRated,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<MapSort>(
      initialValue: sort,
      onSelected: (s) => context.read<MapBloc>().add(MapSortChanged(s)),
      itemBuilder: (_) => [
        for (final s in MapSort.values)
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filters, required this.onExpandRadius});

  final MapFilters filters;
  final VoidCallback onExpandRadius;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 48),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.mapEmptyTitle,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.mapEmptyHint,
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: [
              // Only offer "Expand radius" when there's a radius left to widen.
              if (filters.canExpandRadius)
                FilledButton.tonalIcon(
                  onPressed: onExpandRadius,
                  icon: const Icon(Icons.zoom_out_map, size: 18),
                  label: Text(l10n.mapEmptyExpandRadius),
                ),
              OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.requestTutor),
                icon: const Icon(Icons.person_search_outlined, size: 18),
                label: Text(l10n.mapRequestTutorFab),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _StudentMenuAction { requestTutor, messages, myPosts, profile }

/// Overflow ("option") menu for the student/parent app bar. Notifications and
/// the coin balance stay up front; the rest of the actions live here, each with
/// an icon and a label.
class _StudentOptionsMenu extends StatelessWidget {
  const _StudentOptionsMenu();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<_StudentMenuAction>(
      icon: const Icon(Icons.more_vert),
      onSelected: (action) {
        final route = switch (action) {
          _StudentMenuAction.requestTutor => AppRoutes.requestTutor,
          _StudentMenuAction.messages => AppRoutes.chatList,
          _StudentMenuAction.myPosts => AppRoutes.myPosts,
          _StudentMenuAction.profile => AppRoutes.studentSettings,
        };
        context.push(route);
      },
      itemBuilder: (context) => [
        _item(
          _StudentMenuAction.requestTutor,
          Icons.person_search_outlined,
          l10n.mapRequestTutorFab,
        ),
        _item(
          _StudentMenuAction.messages,
          Icons.forum_outlined,
          l10n.viewMessages,
        ),
        _item(
          _StudentMenuAction.myPosts,
          Icons.assignment_outlined,
          l10n.mapMyPostsTooltip,
        ),
        _item(
          _StudentMenuAction.profile,
          Icons.person_outline,
          l10n.settingsProfileTooltip,
        ),
      ],
    );
  }

  PopupMenuItem<_StudentMenuAction> _item(
    _StudentMenuAction value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem<_StudentMenuAction>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.md),
          Text(label),
        ],
      ),
    );
  }
}
