import '../../../app/router.dart';
import '../../../core/services/push_deep_link.dart';
import '../domain/models/app_notification.dart';

/// Pure mapping from a tapped notification to an in-app location. Reuses the
/// shared [deepLinkForRef]; when the ref can't be resolved it falls back to
/// the notice-detail page for THIS notification (the user is already in the
/// feed, so the generic feed list would be a no-op).
String resolveNotificationDeepLink(AppNotification n) =>
    deepLinkForRef(n.refType, n.refId) ??
    AppRoutes.noticeDetail.replaceAll(':id', n.id);
