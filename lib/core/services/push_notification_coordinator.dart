import 'dart:async';

import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/presentation/blocs/auth_bloc.dart';
import 'push_notification_service.dart';

/// Glues [PushNotificationService] to the rest of the app:
///   - On sign-in: ask the OS for a token and store it server-side so the
///     backend can fan out remote notifications to this device.
///   - On sign-out: release the OS token so the prior user stops receiving
///     pushes on this device. (The server-side `push_token` is cleared by
///     [AuthRepository.signOut].)
///   - On notification tap: deep-link into the matching feed item using the
///     same `ref_type` / `ref_id` convention the in-app feed uses.
///
/// When [PushNotificationService] is the [FakePushNotificationService] (the
/// default in dev) every method is a no-op — the wiring stays valid, so
/// swapping in a real Firebase-backed implementation requires no caller
/// changes.
class PushNotificationCoordinator {
  PushNotificationCoordinator({
    required PushNotificationService push,
    required AuthRepository auth,
    required AuthBloc authBloc,
    required GoRouter router,
  })  : _push = push,
        _auth = auth,
        _authBloc = authBloc,
        _router = router;

  final PushNotificationService _push;
  final AuthRepository _auth;
  final AuthBloc _authBloc;
  final GoRouter _router;

  StreamSubscription<AuthState>? _authSub;
  StreamSubscription<Map<String, dynamic>>? _tapSub;
  bool _registered = false;

  void start() {
    _tapSub = _push.onMessageOpened.listen(_handleTap);
    _authSub = _authBloc.stream.listen(_onAuthChanged);
    // Re-evaluate current state in case the user was already signed in
    // when the coordinator booted (e.g. cold start with a cached session).
    _onAuthChanged(_authBloc.state);
  }

  Future<void> dispose() async {
    await _authSub?.cancel();
    await _tapSub?.cancel();
  }

  Future<void> _onAuthChanged(AuthState state) async {
    if (state.status == AuthStatus.authenticated && state.user != null) {
      if (_registered) return;
      _registered = true;
      final token = await _push.requestPermissionAndGetToken();
      if (token != null) await _auth.setPushToken(token);
    } else if (state.status == AuthStatus.unauthenticated) {
      if (!_registered) return;
      _registered = false;
      await _push.deleteToken();
    }
  }

  void _handleTap(Map<String, dynamic> payload) {
    final refType = payload['ref_type'] as String?;
    final refId = payload['ref_id'] as String?;
    switch (refType) {
      case 'job':
        if (refId != null) {
          _router.push(AppRoutes.postDetail.replaceAll(':id', refId));
          return;
        }
        break;
      case 'vacancy':
        if (refId != null) {
          _router.push(AppRoutes.vacancyDetail.replaceAll(':id', refId));
          return;
        }
        break;
      case 'tutor':
        _router.push(AppRoutes.map);
        return;
      case 'notice':
        if (refId != null) {
          _router.push(AppRoutes.noticeDetail.replaceAll(':id', refId));
          return;
        }
        break;
    }
    // Unknown / no ref — fall back to the in-app feed so the user can see
    // why we pinged them.
    _router.push(AppRoutes.notifications);
  }
}
