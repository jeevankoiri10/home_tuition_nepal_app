import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/vacancies/domain/models/vacancy.dart';
import 'package:home_tuition_nepal_app/features/vacancies/domain/vacancy_sort.dart';

Vacancy _v(
  String id, {
  double? distanceKm,
  num? salaryMax,
  DateTime? createdAt,
}) =>
    Vacancy(
      id: id,
      title: 'V $id',
      areaLabel: 'Area',
      salaryMaxNpr: salaryMax,
      distanceKm: distanceKm,
      createdAt: createdAt ?? DateTime(2026, 1, 1),
    );

List<String> _ids(List<Vacancy> list) => list.map((v) => v.id).toList();

void main() {
  group('sortVacancies', () {
    test('distance: nearest first, unknown distance last', () {
      final list = [
        _v('a', distanceKm: 5),
        _v('b', distanceKm: null),
        _v('c', distanceKm: 1),
      ];
      expect(_ids(sortVacancies(list, VacancySort.distance)), ['c', 'a', 'b']);
    });

    test('salary: high to low, missing salary last', () {
      final list = [
        _v('a', salaryMax: 8000),
        _v('b', salaryMax: null),
        _v('c', salaryMax: 20000),
      ];
      expect(
          _ids(sortVacancies(list, VacancySort.salaryHighLow)), ['c', 'a', 'b']);
    });

    test('newest: most recently created first', () {
      final list = [
        _v('a', createdAt: DateTime(2026, 1, 1)),
        _v('b', createdAt: DateTime(2026, 6, 1)),
        _v('c', createdAt: DateTime(2026, 3, 1)),
      ];
      expect(_ids(sortVacancies(list, VacancySort.newest)), ['b', 'c', 'a']);
    });

    test('does not mutate the input list', () {
      final list = [_v('a', distanceKm: 5), _v('b', distanceKm: 1)];
      sortVacancies(list, VacancySort.distance);
      expect(_ids(list), ['a', 'b']);
    });
  });
}
