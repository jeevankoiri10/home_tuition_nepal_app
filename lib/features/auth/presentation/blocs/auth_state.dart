part of 'auth_bloc.dart';

enum AuthStatus {
  unknown,
  unauthenticated,
  registering,
  awaitingOtp,
  authenticated,
  error,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.errorCode,
  });

  final AuthStatus status;
  final UserProfile? user;
  final String? errorCode;

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? user,
    String? errorCode,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
    );
  }

  @override
  List<Object?> get props => [status, user, errorCode];
}
