import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/auth_repository.dart';
import '../../domain/models/user_profile.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repo) : super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLoginRequested>(_onLogin);
    on<AuthOtpRequested>(_onVerifyOtp);
    on<AuthSignOutRequested>(_onSignOut);
    on<_AuthUserUpdated>(_onUserUpdated);

    _sub = _repo.currentUser.listen((u) => add(_AuthUserUpdated(u)));
  }

  final AuthRepository _repo;
  late final StreamSubscription<UserProfile?> _sub;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final cached = _repo.cachedUser;
    if (cached == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, clearError: true));
    } else if (!cached.phoneVerified) {
      emit(state.copyWith(status: AuthStatus.awaitingOtp, user: cached, clearError: true));
    } else {
      emit(state.copyWith(status: AuthStatus.authenticated, user: cached, clearError: true));
    }
  }

  Future<void> _onRegister(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.registering, clearError: true));
    try {
      final user = await _repo.register(event.input);
      await _repo.sendOtp();
      emit(state.copyWith(status: AuthStatus.awaitingOtp, user: user, clearError: true));
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorCode: e.code));
    }
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.registering, clearError: true));
    try {
      final user = await _repo.login(email: event.email, password: event.password);
      if (!user.phoneVerified) {
        await _repo.sendOtp();
        emit(state.copyWith(status: AuthStatus.awaitingOtp, user: user, clearError: true));
      } else {
        emit(state.copyWith(status: AuthStatus.authenticated, user: user, clearError: true));
      }
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorCode: e.code));
    }
  }

  Future<void> _onVerifyOtp(AuthOtpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.registering, clearError: true));
    try {
      final user = await _repo.verifyOtp(event.code);
      emit(state.copyWith(status: AuthStatus.authenticated, user: user, clearError: true));
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorCode: e.code, user: state.user));
    }
  }

  Future<void> _onSignOut(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await _repo.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void _onUserUpdated(_AuthUserUpdated event, Emitter<AuthState> emit) {
    final u = event.user;
    if (u == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } else if (!u.phoneVerified) {
      emit(state.copyWith(status: AuthStatus.awaitingOtp, user: u));
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
