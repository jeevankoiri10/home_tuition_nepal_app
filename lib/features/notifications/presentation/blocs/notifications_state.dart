part of 'notifications_bloc.dart';

enum NotificationsStatus { initial, loading, ready, error }

enum NotificationsFilter { all, unread, read }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.filter = NotificationsFilter.all,
    this.enabledKinds,
    this.errorMessage,
  });

  final NotificationsStatus status;
  final List<AppNotification> notifications;
  final NotificationsFilter filter;

  /// Kinds the admin currently has enabled. When null the registry hasn't
  /// loaded yet, so nothing is hidden.
  final Set<NotificationKind>? enabledKinds;
  final String? errorMessage;

  /// Notifications whose kind the admin hasn't disabled.
  List<AppNotification> get _allowed {
    final allowed = enabledKinds;
    if (allowed == null) return notifications;
    return notifications.where((n) => allowed.contains(n.kind)).toList();
  }

  int get unreadCount => _allowed.where((n) => !n.isRead).length;

  List<AppNotification> get visible {
    final allowed = _allowed;
    switch (filter) {
      case NotificationsFilter.all:
        return allowed;
      case NotificationsFilter.unread:
        return allowed.where((n) => !n.isRead).toList();
      case NotificationsFilter.read:
        return allowed.where((n) => n.isRead).toList();
    }
  }

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? notifications,
    NotificationsFilter? filter,
    Set<NotificationKind>? enabledKinds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      filter: filter ?? this.filter,
      enabledKinds: enabledKinds ?? this.enabledKinds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, notifications, filter, enabledKinds, errorMessage];
}
