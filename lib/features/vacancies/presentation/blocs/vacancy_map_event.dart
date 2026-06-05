part of 'vacancy_map_bloc.dart';

sealed class VacancyMapEvent extends Equatable {
  const VacancyMapEvent();
  @override
  List<Object?> get props => [];
}

class VacancyMapStarted extends VacancyMapEvent {
  const VacancyMapStarted();
}

class VacancyMapCameraMoved extends VacancyMapEvent {
  const VacancyMapCameraMoved({required this.lat, required this.lng});
  final double lat;
  final double lng;
  @override
  List<Object?> get props => [lat, lng];
}

class VacancyMapRefreshRequested extends VacancyMapEvent {
  const VacancyMapRefreshRequested();
}

class VacancyMapSelected extends VacancyMapEvent {
  const VacancyMapSelected(this.vacancyId);
  final String? vacancyId;
  @override
  List<Object?> get props => [vacancyId];
}

/// Re-orders the current nearby vacancies without re-querying.
class VacancyMapSortChanged extends VacancyMapEvent {
  const VacancyMapSortChanged(this.sort);
  final VacancySort sort;
  @override
  List<Object?> get props => [sort];
}

class _VacancyMapSearchTick extends VacancyMapEvent {
  const _VacancyMapSearchTick();
}
