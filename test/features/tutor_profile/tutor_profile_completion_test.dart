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

    test('adding levels + offerings + about sections climbs the score', () {
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
      );
      expect(TutorProfile.computeCompletion(p), 100);
      expect(p.copyWith(profileCompletion: TutorProfile.computeCompletion(p)).isPublishable, isTrue);
    });

    test('about-me below 100 chars yields no about_me credit', () {
      final p = TutorProfile(tutorId: 't1', aboutMe: 'too short');
      expect(TutorProfile.computeCompletion(p), 10);
    });
  });
}
