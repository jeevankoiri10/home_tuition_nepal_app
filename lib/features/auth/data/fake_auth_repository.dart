import 'dart:async';
import 'dart:math';

import '../domain/auth_repository.dart';
import '../domain/models/user_profile.dart';
import '../domain/models/user_role.dart';

/// In-memory AuthRepository for local development without Supabase credentials.
/// All operations succeed; `refreshEmailVerification` simulates the user
/// having clicked the confirmation link, so the demo flow is reachable
/// without a real mailbox.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository();

  final StreamController<UserProfile?> _controller =
      StreamController<UserProfile?>.broadcast();
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
      emailVerified: false,
      role: input.role,
      handle: handle,
      tosAcceptedAt: DateTime.now(),
      codeOfConductAcceptedAt: input.role == UserRole.tutor
          ? DateTime.now()
          : null,
      coinBalance: 1000,
      activeRole: input.role,
    );
    _user = profile;
    _controller.add(profile);
    return profile;
  }

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
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
      emailVerified: true,
      role: UserRole.student,
      handle: 'Student #DEMO',
      tosAcceptedAt: DateTime.now().subtract(const Duration(days: 30)),
      coinBalance: 1000,
      onboardingComplete: true,
      activeRole: UserRole.student,
      studentOnboarded: true,
    );
    _user = profile;
    _controller.add(profile);
    return profile;
  }

  @override
  Future<UserProfile> signInWithGoogle({required UserRole role}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final profile = UserProfile(
      id: 'fake-google-${DateTime.now().microsecondsSinceEpoch}',
      firstName: '',
      lastName: '',
      email: 'demo.${role.value}@gmail.com',
      phone: '',
      emailVerified: true,
      role: role,
      handle: _generateHandle(role),
      tosAcceptedAt: DateTime.now(),
      codeOfConductAcceptedAt: role == UserRole.tutor ? DateTime.now() : null,
      coinBalance: 1000,
      onboardingComplete: false,
      activeRole: role,
    );
    _user = profile;
    _controller.add(profile);
    return profile;
  }

  @override
  Future<UserProfile> saveOnboardingStep(int step) async {
    final updated = _user?.copyWith(onboardingStep: step);
    if (updated == null) throw AuthException('no_session');
    _user = updated;
    _controller.add(updated);
    return updated;
  }

  @override
  Future<UserProfile> completeStudentOnboarding({
    required String phone,
    required String whatsapp,
    required double lat,
    required double lng,
  }) async {
    final updated = _user?.copyWith(
      whatsapp: whatsapp,
      lat: lat,
      lng: lng,
      onboardingComplete: true,
      onboardingStep: 0,
      studentOnboarded: true,
    );
    if (updated == null) throw AuthException('no_session');
    _user = updated;
    _controller.add(updated);
    return updated;
  }

  @override
  Future<UserProfile> setTutorContact({
    required String phone,
    required String whatsapp,
  }) async {
    final updated = _user?.copyWith(whatsapp: whatsapp);
    if (updated == null) throw AuthException('no_session');
    _user = updated;
    _controller.add(updated);
    return updated;
  }

  @override
  Future<UserProfile> completeTutorOnboarding() async {
    final updated = _user?.copyWith(
      onboardingComplete: true,
      tutorOnboarded: true,
    );
    if (updated == null) throw AuthException('no_session');
    _user = updated;
    _controller.add(updated);
    return updated;
  }

  @override
  Future<UserProfile> switchActiveRole(UserRole role) async {
    final updated = _user?.copyWith(activeRole: role);
    if (updated == null) throw AuthException('no_session');
    _user = updated;
    _controller.add(updated);
    return updated;
  }

  @override
  Future<void> reloadProfile() async {
    // No backend — just re-emit the cached user.
    if (_user != null) _controller.add(_user);
  }

  @override
  Future<void> sendEmailVerification() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<UserProfile> refreshEmailVerification() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final updated = _user?.copyWith(emailVerified: true);
    if (updated == null) throw AuthException('no_session');
    _user = updated;
    _controller.add(updated);
    return updated;
  }

  @override
  Future<void> setPushToken(String? token) async {
    // Fake repo doesn't persist anything — push notifications are noop in
    // dev. See [SupabaseAuthRepository.setPushToken] for the real write.
  }

  @override
  Future<void> setLanguage(String languageCode) async {
    // Fake repo doesn't persist anything — see
    // [SupabaseAuthRepository.setLanguage] for the real write.
  }

  @override
  Future<Set<UserRole>> availableRoles(String userId) async {
    // Single-role schema today — the user has exactly the role they
    // registered with. The interface returns a Set so the chooser code
    // doesn't need to branch when the multi-role schema lands.
    final u = _user;
    if (u == null || u.id != userId) return const {};
    return {u.role};
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
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
