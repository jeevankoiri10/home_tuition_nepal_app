import 'dart:typed_data';

import 'models/tutor_profile.dart';

abstract class TutorRepository {
  Future<TutorProfile> load(String tutorId);
  Future<TutorProfile> save(TutorProfile profile);
  Future<TutorProfile> publish(TutorProfile profile);

  /// Uploads a CV PDF for [tutorId] and returns the public URL. Throws
  /// [TutorRepositoryException] with code `cv_too_large` when [bytes]
  /// exceeds the platform cap (300 KB) — enforced both client- and
  /// server-side so a tampered client can't bypass it.
  Future<String> uploadCv({
    required String tutorId,
    required Uint8List bytes,
    required String fileName,
  });
}

class TutorRepositoryException implements Exception {
  TutorRepositoryException(this.code, [this.message]);
  final String code;
  final String? message;

  @override
  String toString() => 'TutorRepositoryException($code, $message)';
}
