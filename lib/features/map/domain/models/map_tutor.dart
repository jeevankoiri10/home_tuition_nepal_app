import 'package:equatable/equatable.dart';

import '../../../tutor_profile/domain/models/profile_enums.dart';

/// Row returned by `search_tutors_in_viewport`. Contains only masked / public
/// fields — never a real name, phone, or exact address.
class MapTutor extends Equatable {
  const MapTutor({
    required this.tutorId,
    required this.handle,
    required this.maskedName,
    this.tagline,
    required this.areaLabel,
    required this.teachingMode,
    required this.levelsTaught,
    required this.verified,
    required this.available,
    required this.rating,
    required this.ratingCount,
    required this.experienceOffline,
    required this.experienceOnline,
    required this.lat,
    required this.lng,
    required this.distanceKm,
    this.fromPriceNpr,
    this.fromPricePeriod,
    this.topSubjects = const [],
    this.cvUrl,
  });

  final String tutorId;
  final String handle;
  final String maskedName;
  final String? tagline;
  final String areaLabel;
  final TeachingMode teachingMode;
  final List<StudentLevel> levelsTaught;
  final bool verified;
  final bool available;
  final num rating;
  final int ratingCount;
  final num experienceOffline;
  final num experienceOnline;
  final double lat;
  final double lng;
  final double distanceKm;
  final num? fromPriceNpr;
  final String? fromPricePeriod;
  final List<String> topSubjects;

  /// Public URL of the tutor's CV PDF, if uploaded. Null when the tutor has
  /// not yet added a CV — UI hides the "View CV" affordance in that case.
  final String? cvUrl;

  /// "Rs. 5,000/month" or null when the tutor has no offerings.
  String? formatFromPrice() {
    if (fromPriceNpr == null) return null;
    final s = fromPriceNpr!.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    final period = fromPricePeriod ?? 'month';
    return 'Rs. $buf/$period';
  }

  String formatDistance() {
    if (distanceKm < 1) return '${(distanceKm * 1000).round()} m';
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  static MapTutor fromRow(Map<String, dynamic> row) => MapTutor(
        tutorId: row['tutor_id'] as String,
        handle: (row['handle'] as String?) ?? '',
        maskedName: (row['masked_name'] as String?) ?? '',
        tagline: row['tagline'] as String?,
        areaLabel: (row['area_label'] as String?) ?? '',
        teachingMode: TeachingMode.fromString(row['teaching_mode'] as String?),
        levelsTaught: ((row['levels_taught'] as List?) ?? const [])
            .map((v) => StudentLevel.fromValue(v as String))
            .toList(),
        verified: (row['verified'] as bool?) ?? false,
        available: (row['available'] as bool?) ?? false,
        rating: (row['rating'] as num?) ?? 0,
        ratingCount: (row['rating_count'] as int?) ?? 0,
        experienceOffline: (row['experience_offline'] as num?) ?? 0,
        experienceOnline: (row['experience_online'] as num?) ?? 0,
        lat: (row['lat'] as num).toDouble(),
        lng: (row['lng'] as num).toDouble(),
        distanceKm: (row['distance_km'] as num).toDouble(),
        fromPriceNpr: row['from_price_npr'] as num?,
        fromPricePeriod: row['from_price_period'] as String?,
        topSubjects: ((row['top_subjects'] as List?) ?? const [])
            .map((v) => v as String)
            .toList(),
        cvUrl: row['cv_url'] as String?,
      );

  @override
  List<Object?> get props => [tutorId, lat, lng, available, verified, distanceKm];
}
