import 'package:geolocator/geolocator.dart';

/// Thin wrapper over `geolocator` so the rest of the app depends on an
/// interface, not the package directly. The fallback (Kathmandu Valley center)
/// is used when permission is denied or location services are off.
class LocationService {
  static const double fallbackLat = 27.7172; // Kathmandu
  static const double fallbackLng = 85.3240;

  Future<(double, double)> currentOrFallback() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return (fallbackLat, fallbackLng);

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return (fallbackLat, fallbackLng);
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      return (pos.latitude, pos.longitude);
    } catch (_) {
      return (fallbackLat, fallbackLng);
    }
  }
}
