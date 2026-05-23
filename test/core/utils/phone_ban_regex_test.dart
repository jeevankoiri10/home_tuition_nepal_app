import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/utils/phone_ban_regex.dart';

void main() {
  group('PhoneBanRegex.isViolation', () {
    test('flags bare 10-digit Nepali mobile', () {
      expect(PhoneBanRegex.isViolation('Call me at 9812345678'), isTrue);
    });

    test('flags spaced / dashed phone formats', () {
      expect(PhoneBanRegex.isViolation('My number 98 12 345 678'), isTrue);
      expect(PhoneBanRegex.isViolation('phone 98-12-345-678'), isTrue);
    });

    test('flags international prefix', () {
      expect(PhoneBanRegex.isViolation('Reach me on +977 98 1234 5678'), isTrue);
    });

    test('flags email addresses', () {
      expect(PhoneBanRegex.isViolation('Email me at me@example.com'), isTrue);
    });

    test('flags WhatsApp / Telegram links', () {
      expect(PhoneBanRegex.isViolation('https://wa.me/9779801234567'), isTrue);
      expect(PhoneBanRegex.isViolation('join my t.me/something'), isTrue);
    });

    test('does not flag innocuous short numbers (Class 11, age 18)', () {
      expect(PhoneBanRegex.isViolation('I teach Class 11 and Class 12.'), isFalse);
      expect(PhoneBanRegex.isViolation('Age 18+ welcome.'), isFalse);
    });

    test('does not flag empty string', () {
      expect(PhoneBanRegex.isViolation(''), isFalse);
    });
  });
}
