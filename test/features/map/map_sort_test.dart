import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/map/domain/map_sort.dart';
import 'package:home_tuition_nepal_app/features/map/domain/models/map_tutor.dart';

MapTutor _t(
  String id, {
  required double distanceKm,
  num? price,
  num rating = 0,
  int ratingCount = 0,
}) =>
    MapTutor.fromRow({
      'tutor_id': id,
      'lat': 27.7,
      'lng': 85.3,
      'distance_km': distanceKm,
      'from_price_npr': price,
      'rating': rating,
      'rating_count': ratingCount,
    });

List<String> _ids(List<MapTutor> list) => list.map((t) => t.tutorId).toList();

void main() {
  group('sortTutors', () {
    test('distance: nearest first', () {
      final list = [
        _t('a', distanceKm: 5),
        _t('b', distanceKm: 1),
        _t('c', distanceKm: 3),
      ];
      expect(_ids(sortTutors(list, MapSort.distance)), ['b', 'c', 'a']);
    });

    test('price: low to high, unpriced tutors last', () {
      final list = [
        _t('a', distanceKm: 1, price: 8000),
        _t('b', distanceKm: 1, price: null),
        _t('c', distanceKm: 1, price: 3000),
      ];
      expect(_ids(sortTutors(list, MapSort.priceLowHigh)), ['c', 'a', 'b']);
    });

    test('rating: highest first, ties broken by rating count', () {
      final list = [
        _t('a', distanceKm: 1, rating: 4.5, ratingCount: 2),
        _t('b', distanceKm: 1, rating: 4.8, ratingCount: 10),
        _t('c', distanceKm: 1, rating: 4.5, ratingCount: 20),
      ];
      // b (4.8) first; a & c tie at 4.5 → c has more ratings.
      expect(_ids(sortTutors(list, MapSort.rating)), ['b', 'c', 'a']);
    });

    test('does not mutate the input list', () {
      final list = [_t('a', distanceKm: 5), _t('b', distanceKm: 1)];
      sortTutors(list, MapSort.distance);
      expect(_ids(list), ['a', 'b']); // original order preserved
    });
  });
}
