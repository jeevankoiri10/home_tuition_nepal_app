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
    this.applyNeedsTopUp = false,
  });

  final VacanciesStatus status;
  final List<Vacancy> vacancies;
  final List<VacancyApplication> myApplications;
  final String? subjectQuery;
  final String? areaQuery;
  final String? errorMessage;
  final ApplyStatus applyStatus;
  final String? applyError;

  /// True when the last apply failed specifically because the tutor lacked
  /// coins. Lets the UI offer a top-up shortcut without string-matching the
  /// (server-emitted, locale-variable) [applyError] text.
  final bool applyNeedsTopUp;

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
    bool? applyNeedsTopUp,
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
      applyNeedsTopUp:
          clearApplyError ? false : (applyNeedsTopUp ?? this.applyNeedsTopUp),
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
        applyNeedsTopUp,
      ];
}
