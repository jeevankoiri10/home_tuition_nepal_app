import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../features/auth/presentation/blocs/auth_bloc.dart';
import 'usage/usage_repository.dart';

/// Measures active foreground time and attributes it to the user's acting role
/// (tutor vs student/parent). While the app is foregrounded and the user is
/// signed in, it sends a heartbeat every [heartbeatInterval] that opens or
/// extends a usage session via [UsageRepository].
///
/// A foreground stretch is one session: backgrounding closes it (the next
/// resume starts a fresh one), and a role change also starts a new session so
/// dual-role accounts are attributed correctly. Depends on an auth-state
/// [Stream] + getter (not on `AuthBloc` directly) so it stays decoupled and
/// testable — mirrors `PushNotificationCoordinator`. Heartbeats are
/// best-effort: failures never disrupt the app.
class UsageTracker with WidgetsBindingObserver {
  UsageTracker({
    required UsageRepository repository,
    required Stream<AuthState> authStates,
    required AuthState Function() currentAuthState,
    Duration heartbeatInterval = const Duration(seconds: 30),
  })  : _repo = repository,
        _authStates = authStates,
        _currentAuthState = currentAuthState,
        _interval = heartbeatInterval;

  final UsageRepository _repo;
  final Stream<AuthState> _authStates;
  final AuthState Function() _currentAuthState;
  final Duration _interval;

  StreamSubscription<AuthState>? _authSub;
  Timer? _timer;
  String? _sessionId;
  String? _role;
  bool _foreground = true;
  bool _beatInFlight = false;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _authSub = _authStates.listen((_) => _evaluate());
    _evaluate();
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _authSub?.cancel();
    _stopTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground) {
      // End this foreground stretch; the next resume opens a new session.
      _stopTimer();
      _sessionId = null;
    }
    _evaluate();
  }

  /// The signed-in user's role string, or null when not authenticated.
  String? _activeRole() {
    final state = _currentAuthState();
    if (state.status != AuthStatus.authenticated || state.user == null) return null;
    return state.user!.role.value;
  }

  void _evaluate() {
    final role = _activeRole();
    if (role == null) {
      _stopTimer();
      _sessionId = null;
      _role = null;
      return;
    }
    if (role != _role) {
      _role = role;
      _sessionId = null; // role changed → fresh session
    }
    if (_foreground) {
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  void _startTimer() {
    if (_timer != null) return;
    _beat(); // emit one immediately so short sessions still register
    _timer = Timer.periodic(_interval, (_) => _beat());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _beat() async {
    if (_beatInFlight) return;
    final role = _role;
    if (role == null || !_foreground) return;
    _beatInFlight = true;
    try {
      final id = await _repo.touchSession(sessionId: _sessionId, role: role);
      if (id != null) _sessionId = id;
    } catch (_) {
      // Best-effort telemetry — swallow failures.
    } finally {
      _beatInFlight = false;
    }
  }
}
