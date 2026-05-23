import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/tutor_profile/data/fake_tutor_repository.dart';
import 'package:home_tuition_nepal_app/features/tutor_profile/domain/models/profile_enums.dart';
import 'package:home_tuition_nepal_app/features/tutor_profile/domain/models/tutor_offering.dart';
import 'package:home_tuition_nepal_app/features/tutor_profile/domain/models/tutor_profile.dart';
import 'package:home_tuition_nepal_app/features/tutor_profile/presentation/blocs/tutor_profile_bloc.dart';

void main() {
  group('TutorProfileBloc', () {
    blocTest<TutorProfileBloc, TutorProfileState>(
      'load → ready',
      build: () => TutorProfileBloc(FakeTutorRepository()),
      act: (bloc) => bloc.add(const TutorProfileLoaded('t1')),
      wait: const Duration(milliseconds: 400),
      verify: (bloc) {
        expect(bloc.state.status, TutorProfileStatus.ready);
        expect(bloc.state.profile, isNotNull);
        expect(bloc.state.profile!.tutorId, 't1');
      },
    );

    blocTest<TutorProfileBloc, TutorProfileState>(
      'draft update triggers auto-save and updates completion %',
      build: () => TutorProfileBloc(FakeTutorRepository()),
      act: (bloc) async {
        bloc.add(const TutorProfileLoaded('t1'));
        await Future<void>.delayed(const Duration(milliseconds: 400));
        bloc.add(TutorProfileDraftUpdated(bloc.state.profile!.copyWith(
          levelsTaught: {StudentLevel.see},
          offerings: [TutorOffering(level: StudentLevel.see, subject: 'Maths', priceMinNpr: 5000)],
        )));
      },
      wait: const Duration(milliseconds: 1500),
      verify: (bloc) {
        // auto-save has fired by now (800 ms debounce).
        expect(bloc.state.status, TutorProfileStatus.ready);
        expect(bloc.state.profile!.profileCompletion, greaterThan(10));
        expect(bloc.state.lastSavedAt, isNotNull);
      },
    );

    blocTest<TutorProfileBloc, TutorProfileState>(
      'publish below 80% errors',
      build: () => TutorProfileBloc(FakeTutorRepository()),
      act: (bloc) async {
        bloc.add(const TutorProfileLoaded('t1'));
        await Future<void>.delayed(const Duration(milliseconds: 400));
        bloc.add(const TutorProfilePublishRequested());
      },
      wait: const Duration(milliseconds: 700),
      verify: (bloc) {
        expect(bloc.state.status, TutorProfileStatus.error);
        expect(bloc.state.errorMessage, contains('80%'));
      },
    );

    blocTest<TutorProfileBloc, TutorProfileState>(
      'fully-completed profile publishes',
      build: () => TutorProfileBloc(FakeTutorRepository()),
      act: (bloc) async {
        bloc.add(const TutorProfileLoaded('t1'));
        await Future<void>.delayed(const Duration(milliseconds: 400));
        final complete = TutorProfile(
          tutorId: 't1',
          teachingMode: TeachingMode.both,
          levelsTaught: {StudentLevel.see, StudentLevel.plus2},
          offerings: [
            TutorOffering(level: StudentLevel.see, subject: 'Maths', priceMinNpr: 5000),
            TutorOffering(level: StudentLevel.see, subject: 'Science', priceMinNpr: 5000),
            TutorOffering(level: StudentLevel.plus2, subject: 'Physics', priceMinNpr: 7000),
          ],
          aboutMe: 'A' * 120,
          aboutSessions: 'B' * 60,
          qualifications: 'C' * 40,
          languagesKnown: const ['English'],
        );
        bloc.add(TutorProfileDraftUpdated(complete));
        await Future<void>.delayed(const Duration(milliseconds: 100));
        bloc.add(const TutorProfilePublishRequested());
      },
      wait: const Duration(milliseconds: 1000),
      verify: (bloc) {
        expect(bloc.state.status, TutorProfileStatus.published);
        expect(bloc.state.profile!.isPublished, isTrue);
      },
    );
  });
}
