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

  /// Sign in with Google in the chosen [role]. Until the Google provider is
  /// configured (Env.googleOAuthConfigured), this is stubbed via anonymous
  /// sign-in so the role-toggle + onboarding flow is testable end-to-end. The
  /// returned profile is a brand-new account with `onboardingComplete == false`.
  Future<UserProfile> signInWithGoogle({required UserRole role});

  /// Persist the onboarding step the user is currently on so a relaunch resumes
  /// at the same place. Mirrors `profiles.onboarding_step`.
  Future<UserProfile> saveOnboardingStep(int step);

  /// Save a student's contact + location and open the onboarding gate
  /// (`onboarding_complete = true`). Phone numbers are expected pre-formatted.
  Future<UserProfile> completeStudentOnboarding({
    required String phone,
    required String whatsapp,
    required double lat,
    required double lng,
  });

  /// Save a tutor's contact (phone + WhatsApp) during the onboarding wizard.
  Future<UserProfile> setTutorContact({
    required String phone,
    required String whatsapp,
  });

  /// Open the onboarding gate for a tutor who has finished the wizard.
  Future<UserProfile> completeTutorOnboarding();

  /// Re-fetch the signed-in user's profile from the backend and emit it on
  /// [currentUser]. Used by the blocked screen to detect reactivation without a
  /// full restart. No-op when there is no session.
  Future<void> reloadProfile();

  /// Switch which dashboard the account is currently acting as. Grants the
  /// target role to the account (so one email can be both tutor and student)
  /// and sets it active. Routing into a not-yet-onboarded role is handled by
  /// the router guard.
  Future<UserProfile> switchActiveRole(UserRole role);

  /// Resend the confirmation email to the user's registered address.
  Future<void> sendEmailVerification();

  /// Refresh the session and reload the profile. Returns the updated user
  /// with `emailVerified` reflecting the current backend state. Callers use
  /// this after the user reports clicking the confirmation link.
  Future<UserProfile> refreshEmailVerification();

  /// Persist (or clear) this device's push notification token on the user's
  /// profile so the server-side dispatcher can fan out to it. Passing null
  /// clears the token — typically on sign-out or when the user revokes
  /// notification permission. Safe to call when there's no signed-in user
  /// (the implementation will no-op).
  Future<void> setPushToken(String? token);

  /// Persist the user's preferred app language (`'en'` / `'ne'`) on their
  /// profile so server-side fan-outs (e.g. admin broadcasts) localize the
  /// notification text. Safe to call when signed out (no-ops).
  Future<void> setLanguage(String languageCode);

  /// Returns the set of roles this user account has profiles for. With the
  /// current single-role schema this is always a one-element set ({user.role});
  /// once the schema supports a single email backing both a tutor and a
  /// student profile, the set may contain two roles and the post-login
  /// chooser surfaces (see Phase 21).
  Future<Set<UserRole>> availableRoles(String userId);

  Future<void> signOut();
}
