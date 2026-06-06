import 'dart:typed_data';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/pdf_validator.dart';
import '../domain/models/tutor_profile.dart';
import '../domain/tutor_repository.dart';

/// In-memory TutorRepository used when Supabase credentials are absent.
/// Acceptable for development; never used in production.
class FakeTutorRepository implements TutorRepository {
  final Map<String, TutorProfile> _store = {};

  @override
  Future<TutorProfile> load(String tutorId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final existing = _store[tutorId];
    if (existing != null) return existing;
    final fresh = TutorProfile(tutorId: tutorId);
    _store[tutorId] = fresh;
    return fresh;
  }

  @override
  Future<TutorProfile> save(TutorProfile profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final withScore = profile.copyWith(
      profileCompletion: TutorProfile.computeCompletion(profile),
    );
    _store[profile.tutorId] = withScore;
    return withScore;
  }

  @override
  Future<TutorProfile> publish(TutorProfile profile) async {
    if (!profile.isPublishable) {
      throw TutorRepositoryException('not_publishable',
          'Reach 80% profile completion before publishing.');
    }
    final published = profile.copyWith(draftStatus: 'published');
    return save(published);
  }

  @override
  Future<String> uploadCv({
    required String tutorId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (bytes.lengthInBytes > AppConstants.tutorCvMaxBytes) {
      throw TutorRepositoryException(
          'cv_too_large', 'CV must be smaller than 300 KB.');
    }
    if (!PdfValidator.isPdf(bytes)) {
      throw TutorRepositoryException('cv_not_pdf', 'CV must be a PDF file.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
    // In dev we don't actually persist the bytes — return a placeholder URL
    // and stash the path on the in-memory profile so the rest of the wizard
    // (and the student-side viewer in Phase 9) sees it.
    final url = 'https://dev.invalid/tutor-cvs/$tutorId/$fileName';
    final current = _store[tutorId];
    if (current != null) {
      _store[tutorId] = current.copyWith(cvUrl: url);
    }
    return url;
  }
}
