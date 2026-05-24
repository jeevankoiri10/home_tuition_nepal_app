import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../tutor_profile/domain/models/profile_enums.dart';
import '../../domain/models/map_tutor.dart';

/// Color-coded tutor pin used on the map.
///   - Color: green = available now, amber = offline. Online-only tutors
///     always render green (their availability is implicit when "online").
///   - Icon: globe = teaches online only, home = teaches offline only,
///     two-finger pinch = teaches both.
///   - Gold ring = verified
///   - Slight scale-up + glow when selected
class MapPin extends StatelessWidget {
  const MapPin({super.key, required this.tutor, required this.selected});

  final MapTutor tutor;
  final bool selected;

  /// Icon that signals the tutor's teaching mode at-a-glance.
  IconData get _modeIcon {
    switch (tutor.teachingMode) {
      case TeachingMode.online:
        return Icons.public;
      case TeachingMode.offline:
        return Icons.home;
      case TeachingMode.both:
        return Icons.pinch;
    }
  }

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
      child: SizedBox(
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
                color: tutor.verified ? const Color(0xFFFFD54F) : Colors.white,
                width: tutor.verified ? 3 : 2,
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Icon(_modeIcon, color: Colors.white, size: 16),
          ),
        ],
      ),
    ),
    );
  }
}
