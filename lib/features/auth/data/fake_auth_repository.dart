import 'dart:async';
import 'dart:math';

import '../domain/auth_repository.dart';
import '../domain/models/user_profile.dart';
import '../domain/models/user_role.dart';

/// In-memory AuthRepository for local development without Supabase credentials.
/// All operations succeed; the OTP is fixed to '123456' so the flow is
/// demonstrable without an SMS provider.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository();

  static const String demoOtp = '123456';

  final StreamController<UserProfile?> _controller = StreamController<UserProfile?>.broadcast();
  UserProfile? _user;

  @override
  Stream<UserProfile?> get currentUser => _controller.stream;

  @override
  UserProfile? get cachedUser => _user;

  @override
  Future<UserProfile> register(RegistrationInput input) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!input.tosAccepted) throw AuthException('tos_required');
    if (input.role == UserRole.tutor && !input.codeOfConductAccepted) {
      throw AuthException('coc_required');
    }
    final handle = _generateHandle(input.role);
    final profile = UserProfile(
      id: 'fake-${DateTime.now().microsecondsSinceEpoch}',
      firstName: input.firstName.trim(),
      lastName: input.lastName.trim(),
      email: input.email.trim(),
      phone: '+977${input.phone.trim()}',
      phoneVerified: false,
      role: input.role,
      handle: handle,
      tosAcceptedAt: DateTime.now(),
      codeOfConductAcceptedAt: input.role == UserRole.tutor ? DateTime.now() : null,
      coinBalance: 1000,
    );
    _user = profile;
    _controller.add(profile);
    return profile;
  }

  @override
  Future<UserProfile> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (email.isEmpty || password.length < 8) {
      throw AuthException('invalid_credentials');
    }
    final profile = UserProfile(
      id: 'fake-login',
      firstName: 'Demo',
      lastName: 'User',
      email: email,
      phone: '+9779800000000',
      phoneVerified: true,
      role: UserRole.student,
      handle: 'Student #DEMO',
      tosAcceptedAt: DateTime.now().subtract(const Duration(days: 30)),
      coinBalance: 1000,
    );
    _user = profile;
    _controller.add(profile);
    return profile;
  }

  @override
  Future<void> sendOtp() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<UserProfile> verifyOtp(String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (code != demoOtp) throw AuthException('invalid_otp');
    final updated = _user?.copyWith(phoneVerified: true);
    if (updated == null) throw AuthException('no_session');
    _user = updated;
    _controller.add(updated);
    return updated;
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }

  String _generateHandle(UserRole role) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random();
    final code = List<String>.generate(4, (_) => chars[rng.nextInt(chars.length)]).join();
    final prefix = role == UserRole.tutor ? 'Tutor' : 'Student';
    return '$prefix #$code';
  }
}
