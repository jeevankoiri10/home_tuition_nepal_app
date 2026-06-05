import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/tutor_profile/data/fake_tutor_repository.dart';
import 'package:home_tuition_nepal_app/features/tutor_profile/domain/tutor_repository.dart';

Uint8List _pdfBytes(int size) {
  final b = Uint8List(size);
  // %PDF- header so PdfValidator passes.
  const header = [0x25, 0x50, 0x44, 0x46, 0x2D];
  for (var i = 0; i < header.length && i < size; i++) {
    b[i] = header[i];
  }
  return b;
}

void main() {
  late FakeTutorRepository repo;
  setUp(() => repo = FakeTutorRepository());

  group('FakeTutorRepository.uploadCv', () {
    test('accepts a valid PDF and stamps cvUrl on the profile', () async {
      await repo.load('t1'); // create the row
      final url = await repo.uploadCv(
        tutorId: 't1',
        bytes: _pdfBytes(2048),
        fileName: 'cv.pdf',
      );
      expect(url, isNotEmpty);
      final profile = await repo.load('t1');
      expect(profile.cvUrl, url);
    });

    test('rejects a non-PDF file', () async {
      await repo.load('t1');
      expect(
        () => repo.uploadCv(
          tutorId: 't1',
          bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]),
          fileName: 'cv.pdf',
        ),
        throwsA(isA<TutorRepositoryException>().having((e) => e.code, 'code', 'cv_not_pdf')),
      );
    });

    test('rejects a CV larger than 300 KB', () async {
      await repo.load('t1');
      expect(
        () => repo.uploadCv(
          tutorId: 't1',
          bytes: _pdfBytes(301 * 1024),
          fileName: 'cv.pdf',
        ),
        throwsA(isA<TutorRepositoryException>().having((e) => e.code, 'code', 'cv_too_large')),
      );
    });
  });
}
