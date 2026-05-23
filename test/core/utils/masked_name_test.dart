import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/utils/masked_name.dart';

void main() {
  group('maskedName', () {
    test('returns Firstname + first letter of surname + asterisk', () {
      expect(maskedName('Ramesh', 'Shrestha'), 'Ramesh S*');
      expect(maskedName('Sita', 'Khanal'), 'Sita K*');
    });

    test('uppercases the surname initial', () {
      expect(maskedName('Anu', 'pandey'), 'Anu P*');
    });

    test('handles single-letter surname', () {
      expect(maskedName('John', 'D'), 'John D*');
    });

    test('returns first name only when surname is empty', () {
      expect(maskedName('Madonna', ''), 'Madonna');
      expect(maskedName('Madonna', '   '), 'Madonna');
    });

    test('trims surrounding whitespace', () {
      expect(maskedName('  Sita  ', '  Khanal  '), 'Sita K*');
    });
  });
}
