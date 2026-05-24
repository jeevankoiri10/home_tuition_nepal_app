import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/services/platform_settings_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../../wallet/domain/wallet_repository.dart';
import '../../../wallet/presentation/blocs/wallet_bloc.dart';
import '../../../wallet/presentation/widgets/contact_unlock_sheet.dart';
import '../../domain/models/map_tutor.dart';
import '../blocs/map_bloc.dart';
import '../widgets/map_filter_bar.dart';
import '../widgets/map_pin.dart';
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
      _carouselController.animateToPage(index,
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
    _mapController.move(LatLng(tutor.lat, tutor.lng), _mapController.camera.zoom);
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
      listenWhen: (a, b) => a.selectedTutorId != b.selectedTutorId,
      listener: (context, state) {
        final id = state.selectedTutorId;
        if (id == null || id == _lastSelectedId) return;
        _lastSelectedId = id;
        final idx = state.tutors.indexWhere((t) => t.tutorId == id);
        if (idx == -1 || !_carouselController.hasClients) return;
        _carouselController.animateToPage(idx,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      },
      builder: (context, state) {
        final bloc = context.read<MapBloc>();
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.mapTitle),
            actions: [
              const NotificationBell(),
              IconButton(
                tooltip: l10n.mapMyPostsTooltip,
                icon: const Icon(Icons.assignment_outlined),
                onPressed: () => context.push(AppRoutes.myPosts),
              ),
              BlocBuilder<WalletBloc, WalletState>(
                builder: (_, w) => TextButton.icon(
                  onPressed: () => context.push(AppRoutes.wallet),
                  icon: const Icon(Icons.monetization_on_outlined, color: Colors.white),
                  label: Text('${w.balance}',
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.my_location),
                tooltip: l10n.mapRecenterTooltip,
                onPressed: () {
                  if (state.centerLat != null && state.centerLng != null) {
                    _mapController.move(
                      LatLng(state.centerLat!, state.centerLng!),
                      _mapController.camera.zoom,
                    );
                  }
                },
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
                      onTap: () => _onMapTap(bloc),
                      onPinTap: (t, i) => _onPinTap(bloc, t, i),
                      onCameraIdle: (pos) {
                        bloc.add(MapCameraMoved(lat: pos.latitude, lng: pos.longitude));
                      },
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: MapFilterBar(
                        filters: state.filters,
                        onChanged: (f) => bloc.add(MapFiltersChanged(f)),
                      ),
                    ),
                    if (state.status == MapStatus.loading)
                      const Positioned(
                        top: 64,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    _BottomSheet(
                      controller: _sheetController,
                      state: state,
                      carouselController: _carouselController,
                      onCardTap: (t, i) => _onPinTap(bloc, t, i),
                      onContact: (t) => _onContactTap(context, t),
                    ),
                    _SheetTrackingFabs(
                      controller: _sheetController,
                      minSize: _BottomSheet.minSize,
                      maxSize: _BottomSheet.maxSize,
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
    required this.onPinTap,
    required this.onCameraIdle,
  });

  final MapController controller;
  final MapState state;
  final VoidCallback onTap;
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
        // "You are here" marker
        MarkerLayer(markers: [
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
        ]),
        // Tutor pins
        MarkerLayer(
          markers: [
            for (int i = 0; i < state.tutors.length; i++)
              Marker(
                point: LatLng(state.tutors[i].lat, state.tutors[i].lng),
                width: 50,
                height: 50,
                child: GestureDetector(
                  onTap: () => onPinTap(state.tutors[i], i),
                  child: MapPin(
                    tutor: state.tutors[i],
                    selected: state.tutors[i].tutorId == state.selectedTutorId,
                  ),
                ),
              ),
          ],
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
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
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
                    ? const _EmptyState()
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
        final size = sheetController.isAttached ? sheetController.size : _BottomSheet.initialSize;
        final isExpanded = size >= (_BottomSheet.initialSize + _BottomSheet.maxSize) / 2;
        final state = isExpanded ? l10n.mapSheetExpanded : l10n.mapSheetCollapsed;
        final action = isExpanded ? l10n.mapSheetActionCollapse : l10n.mapSheetActionExpand;
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
        final next = (sheetController.size - details.primaryDelta! / screenHeight)
            .clamp(_BottomSheet.minSize, _BottomSheet.maxSize);
        sheetController.jumpTo(next);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
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
                  Text(AppLocalizations.of(context).mapTutorCount(tutorCount),
                      style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  AnimatedBuilder(
                    animation: sheetController,
                    builder: (_, _) {
                      final t = sheetController.isAttached
                          ? ((sheetController.size - _BottomSheet.minSize) /
                                  (_BottomSheet.maxSize - _BottomSheet.minSize))
                              .clamp(0.0, 1.0)
                          : 0.0;
                      // 0 → expand-less (pointing up to invite expansion);
                      // 1 → expand-more (pointing down to invite collapse).
                      return Transform.rotate(
                        angle: t * 3.14159,
                        child: const Icon(Icons.expand_less,
                            color: AppColors.textSecondary),
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
                heroTag: 'fab-request',
                onPressed: () => context.push(AppRoutes.requestTutor),
                icon: const Icon(Icons.person_search_outlined),
                label: Text(AppLocalizations.of(context).mapRequestTutorFab),
              ),
              const SizedBox(height: AppSpacing.sm),
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
          child: SizedBox(
            height: 200,
            child: PageView.builder(
              controller: carouselController,
              padEnds: false,
              itemCount: state.tutors.length,
              itemBuilder: (context, i) {
                final t = state.tutors[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: TutorMapCard(
                    tutor: t,
                    selected: t.tutorId == state.selectedTutorId,
                    onTap: () => onCardTap(t, i),
                    onContact: () => onContact(t),
                  ),
                );
              },
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          sliver: SliverToBoxAdapter(
            child: Text(AppLocalizations.of(context).mapAllMatchesHeader),
          ),
        ),
        SliverList.builder(
          itemCount: state.tutors.length,
          itemBuilder: (context, i) {
            final t = state.tutors[i];
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.xs),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.mapEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.mapEmptyHint,
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

