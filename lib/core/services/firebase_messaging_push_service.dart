import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'push_notification_service.dart';

/// Top-level background handler — required by firebase_messaging to be a
/// top-level (or static) function. Data-only handling is enough here: the
/// `notifications` row already exists server-side, and tapping a system-tray
/// banner is delivered through [FirebaseMessaging.onMessageOpenedApp].
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

/// Production [PushNotificationService] backed by Firebase Cloud Messaging.
/// Registered in `di.dart` only when `Env.pushNotificationsConfigured` is true
/// (and `Firebase.initializeApp` has run in `main.dart`). Otherwise the app
/// keeps using [FakePushNotificationService] and still surfaces notifications
/// live in-app via Supabase Realtime.
class FirebaseMessagingPushService implements PushNotificationService {
  FirebaseMessagingPushService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  final StreamController<Map<String, dynamic>> _opened =
      StreamController<Map<String, dynamic>>.broadcast();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'htn_default',
    'General notifications',
    description: 'Job matches, applications and announcements.',
    importance: Importance.high,
  );

  bool _wired = false;

  @override
  Future<String?> requestPermissionAndGetToken() async {
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return null;
    }
    await _wireListeners();
    return _messaging.getToken();
  }

  Future<void> _wireListeners() async {
    if (_wired) return;
    _wired = true;

    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
    await _local.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) _opened.add(_decode(payload));
      },
    );

    // Foreground messages don't show a system banner by default — render one
    // via flutter_local_notifications so the user always sees it.
    FirebaseMessaging.onMessage.listen(_showForeground);

    // App opened from a tapped banner (warm start).
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _opened.add(m.data));

    // App launched cold from a tapped banner.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _opened.add(initial.data);
  }

  void _showForeground(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: _encode(message.data),
    );
  }

  @override
  Stream<Map<String, dynamic>> get onMessageOpened => _opened.stream;

  @override
  Future<void> deleteToken() async {
    await _messaging.deleteToken();
  }

  // Payload is a flat string map; encode the two routing keys we rely on.
  static String _encode(Map<String, dynamic> data) =>
      '${data['ref_type'] ?? ''}|${data['ref_id'] ?? ''}';

  static Map<String, dynamic> _decode(String payload) {
    final parts = payload.split('|');
    return {
      'ref_type': parts.isNotEmpty ? parts[0] : '',
      'ref_id': parts.length > 1 ? parts[1] : '',
    };
  }
}
