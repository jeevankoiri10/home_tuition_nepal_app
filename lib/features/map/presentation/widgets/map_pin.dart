import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../tutor_profile/domain/models/profile_enums.dart';
import '../../../tutor_profile/presentation/enum_labels.dart';
import '../../domain/models/map_tutor.dart';

/// Color-coded tutor pin used on the map.
///   - Color: green = available now, amber = offline. Online-only tutors
///     always render green (their availability is implicit when "online").
///   - Icon: globe = teaches online only, home = teaches offline only,
///     two-finger pinch = teaches both.
///   - Presence badge: blue internet glyph = online now, grey = offline. This
///     is separate from the pin's teaching-mode icon and always present so the
///     two presence states are easy to tell apart at a glance.
///   - Gold ring = verified
///   - Rating pill below the dot (when the tutor has reviews) so quality reads
///     at a glance without opening the card.
///   - Slight scale-up + glow when selected
class MapPin extends StatelessWidget {
  const MapPin({
    super.key,
    required this.tutor,
    required this.selected,
    this.online = false,
  });

  final MapTutor tutor;
  final bool selected;

  /// Whether this tutor is currently online (Realtime Presence) — drives the
  /// presence badge, distinct from the pin's availability colour.
  final bool online;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Online-only tutors don't have a physical "available now" signal in the
    // same way — render them green so the globe stays paired with green.
    final isOnlineOnly = tutor.teachingMode == TeachingMode.online;
    final base = (tutor.available || isOnlineOnly)
        ? const Color(0xFF2E7D32)
        : const Color(0xFFED6C02);
    final size = selected ? 44.0 : 36.0;
    return Semantics(
      button: true,
      selected: selected,
      label: l10n.mapPinSemantics(
        tutor.maskedName,
        tutor.formatDistance(),
        tutor.verified ? l10n.mapPinVerifiedSuffix : '',
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (selected)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: base.withValues(alpha: 0.18),
                    ),
                  ),
                Container(
                  width: size * 0.7,
                  height: size * 0.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: base,
                    border: Border.all(
                      color: tutor.verified
                          ? const Color(0xFFFFD54F)
                          : Colors.white,
                      width: tutor.verified ? 3 : 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    tutor.teachingMode.icon,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                // Presence badge — top-right corner, always shown so online and
                // offline tutors are clearly distinguishable.
                Positioned(
                  top: size * 0.04,
                  right: size * 0.04,
                  child: _PresenceBadge(online: online),
                ),
              ],
            ),
          ),
          if (tutor.ratingCount > 0) ...[
            const SizedBox(height: 2),
            _RatingPill(rating: tutor.rating, emphasized: selected),
          ],
        ],
      ),
    );
  }
}

/// Tiny floating pill under the pin showing the tutor's average rating, so a
/// quality signal is visible directly on the map.
class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating, required this.emphasized});

  final num rating;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Color(0xFFFFB300), size: 10),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: emphasized ? 11 : 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small corner badge reflecting live Realtime Presence.
///
/// Online → a blue internet (Wi-Fi) glyph; offline → a grey Wi-Fi-off glyph.
/// The contrasting colour + icon keep the two states easy to tell apart on a
/// crowded map, and stay distinct from the pin's centre teaching-mode icon.
class _PresenceBadge extends StatelessWidget {
  const _PresenceBadge({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 17,
      height: 17,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: online ? AppColors.online : AppColors.offline,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(
        online ? Icons.wifi : Icons.wifi_off,
        size: 10,
        color: Colors.white,
      ),
    );
  }
}
