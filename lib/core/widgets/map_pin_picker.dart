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
  });

  final double initialLat;
  final double initialLng;
  final void Function(double lat, double lng) onChanged;
  final double? height;

  @override
  State<MapPinPicker> createState() => _MapPinPickerState();
}

class _MapPinPickerState extends State<MapPinPicker> {
  late final MapController _controller = MapController();
  bool _busy = false;

  Future<void> _useCurrentLocation() async {
    setState(() => _busy = true);
    final (lat, lng) = await sl<LocationService>().currentOrFallback();
    if (!mounted) return;
    setState(() => _busy = false);
    _controller.move(LatLng(lat, lng), _controller.camera.zoom);
    widget.onChanged(lat, lng);
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
              if (hasGesture) widget.onChanged(pos.center.latitude, pos.center.longitude);
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
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location),
          ),
        ),
      ],
    );
    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: content,
      ),
    );
  }
}
