import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/app/router.dart';
import 'package:home_tuition_nepal_app/core/services/push_notification_coordinator.dart';
import 'package:home_tuition_nepal_app/core/services/push_notification_service.dart';
import 'package:home_tuition_nepal_app/features/auth/data/fake_auth_repository.dart';
import 'package:home_tuition_nepal_app/features/auth/domain/models/user_profile.dart';
import 'package:home_tuition_nepal_app/features/auth/domain/models/user_role.dart';
import 'package:home_tuition_nepal_app/features/auth/presentation/blocs/auth_bloc.dart';

/// Push service stub that hands out a fixed token and records deleteToken.
class _RecordingPush implements PushNotificationService {
  _RecordingPush(this._taps);
  final StreamController<Map<String, dynamic>> _taps;
  int deleteTokenCalls = 0;
  int tokenRequests = 0;

  @override
  Future<String?> requestPermissionAndGetToken() async {
    tokenRequests++;
    return 'token-123';
  }

  @override
  Stream<Map<String, dynamic>> get onMessageOpened => _taps.stream;

  @override
  Future<void> deleteToken() async => deleteTokenCalls++;
}

/// Auth repo that records the last push token written.
class _RecordingAuthRepo extends FakeAuthRepository {
  String? lastToken;
  bool tokenCleared = false;

  @override
  Future<void> setPushToken(String? token) async {
    lastToken = token;
    if (token == null) tokenCleared = true;
  }
}

UserProfile _user() => UserProfile(
      id: 'u1',
      firstName: 'A',
      lastName: 'B',
      email: 'a@b.co',
      phone: '+9779800000000',
      emailVerified: true,
      role: UserRole.student,
      handle: 'ab123',
      tosAcceptedAt: DateTime(2026, 1, 1),
    );

void main() {
  group('PushNotificationCoordinator', () {
    late StreamController<AuthState> auth;
    late StreamController<Map<String, dynamic>> taps;
    late _RecordingPush push;
    late _RecordingAuthRepo repo;
    late List<String> navigations;
    late AuthState current;
    late PushNotificationCoordinator coord;

    setUp(() {
      auth = StreamController<AuthState>.broadcast();
      taps = StreamController<Map<String, dynamic>>.broadcast();
      push = _RecordingPush(taps);
      repo = _RecordingAuthRepo();
      navigations = [];
      current = const AuthState();
      coord = PushNotificationCoordinator(
        push: push,
        auth: repo,
        authStates: auth.stream,
        currentAuthState: () => current,
        navigate: navigations.add,
      )..start();
    });

    tearDown(() async {
      await coord.dispose();
      await auth.close();
      await taps.close();
    });

    test('registers the OS token server-side on sign-in', () async {
      auth.add(AuthState(status: AuthStatus.authenticated, user: _user()));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(push.tokenRequests, 1);
      expect(repo.lastToken, 'token-123');
    });

    test('does not re-register while already signed in', () async {
      auth.add(AuthState(status: AuthStatus.authenticated, user: _user()));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      auth.add(AuthState(status: AuthStatus.authenticated, user: _user()));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(push.tokenRequests, 1);
    });

    test('releases the OS token on sign-out', () async {
      auth.add(AuthState(status: AuthStatus.authenticated, user: _user()));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      auth.add(const AuthState(status: AuthStatus.unauthenticated));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(push.deleteTokenCalls, 1);
    });

    test('a notification tap deep-links via the navigate callback', () async {
      taps.add({'ref_type': 'vacancy', 'ref_id': 'v9'});
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(navigations, [AppRoutes.vacancyDetail.replaceAll(':id', 'v9')]);
    });
  });
}
