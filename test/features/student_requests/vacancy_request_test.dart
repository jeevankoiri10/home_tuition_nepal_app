import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/student_requests/domain/models/request_enums.dart';
import 'package:home_tuition_nepal_app/features/student_requests/domain/models/vacancy_request.dart';

VacancyRequest _vr({
  num? min,
  num? max,
  String period = 'month',
}) =>
    VacancyRequest(
      linkedStudent: 's1',
      title: 'Maths tutor needed',
      areaLabel: 'Baneshwor',
      subjects: const ['Maths', 'Science'],
      salaryMinNpr: min,
      salaryMaxNpr: max,
      salaryPeriod: period,
      genderPref: GenderPref.female,
      mode: JobMode.inPerson,
      status: VacancyStatus.open,
    );

void main() {
  group('VacancyRequest.formatSalary', () {
    test('dash when no minimum', () {
      expect(_vr(min: null).formatSalary(), '—');
    });

    test('single amount with period', () {
      expect(_vr(min: 12000).formatSalary(), 'Rs. 12,000/month');
    });

    test('distinct min/max renders a range', () {
      expect(_vr(min: 10000, max: 15000).formatSalary(), 'Rs. 10,000–15,000/month');
    });

    test('max equal to min collapses to single', () {
      expect(_vr(min: 9000, max: 9000).formatSalary(), 'Rs. 9,000/month');
    });
  });

  group('VacancyRequest serialization', () {
    test('toInsertRow → fromRow round-trips the core fields', () {
      final original = _vr(min: 10000, max: 15000);
      final restored = VacancyRequest.fromRow(original.toInsertRow());

      expect(restored.title, original.title);
      expect(restored.areaLabel, original.areaLabel);
      expect(restored.subjects, original.subjects);
      expect(restored.salaryMinNpr, original.salaryMinNpr);
      expect(restored.salaryMaxNpr, original.salaryMaxNpr);
      expect(restored.salaryPeriod, original.salaryPeriod);
      expect(restored.genderPref, GenderPref.female);
      expect(restored.mode, JobMode.inPerson);
      expect(restored.status, VacancyStatus.open);
    });

    test('fromRow applies defaults for missing optional columns', () {
      final vr = VacancyRequest.fromRow({'linked_student': 's9'});
      expect(vr.title, 'Vacancy');
      expect(vr.numStudents, 1);
      expect(vr.salaryPeriod, 'month');
      expect(vr.subjects, isEmpty);
      expect(vr.status, VacancyStatus.pendingAdminReview);
    });
  });
}
