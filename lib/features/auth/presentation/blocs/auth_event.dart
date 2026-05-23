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

class AuthOtpRequested extends AuthEvent {
  const AuthOtpRequested(this.code);
  final String code;

  @override
  List<Object?> get props => [code];
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
