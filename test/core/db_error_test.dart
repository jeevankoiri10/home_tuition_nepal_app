import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/utils/db_error.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

void main() {
  group('friendlyDbMessage', () {
    test('RLS denial → permission hint', () {
      final e = sb.PostgrestException(message: 'new row violates row-level security policy');
      expect(friendlyDbMessage(e, fallback: 'x'), contains('permission'));
    });

    test('NOT NULL violation (23502) → required-fields hint', () {
      final e = sb.PostgrestException(message: 'null value', code: '23502');
      expect(friendlyDbMessage(e, fallback: 'x'), contains('required'));
    });

    test('FK violation (23503) → account-setup hint', () {
      final e = sb.PostgrestException(message: 'fk', code: '23503');
      expect(friendlyDbMessage(e, fallback: 'x').toLowerCase(), contains('account'));
    });

    test('missing relation → unavailable hint', () {
      final e = sb.PostgrestException(message: 'relation "jobs" does not exist');
      expect(friendlyDbMessage(e, fallback: 'x').toLowerCase(), contains('available'));
    });

    test('unknown error → fallback', () {
      final e = sb.PostgrestException(message: 'something weird', code: 'P0001');
      expect(friendlyDbMessage(e, fallback: 'fallback-msg'), 'fallback-msg');
    });

    test('non-Postgrest error → fallback', () {
      expect(friendlyDbMessage(Exception('boom'), fallback: 'fallback-msg'), 'fallback-msg');
    });
  });
}
