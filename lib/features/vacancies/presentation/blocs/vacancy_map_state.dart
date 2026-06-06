part of 'vacancy_map_bloc.dart';

enum VacancyMapStatus { initial, locating, loading, ready, error }

class VacancyMapState extends Equatable {
  const VacancyMapState({
    this.status = VacancyMapStatus.initial,
    this.centerLat,
    this.centerLng,
    this.vacancies = const [],
    this.sort = VacancySort.distance,
    this.selectedId,
    this.errorMessage,
  });

  final VacancyMapStatus status;
  final double? centerLat;
  final double? centerLng;
  final List<Vacancy> vacancies;
  final VacancySort sort;
  final String? selectedId;
  final String? errorMessage;

  VacancyMapState copyWith({
    VacancyMapStatus? status,
    double? centerLat,
    double? centerLng,
    List<Vacancy>? vacancies,
    VacancySort? sort,
    String? selectedId,
    String? errorMessage,
    bool clearSelection = false,
    bool clearError = false,
  }) {
    return VacancyMapState(
      status: status ?? this.status,
      centerLat: centerLat ?? this.centerLat,
      centerLng: centerLng ?? this.centerLng,
      vacancies: vacancies ?? this.vacancies,
      sort: sort ?? this.sort,
      selectedId: clearSelection ? null : (selectedId ?? this.selectedId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, centerLat, centerLng, vacancies, sort, selectedId, errorMessage];
}
