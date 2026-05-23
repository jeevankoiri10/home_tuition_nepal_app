part of 'notifications_bloc.dart';

enum NotificationsStatus { initial, loading, ready, error }

enum NotificationsFilter { all, unread, read }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.filter = NotificationsFilter.all,
    this.errorMessage,
  });

  final NotificationsStatus status;
  final List<AppNotification> notifications;
  final NotificationsFilter filter;
  final String? errorMessage;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  List<AppNotification> get visible {
    switch (filter) {
      case NotificationsFilter.all:
        return notifications;
      case NotificationsFilter.unread:
        return notifications.where((n) => !n.isRead).toList();
      case NotificationsFilter.read:
        return notifications.where((n) => n.isRead).toList();
    }
  }

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? notifications,
    NotificationsFilter? filter,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      filter: filter ?? this.filter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, notifications, filter, errorMessage];
}
