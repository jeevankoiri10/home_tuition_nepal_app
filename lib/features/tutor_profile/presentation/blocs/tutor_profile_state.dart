part of 'tutor_profile_bloc.dart';

enum TutorProfileStatus { initial, loading, ready, saving, error, published }

class TutorProfileState extends Equatable {
  const TutorProfileState({
    this.status = TutorProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.lastSavedAt,
  });

  final TutorProfileStatus status;
  final TutorProfile? profile;
  final String? errorMessage;
  final DateTime? lastSavedAt;

  TutorProfileState copyWith({
    TutorProfileStatus? status,
    TutorProfile? profile,
    String? errorMessage,
    DateTime? lastSavedAt,
    bool clearError = false,
  }) {
    return TutorProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage, lastSavedAt];
}
