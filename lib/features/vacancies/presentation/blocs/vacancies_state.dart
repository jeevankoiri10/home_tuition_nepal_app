part of 'vacancies_bloc.dart';

enum VacanciesStatus { initial, loading, ready, error }
enum ApplyStatus { idle, submitting, success, error }

class VacanciesState extends Equatable {
  const VacanciesState({
    this.status = VacanciesStatus.initial,
    this.vacancies = const [],
    this.myApplications = const [],
    this.subjectQuery,
    this.areaQuery,
    this.errorMessage,
    this.applyStatus = ApplyStatus.idle,
    this.applyError,
  });

  final VacanciesStatus status;
  final List<Vacancy> vacancies;
  final List<VacancyApplication> myApplications;
  final String? subjectQuery;
  final String? areaQuery;
  final String? errorMessage;
  final ApplyStatus applyStatus;
  final String? applyError;

  Set<String> get appliedVacancyIds =>
      myApplications.map((a) => a.vacancyId).toSet();

  VacanciesState copyWith({
    VacanciesStatus? status,
    List<Vacancy>? vacancies,
    List<VacancyApplication>? myApplications,
    String? subjectQuery,
    String? areaQuery,
    String? errorMessage,
    ApplyStatus? applyStatus,
    String? applyError,
    bool clearError = false,
    bool clearApplyError = false,
  }) {
    return VacanciesState(
      status: status ?? this.status,
      vacancies: vacancies ?? this.vacancies,
      myApplications: myApplications ?? this.myApplications,
      subjectQuery: subjectQuery ?? this.subjectQuery,
      areaQuery: areaQuery ?? this.areaQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      applyStatus: applyStatus ?? this.applyStatus,
      applyError: clearApplyError ? null : (applyError ?? this.applyError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        vacancies,
        myApplications,
        subjectQuery,
        areaQuery,
        errorMessage,
        applyStatus,
        applyError,
      ];
}
