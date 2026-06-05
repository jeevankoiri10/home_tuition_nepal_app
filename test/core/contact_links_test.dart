import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/utils/contact_links.dart';

void main() {
  group('ContactLinks', () {
    test('tel keeps the E.164 number verbatim', () {
      final uri = ContactLinks.tel('+9779812345678');
      expect(uri.scheme, 'tel');
      expect(uri.path, '+9779812345678');
      expect(uri.toString(), 'tel:+9779812345678');
    });

    test('tel trims surrounding whitespace', () {
      expect(ContactLinks.tel('  +9779812345678 ').path, '+9779812345678');
    });

    test('whatsApp strips the + and punctuation to digits only', () {
      final uri = ContactLinks.whatsApp('+977 98-123 45678');
      expect(uri.toString(), 'https://wa.me/9779812345678');
    });

    test('whatsApp on a clean E.164 number', () {
      expect(ContactLinks.whatsApp('+9779812345678').toString(),
          'https://wa.me/9779812345678');
    });
  });
}
