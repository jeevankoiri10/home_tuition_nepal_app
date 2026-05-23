import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/tutor_profile.dart';
import '../../domain/tutor_repository.dart';

part 'tutor_profile_event.dart';
part 'tutor_profile_state.dart';

class TutorProfileBloc extends Bloc<TutorProfileEvent, TutorProfileState> {
  TutorProfileBloc(this._repo) : super(const TutorProfileState()) {
    on<TutorProfileLoaded>(_onLoad);
    on<TutorProfileDraftUpdated>(_onDraftUpdated);
    on<TutorProfileSaveRequested>(_onSave);
    on<TutorProfilePublishRequested>(_onPublish);
  }

  final TutorRepository _repo;
  Timer? _autoSaveTimer;

  Future<void> _onLoad(TutorProfileLoaded event, Emitter<TutorProfileState> emit) async {
    emit(state.copyWith(status: TutorProfileStatus.loading, clearError: true));
    try {
      final profile = await _repo.load(event.tutorId);
      emit(state.copyWith(status: TutorProfileStatus.ready, profile: profile));
    } on TutorRepositoryException catch (e) {
      emit(state.copyWith(
        status: TutorProfileStatus.error,
        errorMessage: e.message ?? e.code,
      ));
    }
  }

  void _onDraftUpdated(TutorProfileDraftUpdated event, Emitter<TutorProfileState> emit) {
    final withScore = event.profile.copyWith(
      profileCompletion: TutorProfile.computeCompletion(event.profile),
    );
    emit(state.copyWith(status: TutorProfileStatus.ready, profile: withScore));
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 800), () {
      add(const TutorProfileSaveRequested());
    });
  }

  Future<void> _onSave(TutorProfileSaveRequested event, Emitter<TutorProfileState> emit) async {
    final draft = state.profile;
    if (draft == null) return;
    emit(state.copyWith(status: TutorProfileStatus.saving));
    try {
      final saved = await _repo.save(draft);
      emit(state.copyWith(
        status: TutorProfileStatus.ready,
        profile: saved,
        lastSavedAt: DateTime.now(),
        clearError: true,
      ));
    } on TutorRepositoryException catch (e) {
      emit(state.copyWith(
        status: TutorProfileStatus.error,
        errorMessage: e.message ?? e.code,
      ));
    }
  }

  Future<void> _onPublish(TutorProfilePublishRequested event, Emitter<TutorProfileState> emit) async {
    final draft = state.profile;
    if (draft == null) return;
    emit(state.copyWith(status: TutorProfileStatus.saving));
    try {
      final published = await _repo.publish(draft);
      emit(state.copyWith(
        status: TutorProfileStatus.published,
        profile: published,
        lastSavedAt: DateTime.now(),
        clearError: true,
      ));
    } on TutorRepositoryException catch (e) {
      emit(state.copyWith(
        status: TutorProfileStatus.error,
        errorMessage: e.message ?? e.code,
      ));
    }
  }

  @override
  Future<void> close() {
    _autoSaveTimer?.cancel();
    return super.close();
  }
}
