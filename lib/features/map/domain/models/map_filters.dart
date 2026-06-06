import 'package:equatable/equatable.dart';

import '../../../tutor_profile/domain/models/profile_enums.dart';

/// Active filter state for the map view. Stored on `MapBloc` and round-tripped
/// to `search_tutors_in_viewport`.
class MapFilters extends Equatable {
  const MapFilters({
    this.level,
    this.subjectQuery,
    this.mode,
    this.verifiedOnly = false,
    this.availableOnly = false,
    this.radiusKm,
  });

  final StudentLevel? level;
  final String? subjectQuery;
  final TeachingMode? mode;
  final bool verifiedOnly;
  final bool availableOnly;

  /// Max search radius in km. `null` means no limit — return tutors anywhere.
  /// Default is `null` so the first map load isn't artificially clipped.
  final double? radiusKm;

  /// Selectable radius tiers (km) shown in the filter UI, per `student_UI.md`
  /// §4.3.2. The "Expand radius" empty-state CTA steps up through these.
  static const List<double> radiusTiers = [1, 3, 5, 10];

  /// Whether the radius can still be widened. False once it's already
  /// unlimited (`radiusKm == null`).
  bool get canExpandRadius => radiusKm != null;

  /// Active radius in metres — used to draw the map's search-radius circle
  /// (`student_UI.md` §4.3.2). Null when there's no distance limit, in which
  /// case no circle is drawn.
  double? get radiusMeters => radiusKm == null ? null : radiusKm! * 1000;

  /// True when any filter narrows the default (everything, no distance limit).
  /// Drives the "Clear filters" affordance and the active-chip highlighting.
  bool get hasActiveFilters =>
      level != null ||
      subjectQuery != null ||
      mode != null ||
      verifiedOnly ||
      availableOnly ||
      radiusKm != null;

  /// Returns filters with the radius widened to the next tier — or to "no
  /// limit" when already at/above the widest tier. Used by the empty-state
  /// "Expand radius" CTA to help a student who matched nothing nearby.
  MapFilters expandedRadius() {
    final current = radiusKm;
    if (current == null) return this; // already unlimited
    for (final tier in radiusTiers) {
      if (tier > current) return copyWith(radiusKm: tier);
    }
    return copyWith(clearRadius: true); // widen all the way to no limit
  }

  MapFilters copyWith({
    StudentLevel? level,
    String? subjectQuery,
    TeachingMode? mode,
    bool? verifiedOnly,
    bool? availableOnly,
    double? radiusKm,
    bool clearLevel = false,
    bool clearMode = false,
    bool clearSubject = false,
    bool clearRadius = false,
  }) {
    return MapFilters(
      level: clearLevel ? null : (level ?? this.level),
      subjectQuery: clearSubject ? null : (subjectQuery ?? this.subjectQuery),
      mode: clearMode ? null : (mode ?? this.mode),
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      availableOnly: availableOnly ?? this.availableOnly,
      radiusKm: clearRadius ? null : (radiusKm ?? this.radiusKm),
    );
  }

  @override
  List<Object?> get props => [level, subjectQuery, mode, verifiedOnly, availableOnly, radiusKm];
}
