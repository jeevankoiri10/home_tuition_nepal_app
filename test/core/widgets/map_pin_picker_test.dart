import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/app/di.dart';
import 'package:home_tuition_nepal_app/core/services/location_service.dart';
import 'package:home_tuition_nepal_app/core/widgets/map_pin_picker.dart';
import 'package:home_tuition_nepal_app/l10n/generated/app_localizations.dart';

/// Stubs [LocationService] so the picker's "Use my location" action resolves to
/// a chosen outcome without touching geolocator or the network.
class _FakeLocationService extends LocationService {
  _FakeLocationService(this.result);

  final LocationResult result;

  @override
  Future<LocationResult> resolveCurrent() async => result;

  @override
  Future<void> openLocationSettings() async {}

  @override
  Future<void> openAppSettings() async {}
}

Widget _host() => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SizedBox(
          width: 360,
          height: 480,
          child: MapPinPicker(
            initialLat: LocationService.fallbackLat,
            initialLng: LocationService.fallbackLng,
            onChanged: (_, _) {},
          ),
        ),
      ),
    );

/// Tap the locate FAB, then let the async resolve + SnackBar animation run.
Future<void> _tapLocate(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pump(); // resolve the (already-completed) future
  await tester.pump(const Duration(milliseconds: 400)); // SnackBar slides in
}

void main() {
  setUp(() {
    if (sl.isRegistered<LocationService>()) {
      sl.unregister<LocationService>();
    }
  });

  tearDown(() {
    if (sl.isRegistered<LocationService>()) {
      sl.unregister<LocationService>();
    }
  });

  void register(LocationResolution resolution) {
    sl.registerSingleton<LocationService>(
      _FakeLocationService(
        LocationResult(
          LocationService.fallbackLat,
          LocationService.fallbackLng,
          resolution,
        ),
      ),
    );
  }

  testWidgets('location services off → prompts to turn it on, with settings action',
      (tester) async {
    register(LocationResolution.servicesDisabled);
    await tester.pumpWidget(_host());
    await tester.pump(const Duration(milliseconds: 100));

    await _tapLocate(tester);

    expect(find.textContaining('Location is turned off'), findsOneWidget);
    expect(find.text('Open settings'), findsOneWidget);
  });

  testWidgets('permission blocked → guides to settings, with settings action',
      (tester) async {
    register(LocationResolution.permissionDeniedForever);
    await tester.pumpWidget(_host());
    await tester.pump(const Duration(milliseconds: 100));

    await _tapLocate(tester);

    expect(find.textContaining('Location permission is blocked'), findsOneWidget);
    expect(find.text('Open settings'), findsOneWidget);
  });

  testWidgets('permission denied → explains the fallback, no settings action',
      (tester) async {
    register(LocationResolution.permissionDenied);
    await tester.pumpWidget(_host());
    await tester.pump(const Duration(milliseconds: 100));

    await _tapLocate(tester);

    expect(find.textContaining('Location permission denied'), findsOneWidget);
    expect(find.text('Open settings'), findsNothing);
  });

  testWidgets('resolved fix → no feedback SnackBar', (tester) async {
    register(LocationResolution.resolved);
    await tester.pumpWidget(_host());
    await tester.pump(const Duration(milliseconds: 100));

    await _tapLocate(tester);

    expect(find.byType(SnackBar), findsNothing);
  });
}
