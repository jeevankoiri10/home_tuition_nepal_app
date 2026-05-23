part of 'vacancies_bloc.dart';

sealed class VacanciesEvent extends Equatable {
  const VacanciesEvent();
  @override
  List<Object?> get props => const [];
}

class VacanciesLoaded extends VacanciesEvent {
  const VacanciesLoaded(this.tutorId);
  final String tutorId;
  @override
  List<Object?> get props => [tutorId];
}

class VacanciesRefreshed extends VacanciesEvent {
  const VacanciesRefreshed();
}

class VacanciesFiltersChanged extends VacanciesEvent {
  const VacanciesFiltersChanged({this.subject, this.area});
  final String? subject;
  final String? area;
  @override
  List<Object?> get props => [subject, area];
}

class VacancyApplied extends VacanciesEvent {
  const VacancyApplied({
    required this.vacancyId,
    required this.coverNote,
    this.expectedRate,
    this.cvStoragePath,
  });
  final String vacancyId;
  final String coverNote;
  final num? expectedRate;
  final String? cvStoragePath;
  @override
  List<Object?> get props => [vacancyId, coverNote, expectedRate, cvStoragePath];
}

class VacancyApplyAcknowledged extends VacanciesEvent {
  const VacancyApplyAcknowledged();
}
