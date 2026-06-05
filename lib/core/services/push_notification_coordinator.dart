import 'dart:async';

import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/presentation/blocs/auth_bloc.dart';
import 'push_deep_link.dart';
import 'push_notification_service.dart';

/// Glues [PushNotificationService] to the rest of the app:
///   - On sign-in: ask the OS for a token and store it server-side so the
///     backend can fan out remote notifications to this device.
///   - On sign-out: release the OS token so the prior user stops receiving
///     pushes on this device. (The server-side `push_token` is cleared by
///     [AuthRepository.signOut].)
///   - On notification tap: deep-link via [resolvePushDeepLink] + the injected
///     [navigate] callback.
///
/// Depends on an auth-state [Stream] + a [navigate] port rather than on
/// `AuthBloc`/`GoRouter` directly, so it is decoupled from Flutter routing and
/// fully unit-testable. When [PushNotificationService] is the
/// [FakePushNotificationService] (dev default) every method is a no-op.
class PushNotificationCoordinator {
  PushNotificationCoordinator({
    required PushNotificationService push,
    required AuthRepository auth,
    required Stream<AuthState> authStates,
    required AuthState Function() currentAuthState,
    required void Function(String location) navigate,
  })  : _push = push,
        _auth = auth,
        _authStates = authStates,
        _currentAuthState = currentAuthState,
        _navigate = navigate;

  final PushNotificationService _push;
  final AuthRepository _auth;
  final Stream<AuthState> _authStates;
  final AuthState Function() _currentAuthState;
  final void Function(String location) _navigate;

  StreamSubscription<AuthState>? _authSub;
  StreamSubscription<Map<String, dynamic>>? _tapSub;
  bool _registered = false;

  void start() {
    _tapSub = _push.onMessageOpened.listen(_handleTap);
    _authSub = _authStates.listen(_onAuthChanged);
    // Re-evaluate current state in case the user was already signed in when
    // the coordinator booted (cold start with a cached session).
    _onAuthChanged(_currentAuthState());
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

  void _handleTap(Map<String, dynamic> payload) => _navigate(resolvePushDeepLink(payload));
}
