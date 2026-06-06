import 'dart:async';

import 'package:flutter/foundation.dart';
// Hide gotrue's AuthState so the app's own AuthState (from auth_bloc) wins.
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../features/auth/presentation/blocs/auth_bloc.dart';

/// Live online/offline presence, free-tier only (no extra server).
///
/// Two halves:
///  1. **Realtime Presence** — joins one shared channel and `track`s the signed-in
///     user, exposing the set of currently-connected user ids via [online]. This
///     is ephemeral (in Supabase's Realtime service, no DB writes) and drives the
///     live green dots on the map and in chat.
///  2. **last_seen heartbeat** — every [_interval] it calls the `touch_last_seen`
///     RPC so other users can still see "last seen X ago" after disconnect.
///
/// Decoupled from `AuthBloc` (takes a stream + getter, like `UsageTracker`) and
/// best-effort: failures never disrupt the app. No-ops when [_client] is null
/// (the offline/fake build with no Supabase).
class PresenceService {
  PresenceService({
    required SupabaseClient? client,
    required Stream<AuthState> authStates,
    required AuthState Function() currentAuthState,
    Duration heartbeat = const Duration(seconds: 30),
  }) : _client = client,
       _authStates = authStates,
       _currentAuthState = currentAuthState,
       _interval = heartbeat;

  final SupabaseClient? _client;
  final Stream<AuthState> _authStates;
  final AuthState Function() _currentAuthState;
  final Duration _interval;

  /// User ids currently online, from Realtime Presence. Widgets listen to this.
  final ValueNotifier<Set<String>> online = ValueNotifier<Set<String>>(
    <String>{},
  );

  StreamSubscription<AuthState>? _authSub;
  RealtimeChannel? _channel;
  Timer? _timer;
  String? _trackedUserId;

  void start() {
    if (_client == null) return; // offline / fake build — presence disabled
    _authSub = _authStates.listen((_) => _evaluate());
    _evaluate();
  }

  Future<void> dispose() async {
    await _authSub?.cancel();
    await _disconnect();
  }

  bool isOnline(String userId) => online.value.contains(userId);

  String? _signedInUserId() {
    final s = _currentAuthState();
    if (s.status != AuthStatus.authenticated || s.user == null) return null;
    return s.user!.id;
  }

  void _evaluate() {
    final uid = _signedInUserId();
    if (uid == null) {
      _disconnect();
    } else if (uid != _trackedUserId) {
      _connect(uid);
    }
  }

  void _connect(String uid) {
    _disconnect();
    _trackedUserId = uid;
    final client = _client!;
    final channel = client.channel('online-users');
    channel
        .onPresenceSync((_) => _recompute(channel))
        .onPresenceJoin((_) => _recompute(channel))
        .onPresenceLeave((_) => _recompute(channel))
        .subscribe((status, _) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
            await channel.track({'user_id': uid});
          }
        });
    _channel = channel;
    _beat(); // stamp last_seen immediately, then on the interval
    _timer = Timer.periodic(_interval, (_) => _beat());
  }

  Future<void> _disconnect() async {
    _timer?.cancel();
    _timer = null;
    _trackedUserId = null;
    online.value = <String>{};
    final ch = _channel;
    _channel = null;
    if (ch != null) {
      try {
        await ch.untrack();
      } catch (_) {
        /* best-effort */
      }
      try {
        await _client!.removeChannel(ch);
      } catch (_) {
        /* best-effort */
      }
    }
  }

  void _recompute(RealtimeChannel channel) {
    final ids = <String>{};
    for (final state in channel.presenceState()) {
      for (final presence in state.presences) {
        final id = presence.payload['user_id'];
        if (id is String) ids.add(id);
      }
    }
    online.value = ids;
  }

  Future<void> _beat() async {
    try {
      await _client!.rpc('touch_last_seen');
    } catch (_) {
      /* best-effort telemetry */
    }
  }

  /// Another user's last-seen time, for "last seen X ago". Null when unknown.
  Future<DateTime?> lastSeenOf(String userId) async {
    final client = _client;
    if (client == null) return null;
    try {
      final row = await client
          .from('profiles')
          .select('last_seen')
          .eq('id', userId)
          .maybeSingle();
      final v = row?['last_seen'];
      return v is String ? DateTime.tryParse(v) : null;
    } catch (_) {
      return null;
    }
  }
}
