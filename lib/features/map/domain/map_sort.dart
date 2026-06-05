import 'models/map_tutor.dart';

/// How the map's tutor list (and carousel) is ordered. Mirrors the sort options
/// in `student_UI.md` §4.3.6 — "Newest" is omitted because the map row carries
/// no creation timestamp.
enum MapSort { distance, priceLowHigh, rating }

/// Returns a new list of [tutors] ordered by [sort]. Pure and stable — safe to
/// call on every search result and whenever the sort changes.
List<MapTutor> sortTutors(List<MapTutor> tutors, MapSort sort) {
  final list = [...tutors];
  switch (sort) {
    case MapSort.distance:
      list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    case MapSort.priceLowHigh:
      list.sort((a, b) {
        final pa = a.fromPriceNpr;
        final pb = b.fromPriceNpr;
        // Tutors without a listed price sort last, so priced options lead.
        if (pa == null && pb == null) return 0;
        if (pa == null) return 1;
        if (pb == null) return -1;
        return pa.compareTo(pb);
      });
    case MapSort.rating:
      list.sort((a, b) {
        final byRating = b.rating.compareTo(a.rating);
        // Break ties by who has more ratings (more trustworthy).
        return byRating != 0 ? byRating : b.ratingCount.compareTo(a.ratingCount);
      });
  }
  return list;
}
