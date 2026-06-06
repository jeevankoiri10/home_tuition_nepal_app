import 'package:geolocator/geolocator.dart';

/// Why a location lookup ended where it did. The UI uses this to decide
/// whether to stay silent (we got a real fix) or guide the user
/// (services off / permission blocked) instead of quietly using the
/// Kathmandu fallback.
enum LocationResolution {
  /// A real device position was obtained.
  resolved,

  /// Device location services (GPS) are turned off system-wide.
  servicesDisabled,

  /// Permission was denied this time, but can be requested again later.
  permissionDenied,

  /// Permission is blocked for good — only re-enableable from app settings.
  permissionDeniedForever,

  /// Lookup failed or timed out (e.g. no fix indoors).
  unavailable,
}

/// Outcome of a location lookup: always carries usable coordinates (the real
/// fix when [resolution] is [LocationResolution.resolved], the Kathmandu
/// fallback otherwise) plus the reason, so callers can react.
class LocationResult {
  const LocationResult(this.latitude, this.longitude, this.resolution);

  final double latitude;
  final double longitude;
  final LocationResolution resolution;

  bool get isResolved => resolution == LocationResolution.resolved;
}

/// Thin wrapper over `geolocator` so the rest of the app depends on an
/// interface, not the package directly. The fallback (Kathmandu Valley center)
/// is used when location services are off, permission is denied, or a fix
/// can't be obtained.
class LocationService {
  static const double fallbackLat = 27.7172; // Kathmandu
  static const double fallbackLng = 85.3240;

  /// How long to wait for a fix before falling back, so an indoor device that
  /// never gets a GPS lock doesn't leave the UI spinning indefinitely.
  static const Duration _fixTimeout = Duration(seconds: 10);

  /// Resolve the current position, reporting why if it can't. Requests
  /// permission when it hasn't been decided yet — so a caller tied to an
  /// explicit user action (e.g. "Use my location") triggers the OS prompt.
  Future<LocationResult> resolveCurrent() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _fallback(LocationResolution.servicesDisabled);
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return _fallback(LocationResolution.permissionDeniedForever);
      }
      if (permission == LocationPermission.denied) {
        return _fallback(LocationResolution.permissionDenied);
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: _fixTimeout,
        ),
      );
      return LocationResult(
        pos.latitude,
        pos.longitude,
        LocationResolution.resolved,
      );
    } catch (_) {
      return _fallback(LocationResolution.unavailable);
    }
  }

  /// Coordinates-only convenience for callers that auto-center a map and don't
  /// surface permission feedback (e.g. the browse map on load).
  Future<(double, double)> currentOrFallback() async {
    final result = await resolveCurrent();
    return (result.latitude, result.longitude);
  }

  /// Open the system location-services screen (to turn GPS back on).
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  /// Open this app's settings screen (to grant a permanently-denied
  /// permission).
  Future<void> openAppSettings() => Geolocator.openAppSettings();

  LocationResult _fallback(LocationResolution reason) =>
      LocationResult(fallbackLat, fallbackLng, reason);
}
