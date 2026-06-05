import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/map/domain/models/map_tutor.dart';

// Build via fromRow with a minimal map so we exercise the parser and avoid the
// 18-field constructor. Only the fields under test are varied.
MapTutor _tutor({
  double distanceKm = 2.0,
  num? fromPrice,
  String? period,
}) =>
    MapTutor.fromRow({
      'tutor_id': 't1',
      'lat': 27.7,
      'lng': 85.3,
      'distance_km': distanceKm,
      'from_price_npr': fromPrice,
      'from_price_period': period,
    });

void main() {
  group('MapTutor.formatDistance', () {
    test('renders metres under 1 km', () {
      expect(_tutor(distanceKm: 0.5).formatDistance(), '500 m');
      expect(_tutor(distanceKm: 0.45).formatDistance(), '450 m');
    });

    test('renders kilometres at or above 1 km, one decimal', () {
      expect(_tutor(distanceKm: 1.0).formatDistance(), '1.0 km');
      expect(_tutor(distanceKm: 2.34).formatDistance(), '2.3 km');
    });
  });

  group('MapTutor.formatFromPrice', () {
    test('is null when the tutor has no offering price', () {
      expect(_tutor(fromPrice: null).formatFromPrice(), isNull);
    });

    test('groups thousands and defaults the period to month', () {
      expect(_tutor(fromPrice: 5000).formatFromPrice(), 'Rs. 5,000/month');
    });

    test('uses the given period when present', () {
      expect(_tutor(fromPrice: 600, period: 'hour').formatFromPrice(),
          'Rs. 600/hour');
    });
  });

  group('MapTutor.fromRow', () {
    test('defaults verified/available/rating when columns are absent', () {
      final t = _tutor();
      expect(t.verified, isFalse);
      expect(t.available, isFalse);
      expect(t.rating, 0);
      expect(t.ratingCount, 0);
      expect(t.topSubjects, isEmpty);
    });
  });
}
