part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => const [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested(this.input);
  final RegistrationInput input;

  @override
  List<Object?> get props => [input.email, input.role];
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object?> get props => [email];
}

/// User asked the backend to resend the confirmation email.
class AuthEmailVerificationResendRequested extends AuthEvent {
  const AuthEmailVerificationResendRequested();
}

/// User reports having clicked the confirmation link; refresh the session
/// to pick up the updated `emailVerified` flag.
class AuthEmailVerificationRefreshRequested extends AuthEvent {
  const AuthEmailVerificationRefreshRequested();
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class _AuthUserUpdated extends AuthEvent {
  const _AuthUserUpdated(this.user);
  final UserProfile? user;

  @override
  List<Object?> get props => [user];
}
