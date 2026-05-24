/// Pure abstraction over the OS push channel (FCM today, possibly OneSignal
/// later). The Flutter app should:
///
///   1. Call [requestPermissionAndGetToken] after the user signs in (or on
///      first launch if you want a pre-auth prompt).
///   2. Pass the returned token to [AuthRepository.setPushToken] so the
///      server can fan-out remote notifications to this device.
///   3. Listen on [onMessageOpened] to deep-link into a feed item when the
///      user taps a notification.
///
/// Production wiring lives in a future `FirebaseMessagingPushService`
/// implementation — see docs/push_setup.md for the FCM steps. Until that
/// lands the [FakePushNotificationService] is used so callers can compile
/// and tests can assert against a stable stub.
abstract class PushNotificationService {
  /// Returns the device push token if the user grants permission, else null.
  /// Calling this multiple times is safe — implementations cache.
  Future<String?> requestPermissionAndGetToken();

  /// Emits one event per tap on a system-tray notification. Payload is the
  /// raw FCM `data` map (or the OneSignal equivalent) — callers translate
  /// `ref_type` / `ref_id` into a router push.
  Stream<Map<String, dynamic>> get onMessageOpened;

  /// Released on logout so we stop pinging this device for the prior user.
  Future<void> deleteToken();
}

/// No-op implementation used in dev (no Firebase credentials), in unit tests,
/// and as the default until [FirebaseMessagingPushService] lands. Stream is
/// broadcast so multiple listeners can subscribe safely.
class FakePushNotificationService implements PushNotificationService {
  @override
  Future<String?> requestPermissionAndGetToken() async => null;

  @override
  Stream<Map<String, dynamic>> get onMessageOpened => const Stream.empty();

  @override
  Future<void> deleteToken() async {}
}
