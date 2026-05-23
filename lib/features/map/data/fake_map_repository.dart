import 'dart:math';

import '../../tutor_profile/domain/models/profile_enums.dart';
import '../domain/map_repository.dart';
import '../domain/models/map_filters.dart';
import '../domain/models/map_tutor.dart';

/// In-memory MapRepository seeded with ~15 demo tutors around Kathmandu
/// (Baneshwor area as the default origin). Used when no Supabase credentials
/// are present so the map feature is fully demo-able locally.
class FakeMapRepository implements MapRepository {
  FakeMapRepository();

  late final List<MapTutor> _seed = _generateSeed();

  @override
  Future<List<MapTutor>> search({
    required double lat,
    required double lng,
    required MapFilters filters,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final withDistance = _seed.map((t) {
      final d = _haversine(lat, lng, t.lat, t.lng);
      return MapTutor(
        tutorId: t.tutorId,
        handle: t.handle,
        maskedName: t.maskedName,
        tagline: t.tagline,
        areaLabel: t.areaLabel,
        teachingMode: t.teachingMode,
        levelsTaught: t.levelsTaught,
        verified: t.verified,
        available: t.available,
        rating: t.rating,
        ratingCount: t.ratingCount,
        experienceOffline: t.experienceOffline,
        experienceOnline: t.experienceOnline,
        lat: t.lat,
        lng: t.lng,
        distanceKm: d,
        fromPriceNpr: t.fromPriceNpr,
        fromPricePeriod: t.fromPricePeriod,
        topSubjects: t.topSubjects,
      );
    });

    final filtered = withDistance.where((t) {
      if (t.distanceKm > filters.radiusKm) return false;
      if (filters.level != null && !t.levelsTaught.contains(filters.level)) return false;
      if (filters.verifiedOnly && !t.verified) return false;
      if (filters.availableOnly && !t.available) return false;
      if (filters.mode != null) {
        // Mode filter behavior matches the SQL helper: 'both' tutors always match.
        if (t.teachingMode != filters.mode && t.teachingMode != TeachingMode.both) {
          return false;
        }
      }
      if (filters.subjectQuery != null && filters.subjectQuery!.isNotEmpty) {
        final q = filters.subjectQuery!.toLowerCase();
        if (!t.topSubjects.any((s) => s.toLowerCase().contains(q))) return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      if (a.available != b.available) return a.available ? -1 : 1;
      if (a.verified != b.verified) return a.verified ? -1 : 1;
      return a.distanceKm.compareTo(b.distanceKm);
    });

    return filtered;
  }

  // ─── Seed data ──────────────────────────────────────────────────────────────

  static const double _seedLat = 27.6915; // New Baneshwor, Kathmandu
  static const double _seedLng = 85.3370;

  List<MapTutor> _generateSeed() {
    final rng = Random(42); // deterministic
    return List.generate(_seedNames.length, (i) {
      final entry = _seedNames[i];
      final dLat = (rng.nextDouble() - 0.5) * 0.04; // ≈ ±2.2 km
      final dLng = (rng.nextDouble() - 0.5) * 0.04;
      final price = 4000 + rng.nextInt(15) * 1000;
      return MapTutor(
        tutorId: 'fake-t-$i',
        handle: 'Tutor #${entry.handle}',
        maskedName: entry.maskedName,
        tagline: entry.tagline,
        areaLabel: entry.area,
        teachingMode: entry.mode,
        levelsTaught: entry.levels,
        verified: i % 3 == 0,
        available: i % 4 != 0,
        rating: 3.5 + rng.nextDouble() * 1.5,
        ratingCount: rng.nextInt(40),
        experienceOffline: (rng.nextInt(6) + 1).toDouble(),
        experienceOnline: rng.nextInt(4).toDouble(),
        lat: _seedLat + dLat,
        lng: _seedLng + dLng,
        distanceKm: 0, // filled in by search()
        fromPriceNpr: price,
        fromPricePeriod: i.isEven ? 'month' : 'hour',
        topSubjects: entry.subjects,
      );
    });
  }

  static const _seedNames = [
    _Seed('A4F7', 'Ramesh S*', 'Engineering grad — Maths & Physics', 'Baneshwor',
        TeachingMode.both, [StudentLevel.see, StudentLevel.plus2], ['Maths', 'Physics']),
    _Seed('9BG2', 'Sita K*', 'Patient tutor for primary kids', 'Kapan',
        TeachingMode.offline, [StudentLevel.belowClass9], ['English', 'Nepali']),
    _Seed('7K3P', 'Aakash D*', 'A-Level Chemistry coach', 'Lazimpat',
        TeachingMode.online, [StudentLevel.aLevel], ['Chemistry']),
    _Seed('M2QK', 'Bidhya T*', 'Science enthusiast', 'Chabahil',
        TeachingMode.both, [StudentLevel.see, StudentLevel.belowClass9], ['Science', 'Maths']),
    _Seed('R5LP', 'Sushmita P*', 'IGCSE Biology + SAT prep', 'Koteswor',
        TeachingMode.online, [StudentLevel.aLevel, StudentLevel.plus2], ['Biology', 'Statistics']),
    _Seed('H8VR', 'Prem D*', 'BSc CSIT, programming basics', 'New Baneshwor',
        TeachingMode.both, [StudentLevel.plus2, StudentLevel.aLevel], ['Computer Science', 'Maths']),
    _Seed('XB72', 'Sangeer N*', 'Engineering Mechanics tutor', 'Maitighar',
        TeachingMode.offline, [StudentLevel.plus2], ['Engineering Mechanics']),
    _Seed('YN34', 'Punita Y*', 'Multi-subject primary tutor', 'Kalimati',
        TeachingMode.offline, [StudentLevel.belowClass9], ['Nepali', 'Mathematics', 'English']),
    _Seed('LP01', 'Madhavi U*', 'Encouraging coach for early learners', 'Sundhara',
        TeachingMode.offline, [StudentLevel.belowClass9], ['Math', 'Nepali']),
    _Seed('VC83', 'Sabita A*', 'Maths & Accounts (Class 10)', 'Putalisadak',
        TeachingMode.both, [StudentLevel.see], ['Statistics', 'Accountancy']),
    _Seed('JK19', 'Sijan S*', 'CBSE specialist, modern methods', 'Tinkune',
        TeachingMode.offline, [StudentLevel.see, StudentLevel.plus2], ['Maths', 'Science']),
    _Seed('BR55', 'Roshni K*', '+2 Science teacher', 'Koteswor',
        TeachingMode.offline, [StudentLevel.plus2], ['Physics', 'Chemistry']),
    _Seed('TT08', 'Adarsha K*', 'Friendly accounts tutor', 'Maharajgunj',
        TeachingMode.online, [StudentLevel.plus2], ['Accountancy']),
    _Seed('NM91', 'Yunisha K*', 'Maths (10th)', 'Anamnagar',
        TeachingMode.offline, [StudentLevel.see], ['Mathematics']),
    _Seed('QC44', 'Prabisha D*', 'Science graduate, breaks down hard concepts', 'Thapathali',
        TeachingMode.both, [StudentLevel.see, StudentLevel.belowClass9], ['Science', 'Maths']),
  ];

  // Haversine in km.
  double _haversine(double aLat, double aLng, double bLat, double bLng) {
    const r = 6371.0;
    final dLat = _deg(bLat - aLat);
    final dLng = _deg(bLng - aLng);
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg(aLat)) * cos(_deg(bLat)) * sin(dLng / 2) * sin(dLng / 2);
    return 2 * r * asin(sqrt(h));
  }

  double _deg(double d) => d * pi / 180.0;
}

class _Seed {
  const _Seed(this.handle, this.maskedName, this.tagline, this.area, this.mode, this.levels,
      this.subjects);
  final String handle;
  final String maskedName;
  final String tagline;
  final String area;
  final TeachingMode mode;
  final List<StudentLevel> levels;
  final List<String> subjects;
}
