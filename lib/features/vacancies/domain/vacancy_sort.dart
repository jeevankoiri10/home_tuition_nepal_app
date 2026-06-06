import 'models/vacancy.dart';

/// Ordering for the tutor vacancy-map nearby list. Vacancies carry a
/// `createdAt`, so unlike the tutor map "Newest" is a real option here.
enum VacancySort { distance, salaryHighLow, newest }

/// Returns a new list of [vacancies] ordered by [sort]. Pure and stable.
List<Vacancy> sortVacancies(List<Vacancy> vacancies, VacancySort sort) {
  final list = [...vacancies];
  switch (sort) {
    case VacancySort.distance:
      // Vacancies without a distance (no geo-search) sort last.
      list.sort((a, b) => (a.distanceKm ?? double.infinity)
          .compareTo(b.distanceKm ?? double.infinity));
    case VacancySort.salaryHighLow:
      num pay(Vacancy v) => v.salaryMaxNpr ?? v.salaryMinNpr ?? -1;
      list.sort((a, b) => pay(b).compareTo(pay(a)));
    case VacancySort.newest:
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  return list;
}
