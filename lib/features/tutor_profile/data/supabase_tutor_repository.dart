import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../domain/models/profile_enums.dart';
import '../domain/models/tutor_availability.dart';
import '../domain/models/tutor_credentials.dart';
import '../domain/models/tutor_offering.dart';
import '../domain/models/tutor_profile.dart';
import '../domain/tutor_repository.dart';

class SupabaseTutorRepository implements TutorRepository {
  SupabaseTutorRepository(this._client);

  final sb.SupabaseClient _client;

  @override
  Future<TutorProfile> load(String tutorId) async {
    try {
      final tutorRow =
          await _client.from('tutors').select().eq('id', tutorId).maybeSingle();
      // First-time visit: create the row.
      if (tutorRow == null) {
        await _client.from('tutors').insert({'id': tutorId});
        return TutorProfile(tutorId: tutorId);
      }
      final offerings = await _client
          .from('tutor_offerings')
          .select()
          .eq('tutor_id', tutorId)
          .order('level', ascending: true);
      final availRow = await _client
          .from('tutor_availability')
          .select()
          .eq('tutor_id', tutorId)
          .maybeSingle();
      final education = await _client
          .from('tutor_education')
          .select()
          .eq('tutor_id', tutorId)
          .order('sort_order');
      final experience = await _client
          .from('tutor_experience')
          .select()
          .eq('tutor_id', tutorId)
          .order('sort_order');
      final certificates = await _client
          .from('tutor_certificates')
          .select()
          .eq('tutor_id', tutorId)
          .order('sort_order');

      return _profileFromRows(
        tutorId: tutorId,
        tutorRow: tutorRow,
        offeringRows: List<Map<String, dynamic>>.from(offerings),
        availabilityRow: availRow,
        educationRows: List<Map<String, dynamic>>.from(education),
        experienceRows: List<Map<String, dynamic>>.from(experience),
        certificateRows: List<Map<String, dynamic>>.from(certificates),
      );
    } on sb.PostgrestException catch (e) {
      throw TutorRepositoryException('load_failed', e.message);
    }
  }

  @override
  Future<TutorProfile> save(TutorProfile profile) async {
    try {
      // 1. Upsert the tutors row.
      await _client.from('tutors').upsert({
        'id': profile.tutorId,
        'teaching_mode': profile.teachingMode.value,
        'levels_taught': profile.levelsTaught.map((l) => l.value).toList(),
        'languages_known': profile.languagesKnown,
        'native_language': profile.nativeLanguage,
        'about_me': profile.aboutMe,
        'about_sessions': profile.aboutSessions,
        'qualifications': profile.qualifications,
        'tagline': profile.tagline,
        'country': profile.country,
        'zone': profile.zone,
        'city': profile.city,
        'address_line': profile.addressLine,
        'service_radius_km': profile.serviceRadiusKm,
        'draft_status': profile.draftStatus,
      });

      // 2. Replace offerings (simple upsert-replace strategy).
      await _client.from('tutor_offerings').delete().eq('tutor_id', profile.tutorId);
      if (profile.offerings.isNotEmpty) {
        await _client.from('tutor_offerings').insert(
              profile.offerings.map((o) => o.toRow(profile.tutorId)).toList(),
            );
      }

      // 3. Upsert availability.
      await _client.from('tutor_availability').upsert({
        'tutor_id': profile.tutorId,
        'slots': profile.availability.toJson(),
      });

      // 4. Replace credentials.
      await _client.from('tutor_education').delete().eq('tutor_id', profile.tutorId);
      if (profile.education.isNotEmpty) {
        await _client.from('tutor_education').insert(
              profile.education.map((e) => e.toRow(profile.tutorId)).toList(),
            );
      }
      await _client.from('tutor_experience').delete().eq('tutor_id', profile.tutorId);
      if (profile.experience.isNotEmpty) {
        await _client.from('tutor_experience').insert(
              profile.experience.map((e) => e.toRow(profile.tutorId)).toList(),
            );
      }
      await _client.from('tutor_certificates').delete().eq('tutor_id', profile.tutorId);
      if (profile.certificates.isNotEmpty) {
        await _client.from('tutor_certificates').insert(
              profile.certificates.map((c) => c.toRow(profile.tutorId)).toList(),
            );
      }

      return load(profile.tutorId);
    } on sb.PostgrestException catch (e) {
      throw TutorRepositoryException('save_failed', e.message);
    }
  }

  @override
  Future<TutorProfile> publish(TutorProfile profile) async {
    if (!profile.isPublishable) {
      throw TutorRepositoryException(
          'not_publishable', 'Reach 80% profile completion before publishing.');
    }
    return save(profile.copyWith(draftStatus: 'published'));
  }

  TutorProfile _profileFromRows({
    required String tutorId,
    required Map<String, dynamic> tutorRow,
    required List<Map<String, dynamic>> offeringRows,
    required Map<String, dynamic>? availabilityRow,
    required List<Map<String, dynamic>> educationRows,
    required List<Map<String, dynamic>> experienceRows,
    required List<Map<String, dynamic>> certificateRows,
  }) {
    return TutorProfile(
      tutorId: tutorId,
      teachingMode: TeachingMode.fromString(tutorRow['teaching_mode'] as String?),
      levelsTaught: ((tutorRow['levels_taught'] as List?) ?? const [])
          .map((v) => StudentLevel.fromValue(v as String))
          .toSet(),
      languagesKnown: ((tutorRow['languages_known'] as List?) ?? const [])
          .map((v) => v as String)
          .toList(),
      nativeLanguage: tutorRow['native_language'] as String?,
      aboutMe: tutorRow['about_me'] as String?,
      aboutSessions: tutorRow['about_sessions'] as String?,
      qualifications: tutorRow['qualifications'] as String?,
      tagline: tutorRow['tagline'] as String?,
      country: (tutorRow['country'] as String?) ?? 'Nepal',
      zone: tutorRow['zone'] as String?,
      city: tutorRow['city'] as String?,
      addressLine: tutorRow['address_line'] as String?,
      serviceRadiusKm: (tutorRow['service_radius_km'] as num?) ?? 5,
      draftStatus: (tutorRow['draft_status'] as String?) ?? 'draft',
      profileCompletion: (tutorRow['profile_completion'] as int?) ?? 0,
      offerings: offeringRows.map(TutorOffering.fromRow).toList(),
      availability:
          TutorAvailability.fromJson(availabilityRow?['slots'] as Map<String, dynamic>?),
      education: educationRows.map(TutorEducation.fromRow).toList(),
      experience: experienceRows.map(TutorExperience.fromRow).toList(),
      certificates: certificateRows.map(TutorCertificate.fromRow).toList(),
    );
  }
}
