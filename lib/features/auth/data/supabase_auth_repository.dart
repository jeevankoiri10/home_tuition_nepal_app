import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/config/env.dart';
import '../domain/auth_repository.dart';
import '../domain/models/user_profile.dart';
import '../domain/models/user_role.dart';

/// Real AuthRepository backed by Supabase. Requires SUPABASE_URL +
/// SUPABASE_ANON_KEY at build time (see lib/core/config/env.dart).
///
/// Email verification is delegated to Supabase Auth: `signUp` triggers the
/// confirmation email automatically, and the email is considered verified
/// once `auth.users.email_confirmed_at` is set. We mirror that into
/// `profiles.email_verified` so the rest of the app can read a single
/// canonical flag.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client) {
    _client.auth.onAuthStateChange.listen((event) async {
      final session = event.session;
      if (session == null) {
        _user = null;
        _controller.add(null);
      } else {
        await _loadProfile(session.user.id);
      }
    });
  }

  final sb.SupabaseClient _client;
  final StreamController<UserProfile?> _controller =
      StreamController<UserProfile?>.broadcast();
  UserProfile? _user;

  @override
  Stream<UserProfile?> get currentUser => _controller.stream;

  @override
  UserProfile? get cachedUser => _user;

  @override
  Future<UserProfile> register(RegistrationInput input) async {
    if (!input.tosAccepted) throw AuthException('tos_required');
    if (input.role == UserRole.tutor && !input.codeOfConductAccepted) {
      throw AuthException('coc_required');
    }

    final handle = _generateHandle(input.role);
    final now = DateTime.now().toUtc();
    final phone = '+977${input.phone.trim()}';

    final sb.AuthResponse res;
    try {
      // Pass profile fields as user metadata so the handle_new_user() trigger
      // (migration 0026) can create the profiles row server-side — reliable
      // even when email confirmation defers the client session.
      res = await _client.auth.signUp(
        email: input.email,
        password: input.password,
        data: {
          'first_name': input.firstName.trim(),
          'last_name': input.lastName.trim(),
          'phone': phone,
          'role': input.role.value,
          'handle': handle,
        },
      );
    } on AuthException {
      rethrow;
    } on sb.AuthApiException catch (e) {
      throw AuthException('signup_failed', e.message);
    } catch (e) {
      throw AuthException(
        _isNetworkError(e) ? 'no_internet' : 'signup_failed',
        e.toString(),
      );
    }

    final user = res.user;
    if (user == null) throw AuthException('signup_failed');

    // The profiles row (and its signup coin grant) is created server-side by
    // the handle_new_user() trigger (migration 0026) from the signup metadata
    // above — no client-side insert, so the balance/ledger stay server-managed.
    await _loadProfile(user.id);
    if (_user != null) return _user!;

    // No readable session yet (email confirmation pending): synthesize the
    // profile so the verify-email screen has a user. The real row loads once
    // the session is established after confirmation.
    return UserProfile(
      id: user.id,
      firstName: input.firstName.trim(),
      lastName: input.lastName.trim(),
      email: input.email.trim(),
      phone: phone,
      emailVerified: user.emailConfirmedAt != null,
      role: input.role,
      handle: handle,
      tosAcceptedAt: now,
      codeOfConductAcceptedAt: input.role == UserRole.tutor ? now : null,
      coinBalance: 1000,
    );
  }

  @override
  Future<UserProfile> signInWithGoogle({required UserRole role}) async {
    try {
      // Resolve an authenticated identity. The real Google flow opens an
      // external browser and the session only arrives later via the redirect
      // deep link, so we must AWAIT that session instead of reading
      // currentUser synchronously (which would still be null and throw). The
      // stub path (anonymous sign-in) resolves immediately.
      final sb.User user;
      if (Env.googleOAuthConfigured) {
        user = await _signInWithGoogleOAuth();
      } else {
        // Stub: a real, confirmed session without external config. The
        // handle_new_user() trigger (0026) provisions the profiles row.
        await _client.auth.signInAnonymously();
        final stubUser = _client.auth.currentUser;
        if (stubUser == null) throw AuthException('signin_failed');
        user = stubUser;
      }

      // Apply the chosen role exactly once. set_my_role is a server-side no-op
      // when onboarding_complete is already true (migration 0029), so a
      // RETURNING user keeps their existing role and finished onboarding and is
      // routed straight to their dashboard — they never see onboarding again.
      // Only a brand-new account is promoted into the chosen role (and marked
      // verified) and then sent through onboarding by the router guard.
      await _client.rpc('set_my_role', params: {'p_role': role.value});
      await _loadProfile(user.id);
      final u = _user;
      if (u == null) throw AuthException('signin_failed');
      return u;
    } on AuthException {
      rethrow;
    } on sb.AuthApiException catch (e) {
      throw AuthException('signin_failed', e.message);
    } catch (e) {
      throw AuthException(
        _isNetworkError(e) ? 'no_internet' : 'signin_failed',
        e.toString(),
      );
    }
  }

  /// Drives the external Google OAuth handshake and completes only once the
  /// redirect delivers a signed-in session.
  ///
  /// [signInWithOAuth] merely LAUNCHES the browser (it returns as soon as the
  /// tab opens); Supabase delivers the resulting session asynchronously to
  /// [onAuthStateChange] when Google redirects back to [Env.googleOAuthRedirect].
  /// Awaiting that event is what lets the caller apply the role and load the
  /// profile against a real session rather than a null `currentUser`.
  Future<sb.User> _signInWithGoogleOAuth() async {
    // Already authenticated (e.g. a session survived from a prior launch) —
    // reuse it rather than launching a redundant browser handshake.
    final existing = _client.auth.currentSession?.user;
    if (existing != null) return existing;

    final completer = Completer<sb.User>();
    late final StreamSubscription<sb.AuthState> sub;
    sub = _client.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      if (session != null &&
          event.event == sb.AuthChangeEvent.signedIn &&
          !completer.isCompleted) {
        completer.complete(session.user);
      }
    });

    try {
      final launched = await _client.auth.signInWithOAuth(
        sb.OAuthProvider.google,
        redirectTo: Env.googleOAuthRedirect,
      );
      if (!launched) throw AuthException('signin_cancelled');
      // The browser is open; wait for the redirect to bring the session back.
      // Bounded so a user who abandons the browser isn't left hanging forever.
      // A timeout is distinct from a cancel: the user may simply have been slow,
      // so it gets its own code and a "took too long" message rather than the
      // "you cancelled" one.
      return await completer.future.timeout(
        const Duration(minutes: 3),
        onTimeout: () => throw AuthException('signin_timeout'),
      );
    } finally {
      await sub.cancel();
    }
  }

  @override
  Future<UserProfile> saveOnboardingStep(int step) async {
    final user = _user;
    if (user == null) throw AuthException('no_session');
    try {
      await _client
          .from('profiles')
          .update({'onboarding_step': step})
          .eq('id', user.id);
      await _loadProfile(user.id);
      return _user ?? user;
    } on sb.PostgrestException catch (e) {
      throw AuthException('onboarding_step_failed', e.message);
    }
  }

  @override
  Future<UserProfile> completeStudentOnboarding({
    required String phone,
    required String whatsapp,
    required double lat,
    required double lng,
  }) async {
    return _runOnboardingRpc('complete_student_onboarding', {
      'p_phone': phone,
      'p_whatsapp': whatsapp,
      'p_lat': lat,
      'p_lng': lng,
    });
  }

  @override
  Future<UserProfile> setTutorContact({
    required String phone,
    required String whatsapp,
  }) async {
    return _runOnboardingRpc('set_tutor_contact', {
      'p_phone': phone,
      'p_whatsapp': whatsapp,
    });
  }

  @override
  Future<UserProfile> completeTutorOnboarding() async {
    return _runOnboardingRpc('complete_tutor_onboarding', const {});
  }

  @override
  Future<UserProfile> switchActiveRole(UserRole role) async {
    return _runOnboardingRpc('switch_active_role', {'p_role': role.value});
  }

  @override
  Future<void> reloadProfile() async {
    final id = _client.auth.currentUser?.id;
    if (id == null) return;
    await _loadProfile(id);
  }

  /// Call an onboarding RPC then reload the profile so the cached user (and the
  /// router guard listening on [currentUser]) reflect the new state immediately.
  Future<UserProfile> _runOnboardingRpc(
    String fn,
    Map<String, dynamic> params,
  ) async {
    final user = _user;
    if (user == null) throw AuthException('no_session');
    try {
      await _client.rpc(fn, params: params);
      await _loadProfile(user.id);
      return _user ?? user;
    } on sb.PostgrestException catch (e) {
      throw AuthException('onboarding_save_failed', e.message);
    }
  }

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user == null) throw AuthException('invalid_credentials');
      await _loadProfile(res.user!.id);
      final u = _user;
      if (u == null) throw AuthException('invalid_credentials');
      return u;
    } on AuthException {
      rethrow;
    } on sb.AuthApiException catch (e) {
      // A real API rejection (e.g. 400 invalid credentials, email not confirmed).
      throw AuthException('invalid_credentials', e.message);
    } catch (e) {
      // Network failure or anything unexpected — never leave the caller hanging.
      throw AuthException(
        _isNetworkError(e) ? 'no_internet' : 'unknown',
        e.toString(),
      );
    }
  }

  /// True when [e] looks like a connectivity failure (no internet / DNS / reset)
  /// rather than a real auth rejection.
  bool _isNetworkError(Object e) {
    if (e is SocketException) return true;
    final s = e.toString();
    return s.contains('SocketException') ||
        s.contains('Failed host lookup') ||
        s.contains('ClientException') ||
        s.contains('AuthRetryableFetchException') ||
        s.contains('Connection');
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _user;
    if (user == null) throw AuthException('no_session');
    try {
      await _client.auth.resend(type: sb.OtpType.signup, email: user.email);
    } on sb.AuthException catch (e) {
      throw AuthException('email_send_failed', e.message);
    }
  }

  @override
  Future<UserProfile> refreshEmailVerification() async {
    final user = _user;
    if (user == null) throw AuthException('no_session');
    try {
      final res = await _client.auth.refreshSession();
      final authUser = res.user;
      final confirmed = authUser?.emailConfirmedAt != null;
      if (confirmed) {
        await _client
            .from('profiles')
            .update({'email_verified': true})
            .eq('id', user.id);
      }
      await _loadProfile(user.id);
      return _user!;
    } on sb.AuthException catch (e) {
      throw AuthException('refresh_failed', e.message);
    }
  }

  @override
  Future<void> setPushToken(String? token) async {
    final user = _user;
    if (user == null) return;
    try {
      await _client
          .from('profiles')
          .update({'push_token': token})
          .eq('id', user.id);
    } on sb.PostgrestException catch (e) {
      throw AuthException('push_token_update_failed', e.message);
    }
  }

  @override
  Future<void> setLanguage(String languageCode) async {
    final user = _user;
    if (user == null) return;
    try {
      await _client
          .from('profiles')
          .update({'language': languageCode})
          .eq('id', user.id);
    } on sb.PostgrestException catch (e) {
      throw AuthException('language_update_failed', e.message);
    }
  }

  @override
  Future<Set<UserRole>> availableRoles(String userId) async {
    try {
      // account_roles holds every role this user may enter the app as
      // (migration 0023). One row → auto-route; two → the login chooser.
      final rows = await _client
          .from('account_roles')
          .select('role')
          .eq('user_id', userId);
      final roles = (rows as List)
          .cast<Map<String, dynamic>>()
          .map((r) => UserRole.fromString((r['role'] as String?) ?? 'student'))
          .toSet();
      if (roles.isNotEmpty) return roles;
      // Fallback for a profile created before account_roles was seeded.
      final profile = await _client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();
      if (profile == null) return const <UserRole>{};
      return {UserRole.fromString((profile['role'] as String?) ?? 'student')};
    } on sb.PostgrestException catch (e) {
      throw AuthException('available_roles_failed', e.message);
    }
  }

  @override
  Future<void> signOut() async {
    // Clear the token first so the dispatcher stops trying to send to a
    // device the user has abandoned. Don't fail the sign-out if this errors.
    try {
      await setPushToken(null);
    } on AuthException {
      // best-effort
    }
    await _client.auth.signOut();
    _user = null;
    _controller.add(null);
  }

  Future<void> _loadProfile(String id) async {
    try {
      final row = await _client
          .from('profiles')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (row == null) {
        _user = null;
        _controller.add(null);
        return;
      }
      _user = _profileFromRow(row);
      _controller.add(_user);
    } on sb.PostgrestException catch (e) {
      throw AuthException('profile_load_failed', e.message);
    }
  }

  UserProfile _profileFromRow(Map<String, dynamic> row) {
    return UserProfile(
      id: row['id'] as String,
      firstName: (row['first_name'] as String?) ?? '',
      lastName: (row['last_name'] as String?) ?? '',
      email: (row['email'] as String?) ?? '',
      phone: (row['phone'] as String?) ?? '',
      emailVerified: (row['email_verified'] as bool?) ?? false,
      role: UserRole.fromString((row['role'] as String?) ?? 'student'),
      handle: (row['handle'] as String?) ?? '',
      tosAcceptedAt: DateTime.parse(row['tos_accepted_at'] as String),
      codeOfConductAcceptedAt: row['code_of_conduct_accepted_at'] == null
          ? null
          : DateTime.parse(row['code_of_conduct_accepted_at'] as String),
      coinBalance: (row['coin_balance'] as int?) ?? 0,
      whatsapp: row['whatsapp'] as String?,
      lat: (row['lat'] as num?)?.toDouble(),
      lng: (row['lng'] as num?)?.toDouble(),
      onboardingComplete: (row['onboarding_complete'] as bool?) ?? false,
      onboardingStep: (row['onboarding_step'] as int?) ?? 0,
      activeRole: UserRole.fromString(
        (row['active_role'] as String?) ??
            (row['role'] as String?) ??
            'student',
      ),
      tutorOnboarded: (row['tutor_onboarded'] as bool?) ?? false,
      studentOnboarded: (row['student_onboarded'] as bool?) ?? false,
      isBlocked: row['banned_at'] != null,
    );
  }

  String _generateHandle(UserRole role) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random();
    final code = List<String>.generate(
      4,
      (_) => chars[rng.nextInt(chars.length)],
    ).join();
    final prefix = role == UserRole.tutor ? 'Tutor' : 'Student';
    return '$prefix #$code';
  }
}
