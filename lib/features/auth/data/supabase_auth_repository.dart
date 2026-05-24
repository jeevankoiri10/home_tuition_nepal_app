import 'dart:async';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

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
  final StreamController<UserProfile?> _controller = StreamController<UserProfile?>.broadcast();
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

    final sb.AuthResponse res;
    try {
      res = await _client.auth.signUp(email: input.email, password: input.password);
    } on sb.AuthException catch (e) {
      throw AuthException('signup_failed', e.message);
    }

    final user = res.user;
    if (user == null) throw AuthException('signup_failed');

    final handle = _generateHandle(input.role);
    final now = DateTime.now().toUtc();
    final row = <String, dynamic>{
      'id': user.id,
      'first_name': input.firstName.trim(),
      'last_name': input.lastName.trim(),
      'email': input.email.trim(),
      'phone': '+977${input.phone.trim()}',
      'email_verified': user.emailConfirmedAt != null,
      'role': input.role.value,
      'handle': handle,
      'tos_accepted_at': now.toIso8601String(),
      'code_of_conduct_accepted_at':
          input.role == UserRole.tutor ? now.toIso8601String() : null,
      'coin_balance': 1000,
    };

    try {
      await _client.from('profiles').insert(row);
    } on sb.PostgrestException catch (e) {
      throw AuthException('profile_insert_failed', e.message);
    }

    await _loadProfile(user.id);
    return _user!;
  }

  @override
  Future<UserProfile> login({required String email, required String password}) async {
    try {
      final res = await _client.auth.signInWithPassword(email: email, password: password);
      if (res.user == null) throw AuthException('invalid_credentials');
      await _loadProfile(res.user!.id);
      return _user!;
    } on sb.AuthException catch (e) {
      throw AuthException('invalid_credentials', e.message);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _user;
    if (user == null) throw AuthException('no_session');
    try {
      await _client.auth.resend(
        type: sb.OtpType.signup,
        email: user.email,
      );
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
        await _client.from('profiles').update({'email_verified': true}).eq('id', user.id);
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
      await _client.from('profiles').update({'push_token': token}).eq('id', user.id);
    } on sb.PostgrestException catch (e) {
      throw AuthException('push_token_update_failed', e.message);
    }
  }

  @override
  Future<Set<UserRole>> availableRoles(String userId) async {
    try {
      // Each profiles row carries exactly one role today, but the query is
      // shaped so a future multi-role schema (one auth user → many profile
      // rows) naturally returns both without further client changes.
      final rows = await _client
          .from('profiles')
          .select('role')
          .eq('id', userId);
      return (rows as List)
          .cast<Map<String, dynamic>>()
          .map((r) => UserRole.values.firstWhere(
                (v) => v.value == (r['role'] as String?),
                orElse: () => UserRole.student,
              ))
          .toSet();
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
      final row = await _client.from('profiles').select().eq('id', id).maybeSingle();
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
    );
  }

  String _generateHandle(UserRole role) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random();
    final code = List<String>.generate(4, (_) => chars[rng.nextInt(chars.length)]).join();
    final prefix = role == UserRole.tutor ? 'Tutor' : 'Student';
    return '$prefix #$code';
  }
}
