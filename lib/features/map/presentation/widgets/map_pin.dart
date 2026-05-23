import 'package:flutter/material.dart';

import '../../domain/models/map_tutor.dart';

/// Color-coded tutor pin used on the map.
///   - Green = available now
///   - Amber = published but offline
///   - Gold ring = verified
///   - Slight scale-up + glow when selected
class MapPin extends StatelessWidget {
  const MapPin({super.key, required this.tutor, required this.selected});

  final MapTutor tutor;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final base = tutor.available ? const Color(0xFF2E7D32) : const Color(0xFFED6C02);
    final size = selected ? 44.0 : 36.0;
    return SizedBox(
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
            child: const Icon(Icons.person_outline, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }
}
