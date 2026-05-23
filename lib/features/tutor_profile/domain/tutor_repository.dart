import 'models/tutor_profile.dart';

abstract class TutorRepository {
  Future<TutorProfile> load(String tutorId);
  Future<TutorProfile> save(TutorProfile profile);
  Future<TutorProfile> publish(TutorProfile profile);
}

class TutorRepositoryException implements Exception {
  TutorRepositoryException(this.code, [this.message]);
  final String code;
  final String? message;

  @override
  String toString() => 'TutorRepositoryException($code, $message)';
}
