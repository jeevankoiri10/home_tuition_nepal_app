import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/app_notification.dart';
import '../../domain/notifications_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc(this._repo) : super(const NotificationsState()) {
    on<NotificationsLoaded>(_onLoad);
    on<NotificationsRefreshed>(_onRefresh);
    on<NotificationsFilterChanged>(_onFilter);
    on<NotificationsRead>(_onRead);
    on<NotificationsAllRead>(_onAllRead);
    on<_NotificationsInserted>(_onInserted);
  }

  final NotificationsRepository _repo;
  String? _userId;
  StreamSubscription<AppNotification>? _sub;

  Future<void> _onLoad(NotificationsLoaded e, Emitter<NotificationsState> emit) async {
    _userId = e.userId;
    await _reload(emit);
    _sub?.cancel();
    _sub = _repo.watchInserts(e.userId).listen((n) => add(_NotificationsInserted(n)));
  }

  Future<void> _onRefresh(_, Emitter<NotificationsState> emit) => _reload(emit);

  Future<void> _reload(Emitter<NotificationsState> emit) async {
    final id = _userId;
    if (id == null) return;
    emit(state.copyWith(status: NotificationsStatus.loading, clearError: true));
    try {
      final list = await _repo.list(id);
      emit(state.copyWith(status: NotificationsStatus.ready, notifications: list));
    } on NotificationsException catch (e) {
      emit(state.copyWith(
          status: NotificationsStatus.error, errorMessage: e.message ?? e.code));
    }
  }

  void _onFilter(NotificationsFilterChanged e, Emitter<NotificationsState> emit) {
    emit(state.copyWith(filter: e.filter));
  }

  Future<void> _onRead(NotificationsRead e, Emitter<NotificationsState> emit) async {
    try {
      await _repo.markRead(e.notificationId);
      emit(state.copyWith(
        notifications: state.notifications
            .map((n) => n.id == e.notificationId ? n.copyWith(markRead: true) : n)
            .toList(),
      ));
    } on NotificationsException catch (e) {
      emit(state.copyWith(
          status: NotificationsStatus.error, errorMessage: e.message ?? e.code));
    }
  }

  Future<void> _onAllRead(_, Emitter<NotificationsState> emit) async {
    final id = _userId;
    if (id == null) return;
    try {
      await _repo.markAllRead(id);
      emit(state.copyWith(
        notifications: state.notifications.map((n) => n.copyWith(markRead: true)).toList(),
      ));
    } on NotificationsException catch (e) {
      emit(state.copyWith(
          status: NotificationsStatus.error, errorMessage: e.message ?? e.code));
    }
  }

  void _onInserted(_NotificationsInserted e, Emitter<NotificationsState> emit) {
    // De-dupe by id; insert at the front.
    if (state.notifications.any((n) => n.id == e.n.id)) return;
    emit(state.copyWith(notifications: [e.n, ...state.notifications]));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
