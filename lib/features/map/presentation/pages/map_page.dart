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
        return Scaffold(
          appBar: AppBar(
            title: const Text('Tutors near you'),
            actions: [
              const NotificationBell(),
              IconButton(
                tooltip: 'My posts',
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
                tooltip: 'Re-center',
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
                    Positioned(
                      left: AppSpacing.lg,
                      bottom: 220,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FloatingActionButton.extended(
                            heroTag: 'fab-request',
                            onPressed: () => context.push(AppRoutes.requestTutor),
                            icon: const Icon(Icons.person_search_outlined),
                            label: const Text('Request a tutor'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          FloatingActionButton.extended(
                            heroTag: 'fab-post-job',
                            onPressed: () => context.push(AppRoutes.postJob),
                            icon: const Icon(Icons.post_add_outlined),
                            label: const Text('Post a job'),
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
        onTap: (_, __) => onTap(),
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

  final DraggableScrollableController controller;
  final MapState state;
  final PageController carouselController;
  final void Function(MapTutor, int) onCardTap;
  final void Function(MapTutor) onContact;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: 0.32,
      minChildSize: 0.18,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.32, 0.85],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Text('${state.tutors.length} tutors',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    const Icon(Icons.expand_less, color: AppColors.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
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
    return CustomScrollView(
      controller: scrollController,
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
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          sliver: SliverToBoxAdapter(child: Text('All matches')),
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
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text('No tutors match your filters',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Try widening the radius or loosening filters.',
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

