import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/utils/pdf_validator.dart';

void main() {
  group('PdfValidator', () {
    test('accepts bytes with a %PDF- header', () {
      final bytes = Uint8List.fromList(
          [0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x37]); // %PDF-1.7
      expect(PdfValidator.isPdf(bytes), isTrue);
    });

    test('rejects non-PDF bytes (e.g. a JPEG header)', () {
      final bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);
      expect(PdfValidator.isPdf(bytes), isFalse);
    });

    test('rejects bytes shorter than the magic header', () {
      expect(PdfValidator.isPdf(Uint8List.fromList([0x25, 0x50])), isFalse);
    });
  });
}
