import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/auth_repository.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/user_role.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repo) : super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLoginRequested>(_onLogin);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthEmailVerificationResendRequested>(_onResendEmail);
    on<AuthEmailVerificationRefreshRequested>(_onRefreshEmail);
    on<AuthSignOutRequested>(_onSignOut);
    on<_AuthUserUpdated>(_onUserUpdated);

    _sub = _repo.currentUser.listen((u) => add(_AuthUserUpdated(u)));
  }

  final AuthRepository _repo;
  late final StreamSubscription<UserProfile?> _sub;

  /// Email verification only applies to email/password accounts. Externally-
  /// authenticated identities (Google / anonymous stub) have no email to
  /// confirm, so they are never parked on the verify-email screen.
  bool _needsEmailVerification(UserProfile u) =>
      u.email.isNotEmpty && !u.emailVerified;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final cached = _repo.cachedUser;
    if (cached == null) {
      emit(
        state.copyWith(status: AuthStatus.unauthenticated, clearError: true),
      );
    } else if (_needsEmailVerification(cached)) {
      emit(
        state.copyWith(
          status: AuthStatus.awaitingEmailVerification,
          user: cached,
          clearError: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: cached,
          clearError: true,
        ),
      );
    }
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.registering, clearError: true));
    try {
      final user = await _repo.register(event.input);
      // If the project auto-confirms emails (no confirmation required), the
      // account is already verified — go straight in instead of stranding the
      // user on the "verify your email" screen.
      if (user.emailVerified) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            clearError: true,
          ),
        );
      } else {
        // signUp already sent the confirmation email; this resend is a
        // best-effort nudge. Its failure (rate limit / SMTP) must NOT block the
        // user from reaching the verify-email screen.
        try {
          await _repo.sendEmailVerification();
        } catch (_) {
          /* non-fatal */
        }
        emit(
          state.copyWith(
            status: AuthStatus.awaitingEmailVerification,
            user: user,
            clearError: true,
          ),
        );
      }
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorCode: e.code));
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.error, errorCode: 'no_internet'));
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.registering, clearError: true));
    try {
      final user = await _repo.login(
        email: event.email,
        password: event.password,
      );
      if (!user.emailVerified) {
        try {
          await _repo.sendEmailVerification();
        } catch (_) {
          /* non-fatal — already-unverified login still reaches verify screen */
        }
        emit(
          state.copyWith(
            status: AuthStatus.awaitingEmailVerification,
            user: user,
            clearError: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            clearError: true,
          ),
        );
      }
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorCode: e.code));
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.error, errorCode: 'no_internet'));
    }
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.registering, clearError: true));
    try {
      // Google / anonymous identities are inherently verified — there is no
      // email confirmation step. The router guard routes the new account into
      // onboarding because onboardingComplete is false.
      final user = await _repo.signInWithGoogle(role: event.role);
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        ),
      );
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorCode: e.code));
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.error, errorCode: 'no_internet'));
    }
  }

  Future<void> _onResendEmail(
    AuthEmailVerificationResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _repo.sendEmailVerification();
    } on AuthException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorCode: e.code,
          user: state.user,
        ),
      );
    }
  }

  Future<void> _onRefreshEmail(
    AuthEmailVerificationRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.registering, clearError: true));
    try {
      final user = await _repo.refreshEmailVerification();
      if (user.emailVerified) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            clearError: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.awaitingEmailVerification,
            user: user,
            clearError: true,
          ),
        );
      }
    } on AuthException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorCode: e.code,
          user: state.user,
        ),
      );
    } catch (_) {
      // Network hiccup during the verification poll — stay put and let the
      // next poll retry instead of stranding the screen in a loading state.
      emit(
        state.copyWith(
          status: AuthStatus.awaitingEmailVerification,
          user: state.user,
          clearError: true,
        ),
      );
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repo.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void _onUserUpdated(_AuthUserUpdated event, Emitter<AuthState> emit) {
    final u = event.user;
    if (u == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } else if (_needsEmailVerification(u)) {
      emit(
        state.copyWith(status: AuthStatus.awaitingEmailVerification, user: u),
      );
    } else {
      emit(state.copyWith(status: AuthStatus.authenticated, user: u));
    }
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
