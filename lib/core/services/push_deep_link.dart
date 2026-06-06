import '../../app/router.dart';

/// Shared, pure mapping from a `ref_type`/`ref_id` pair to an in-app location.
/// Returns null when the ref can't be resolved (unknown type, or a type that
/// needs an id but none was given) so each caller can choose its own
/// fallback. Used by both push deep-links and the in-app notifications feed.
String? deepLinkForRef(String? refType, String? refId) {
  switch (refType) {
    case 'job':
      return refId == null ? null : AppRoutes.postDetail.replaceAll(':id', refId);
    case 'vacancy':
      return refId == null ? null : AppRoutes.vacancyDetail.replaceAll(':id', refId);
    case 'tutor':
      return AppRoutes.map;
    case 'notice':
      return refId == null ? null : AppRoutes.noticeDetail.replaceAll(':id', refId);
  }
  return null;
}

/// Push payload → location. Unknown/missing ref lands on the feed so the user
/// sees why we pinged them. Side-effect-free; the coordinator hands the result
/// to its `navigate` callback.
String resolvePushDeepLink(Map<String, dynamic> payload) =>
    deepLinkForRef(payload['ref_type'] as String?, payload['ref_id'] as String?) ??
    AppRoutes.notifications;
