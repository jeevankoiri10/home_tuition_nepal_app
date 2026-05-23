import 'models/user_profile.dart';
import 'models/user_role.dart';

/// Data inputs for the email/password registration form (docs/plan.md §5.1).
class RegistrationInput {
  const RegistrationInput({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    required this.tosAccepted,
    required this.codeOfConductAccepted,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final UserRole role;
  final bool tosAccepted;
  final bool codeOfConductAccepted;
}

/// Thrown for any auth-related failure that should be surfaced to the user.
class AuthException implements Exception {
  AuthException(this.code, [this.message]);
  final String code;
  final String? message;

  @override
  String toString() => 'AuthException($code, $message)';
}

/// Pure abstraction over the auth backend. Implementations are swapped via
/// dependency injection — see lib/app/di.dart.
abstract class AuthRepository {
  Stream<UserProfile?> get currentUser;

  UserProfile? get cachedUser;

  Future<UserProfile> register(RegistrationInput input);

  Future<UserProfile> login({required String email, required String password});

  /// Send a 6-digit OTP to the user's stored phone number.
  Future<void> sendOtp();

  /// Verify the OTP. On success, flips phoneVerified=true and returns the
  /// updated profile.
  Future<UserProfile> verifyOtp(String code);

  Future<void> signOut();
}
