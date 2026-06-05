import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/map_tutor.dart';
import 'tutor_map_card.dart';

/// Horizontally-swipable carousel of [TutorMapCard]s shown in the map's bottom
/// sheet (`student_UI.md` §4.3.3, the `TutorCarousel` component in §5).
///
/// Kept in sync with the map: swiping to a card calls [onCardTap], which the
/// page uses to select that tutor and fly the camera to its pin. A feedback-
/// loop guard means a *programmatic* page change — e.g. when a pin tap animates
/// the carousel to the matching card — does NOT re-fire [onCardTap], so pin↔card
/// selection can't ping-pong.
class TutorCarousel extends StatelessWidget {
  const TutorCarousel({
    super.key,
    required this.tutors,
    required this.selectedTutorId,
    required this.controller,
    required this.onCardTap,
    required this.onContact,
    this.height = 200,
  });

  final List<MapTutor> tutors;
  final String? selectedTutorId;
  final PageController controller;
  final void Function(MapTutor tutor, int index) onCardTap;
  final void Function(MapTutor tutor) onContact;

  /// Base card height at the default text scale.
  final double height;

  /// Carousel height scaled for the user's text-size setting so the cards don't
  /// overflow at large accessibility font scales. Capped at 1.6× so a very
  /// large scale doesn't let the carousel swallow the map; floored at the base
  /// so smaller scales don't shrink it awkwardly.
  static double responsiveHeight(double base, double textScale) =>
      base * textScale.clamp(1.0, 1.6);

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = responsiveHeight(
      height,
      MediaQuery.textScalerOf(context).scale(1.0),
    );
    return SizedBox(
      height: effectiveHeight,
      child: PageView.builder(
        controller: controller,
        padEnds: false,
        itemCount: tutors.length,
        onPageChanged: (i) {
          if (i < 0 || i >= tutors.length) return;
          final tutor = tutors[i];
          // React only to user-driven swipes. When the landed-on card already
          // matches the selected tutor, the change came from a programmatic
          // animateToPage (pin tap / selection sync) — don't echo it back.
          if (tutor.tutorId != selectedTutorId) onCardTap(tutor, i);
        },
        itemBuilder: (context, i) {
          final tutor = tutors[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: TutorMapCard(
              tutor: tutor,
              selected: tutor.tutorId == selectedTutorId,
              onTap: () => onCardTap(tutor, i),
              onContact: () => onContact(tutor),
            ),
          );
        },
      ),
    );
  }
}
