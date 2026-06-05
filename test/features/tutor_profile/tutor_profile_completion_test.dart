import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/tutor_profile/domain/models/profile_enums.dart';
import 'package:home_tuition_nepal_app/features/tutor_profile/domain/models/tutor_availability.dart';
import 'package:home_tuition_nepal_app/features/tutor_profile/domain/models/tutor_offering.dart';
import 'package:home_tuition_nepal_app/features/tutor_profile/domain/models/tutor_profile.dart';

void main() {
  group('TutorProfile.computeCompletion', () {
    test('fresh profile scores only the teaching-mode credit', () {
      final p = TutorProfile(tutorId: 't1');
      expect(TutorProfile.computeCompletion(p), 10);
    });

    test('a fully filled profile (incl. location + CV) scores 100', () {
      final p = TutorProfile(
        tutorId: 't1',
        levelsTaught: {StudentLevel.see, StudentLevel.plus2},
        offerings: [
          TutorOffering(level: StudentLevel.see, subject: 'Maths', priceMinNpr: 5000),
          TutorOffering(level: StudentLevel.see, subject: 'Science', priceMinNpr: 5000),
          TutorOffering(level: StudentLevel.plus2, subject: 'Physics', priceMinNpr: 7000),
        ],
        aboutMe: 'A' * 120,
        aboutSessions: 'B' * 60,
        qualifications: 'C' * 40,
        languagesKnown: const ['English', 'Nepali'],
        availability: TutorAvailability().toggleRow(TimeBand.midday, value: true),
        lat: 27.7,
        lng: 85.3,
        cvUrl: 'https://example.com/cv.pdf',
      );
      expect(TutorProfile.computeCompletion(p), 100);
      expect(p.copyWith(profileCompletion: TutorProfile.computeCompletion(p)).isPublishable, isTrue);
    });

    test('location pin and CV each contribute to the score', () {
      final base = TutorProfile(tutorId: 't1'); // 10 (teaching mode default)
      expect(TutorProfile.computeCompletion(base), 10);
      expect(TutorProfile.computeCompletion(base.copyWith(lat: 27.7, lng: 85.3)), 15);
      expect(
        TutorProfile.computeCompletion(base.copyWith(cvUrl: 'https://x/cv.pdf')),
        20,
      );
    });

    test('about-me below 100 chars yields no about_me credit', () {
      final p = TutorProfile(tutorId: 't1', aboutMe: 'too short');
      expect(TutorProfile.computeCompletion(p), 10);
    });
  });
}
