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
}
