import 'package:equatable/equatable.dart';

import 'profile_enums.dart';
import 'tutor_availability.dart';
import 'tutor_credentials.dart';
import 'tutor_offering.dart';

/// Aggregate held in memory while the wizard / Profile Settings editor is open.
/// One TutorProfile == one tutor row + their offerings + availability + credentials.
class TutorProfile extends Equatable {
  TutorProfile({
    required this.tutorId,
    this.teachingMode = TeachingMode.offline,
    Set<StudentLevel>? levelsTaught,
    this.serviceRadiusKm = 5,
    this.tagline,
    this.aboutMe,
    this.aboutSessions,
    this.qualifications,
    List<String>? languagesKnown,
    this.nativeLanguage,
    this.country = 'Nepal',
    this.zone,
    this.city,
    this.addressLine,
    List<TutorOffering>? offerings,
    TutorAvailability? availability,
    List<TutorEducation>? education,
    List<TutorExperience>? experience,
    List<TutorCertificate>? certificates,
    this.draftStatus = 'draft',
    this.profileCompletion = 0,
  })  : levelsTaught = levelsTaught ?? <StudentLevel>{},
        languagesKnown = languagesKnown ?? const <String>[],
        offerings = offerings ?? const <TutorOffering>[],
        availability = availability ?? TutorAvailability(),
        education = education ?? const <TutorEducation>[],
        experience = experience ?? const <TutorExperience>[],
        certificates = certificates ?? const <TutorCertificate>[];

  final String tutorId;
  final TeachingMode teachingMode;
  final Set<StudentLevel> levelsTaught;
  final num serviceRadiusKm;
  final String? tagline;
  final String? aboutMe;
  final String? aboutSessions;
  final String? qualifications;
  final List<String> languagesKnown;
  final String? nativeLanguage;
  final String country;
  final String? zone;
  final String? city;
  final String? addressLine;
  final List<TutorOffering> offerings;
  final TutorAvailability availability;
  final List<TutorEducation> education;
  final List<TutorExperience> experience;
  final List<TutorCertificate> certificates;
  final String draftStatus;
  final int profileCompletion;

  bool get isPublishable => profileCompletion >= 80;
  bool get isPublished => draftStatus == 'published';

  TutorProfile copyWith({
    TeachingMode? teachingMode,
    Set<StudentLevel>? levelsTaught,
    num? serviceRadiusKm,
    String? tagline,
    String? aboutMe,
    String? aboutSessions,
    String? qualifications,
    List<String>? languagesKnown,
    String? nativeLanguage,
    String? country,
    String? zone,
    String? city,
    String? addressLine,
    List<TutorOffering>? offerings,
    TutorAvailability? availability,
    List<TutorEducation>? education,
    List<TutorExperience>? experience,
    List<TutorCertificate>? certificates,
    String? draftStatus,
    int? profileCompletion,
  }) {
    return TutorProfile(
      tutorId: tutorId,
      teachingMode: teachingMode ?? this.teachingMode,
      levelsTaught: levelsTaught ?? this.levelsTaught,
      serviceRadiusKm: serviceRadiusKm ?? this.serviceRadiusKm,
      tagline: tagline ?? this.tagline,
      aboutMe: aboutMe ?? this.aboutMe,
      aboutSessions: aboutSessions ?? this.aboutSessions,
      qualifications: qualifications ?? this.qualifications,
      languagesKnown: languagesKnown ?? this.languagesKnown,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      country: country ?? this.country,
      zone: zone ?? this.zone,
      city: city ?? this.city,
      addressLine: addressLine ?? this.addressLine,
      offerings: offerings ?? this.offerings,
      availability: availability ?? this.availability,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      certificates: certificates ?? this.certificates,
      draftStatus: draftStatus ?? this.draftStatus,
      profileCompletion: profileCompletion ?? this.profileCompletion,
    );
  }

  /// Mirrors compute_tutor_completion() in supabase/migrations/0002_phase3_tutors.sql.
  /// Kept in sync so the UI can show an instant local estimate before the server
  /// trigger writes the authoritative value back.
  static int computeCompletion(TutorProfile p) {
    int score = 0;
    score += 10; // teaching_mode is always set
    if (p.levelsTaught.isNotEmpty) score += 15;
    if (p.offerings.isNotEmpty) score += 20;
    if (p.offerings.length >= 3) score += 5;
    if ((p.aboutMe ?? '').length >= 100) score += 10;
    if ((p.aboutSessions ?? '').length >= 50) score += 10;
    if ((p.qualifications ?? '').length >= 30) score += 10;
    if (p.availability.isSet) score += 15;
    if (p.languagesKnown.isNotEmpty) score += 5;
    if (score > 100) score = 100;
    return score;
  }

  @override
  List<Object?> get props => [
        tutorId,
        teachingMode,
        levelsTaught,
        serviceRadiusKm,
        tagline,
        aboutMe,
        aboutSessions,
        qualifications,
        languagesKnown,
        nativeLanguage,
        country,
        zone,
        city,
        addressLine,
        offerings,
        availability,
        education,
        experience,
        certificates,
        draftStatus,
        profileCompletion,
      ];
}
