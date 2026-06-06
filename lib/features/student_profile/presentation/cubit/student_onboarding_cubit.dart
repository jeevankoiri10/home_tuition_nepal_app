import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/location_service.dart';
import '../../../auth/domain/auth_repository.dart';

/// Drives the two-step student onboarding (contact → location). Form text lives
/// in the page's controllers; this cubit owns the picked location, the resume
/// step, and the save/complete calls against [AuthRepository].
class StudentOnboardingCubit extends Cubit<StudentOnboardingState> {
  StudentOnboardingCubit(this._auth)
    : super(
        StudentOnboardingState(
          step: _auth.cachedUser?.onboardingStep ?? 0,
          lat: _auth.cachedUser?.lat,
          lng: _auth.cachedUser?.lng,
        ),
      );

  final AuthRepository _auth;

  void setLocation(double lat, double lng) =>
      emit(state.copyWith(lat: lat, lng: lng));

  /// Remember the current step so a relaunch resumes here (best-effort — a
  /// failed persist must not block navigation within the wizard).
  Future<void> goToStep(int step) async {
    emit(state.copyWith(step: step));
    try {
      await _auth.saveOnboardingStep(step);
    } catch (_) {
      /* resume hint is non-critical */
    }
  }

  /// Persist contact + location and open the onboarding gate. Returns true on
  /// success; the router guard then routes the student to the map home.
  Future<bool> complete({
    required String phone,
    required String whatsapp,
  }) async {
    emit(state.copyWith(saving: true, clearError: true));
    try {
      await _auth.completeStudentOnboarding(
        phone: phone,
        whatsapp: whatsapp,
        lat: state.lat ?? LocationService.fallbackLat,
        lng: state.lng ?? LocationService.fallbackLng,
      );
      return true;
    } on AuthException catch (e) {
      emit(state.copyWith(saving: false, error: e.code));
      return false;
    } catch (_) {
      emit(state.copyWith(saving: false, error: 'no_internet'));
      return false;
    }
  }
}

class StudentOnboardingState extends Equatable {
  const StudentOnboardingState({
    this.step = 0,
    this.lat,
    this.lng,
    this.saving = false,
    this.error,
  });

  final int step;
  final double? lat;
  final double? lng;
  final bool saving;
  final String? error;

  StudentOnboardingState copyWith({
    int? step,
    double? lat,
    double? lng,
    bool? saving,
    String? error,
    bool clearError = false,
  }) {
    return StudentOnboardingState(
      step: step ?? this.step,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      saving: saving ?? this.saving,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [step, lat, lng, saving, error];
}
