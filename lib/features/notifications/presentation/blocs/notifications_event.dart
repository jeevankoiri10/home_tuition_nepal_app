part of 'notifications_bloc.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();
  @override
  List<Object?> get props => const [];
}

class NotificationsLoaded extends NotificationsEvent {
  const NotificationsLoaded(this.userId);
  final String userId;
  @override
  List<Object?> get props => [userId];
}

class NotificationsRefreshed extends NotificationsEvent {
  const NotificationsRefreshed();
}

class NotificationsFilterChanged extends NotificationsEvent {
  const NotificationsFilterChanged(this.filter);
  final NotificationsFilter filter;
  @override
  List<Object?> get props => [filter];
}

class NotificationsRead extends NotificationsEvent {
  const NotificationsRead(this.notificationId);
  final String notificationId;
  @override
  List<Object?> get props => [notificationId];
}

class NotificationsAllRead extends NotificationsEvent {
  const NotificationsAllRead();
}

class _NotificationsInserted extends NotificationsEvent {
  const _NotificationsInserted(this.n);
  final AppNotification n;
  @override
  List<Object?> get props => [n.id];
}
