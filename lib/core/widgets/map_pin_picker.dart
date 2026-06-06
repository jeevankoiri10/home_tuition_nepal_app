import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../app/di.dart';
import '../../l10n/generated/app_localizations.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Reusable OpenStreetMap-backed location picker.
///
/// Renders a flutter_map with a fixed centre pin; the parent receives a new
/// `(lat, lng)` on every camera idle (so the spot the pin is sitting on is
/// the user's selection). A "Use my location" FAB falls back to the
/// [LocationService] (Kathmandu Valley if permissions are denied).
class MapPinPicker extends StatefulWidget {
  const MapPinPicker({
    super.key,
    required this.initialLat,
    required this.initialLng,
    required this.onChanged,
    this.height,
    this.showSelectButton = false,
  });

  final double initialLat;
  final double initialLng;
  final void Function(double lat, double lng) onChanged;
  final double? height;

  /// When true, renders a labelled "Select my location" button beneath the map
  /// (in addition to the in-map locate FAB). Used by the onboarding location
  /// steps where an explicit confirm-my-spot action is expected.
  final bool showSelectButton;

  @override
  State<MapPinPicker> createState() => _MapPinPickerState();
}

class _MapPinPickerState extends State<MapPinPicker> {
  late final MapController _controller = MapController();
  bool _busy = false;

  Future<void> _useCurrentLocation() async {
    setState(() => _busy = true);
    final service = sl<LocationService>();
    final result = await service.resolveCurrent();
    if (!mounted) return;
    setState(() => _busy = false);
    _controller.move(
      LatLng(result.latitude, result.longitude),
      _controller.camera.zoom,
    );
    widget.onChanged(result.latitude, result.longitude);
    if (!result.isResolved) {
      _showFallbackFeedback(service, result.resolution);
    }
  }

  /// When we couldn't get a real fix, tell the user why (and offer a route to
  /// fix it) instead of silently dropping the pin on the Kathmandu fallback.
  void _showFallbackFeedback(
    LocationService service,
    LocationResolution resolution,
  ) {
    final l10n = AppLocalizations.of(context);
    final (String? message, SnackBarAction? action) = switch (resolution) {
      LocationResolution.servicesDisabled => (
        l10n.locationServicesDisabledMessage,
        SnackBarAction(
          label: l10n.openSettingsAction,
          onPressed: service.openLocationSettings,
        ),
      ),
      LocationResolution.permissionDeniedForever => (
        l10n.locationPermissionBlockedMessage,
        SnackBarAction(
          label: l10n.openSettingsAction,
          onPressed: service.openAppSettings,
        ),
      ),
      LocationResolution.permissionDenied => (
        l10n.locationPermissionDeniedMessage,
        null,
      ),
      LocationResolution.unavailable => (l10n.locationUnavailableMessage, null),
      LocationResolution.resolved => (null, null),
    };
    if (message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), action: action),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final content = Stack(
      alignment: Alignment.center,
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: LatLng(widget.initialLat, widget.initialLng),
            initialZoom: 14,
            onPositionChanged: (pos, hasGesture) {
              if (hasGesture) {
                widget.onChanged(pos.center.latitude, pos.center.longitude);
              }
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
          ],
        ),
        // Centre pin — sits above the map at the viewport center, so the
        // user's selection equals whatever the map is showing.
        IgnorePointer(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Icon(Icons.location_on, color: AppColors.primary, size: 40),
          ),
        ),
        Positioned(
          right: AppSpacing.md,
          bottom: AppSpacing.md,
          child: FloatingActionButton.small(
            heroTag: 'map-pin-picker-current-loc',
            tooltip: l10n.mapPinPickerUseMyLocation,
            onPressed: _busy ? null : _useCurrentLocation,
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
          ),
        ),
      ],
    );
    final map = SizedBox(
      height: widget.height,
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: content),
    );
    if (!widget.showSelectButton) return map;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        map,
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: _busy ? null : _useCurrentLocation,
          icon: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
          label: Text(l10n.onboardingSelectMyLocation),
        ),
      ],
    );
  }
}
