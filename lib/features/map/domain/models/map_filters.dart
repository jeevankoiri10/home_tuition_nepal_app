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
