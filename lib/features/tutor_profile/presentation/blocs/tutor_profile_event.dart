part of 'tutor_profile_bloc.dart';

sealed class TutorProfileEvent extends Equatable {
  const TutorProfileEvent();
  @override
  List<Object?> get props => const [];
}

class TutorProfileLoaded extends TutorProfileEvent {
  const TutorProfileLoaded(this.tutorId);
  final String tutorId;
  @override
  List<Object?> get props => [tutorId];
}

/// Replaces the in-memory draft with the given profile and schedules an
/// auto-save. Used by every section editor on every keystroke or toggle.
class TutorProfileDraftUpdated extends TutorProfileEvent {
  const TutorProfileDraftUpdated(this.profile);
  final TutorProfile profile;
  @override
  List<Object?> get props => [profile];
}

/// Explicit save request — usually fires only when the user taps Save & Update.
class TutorProfileSaveRequested extends TutorProfileEvent {
  const TutorProfileSaveRequested();
}

class TutorProfilePublishRequested extends TutorProfileEvent {
  const TutorProfilePublishRequested();
}
