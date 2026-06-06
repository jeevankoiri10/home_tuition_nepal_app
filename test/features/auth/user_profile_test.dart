import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/utils/masked_name.dart';
import 'package:home_tuition_nepal_app/features/auth/domain/models/user_profile.dart';
import 'package:home_tuition_nepal_app/features/auth/domain/models/user_role.dart';

UserProfile _profile({
  String first = 'Ramesh',
  String last = 'Shrestha',
}) =>
    UserProfile(
      id: 'u1',
      firstName: first,
      lastName: last,
      email: 'ramesh@example.com',
      phone: '+9779800000000',
      emailVerified: false,
      role: UserRole.tutor,
      handle: 'ramesh99',
      tosAcceptedAt: DateTime(2026, 1, 1),
      coinBalance: 50,
    );

void main() {
  group('UserProfile.displayName (privacy invariant)', () {
    test('returns the masked name, never the raw full name', () {
      final p = _profile(first: 'Ramesh', last: 'Shrestha');
      expect(p.displayName, 'Ramesh S*');
      expect(p.displayName, isNot('Ramesh Shrestha'));
    });

    test('delegates to maskedName for any name', () {
      final p = _profile(first: 'Sita', last: 'Khanal');
      expect(p.displayName, maskedName('Sita', 'Khanal'));
    });

    test('never contains the full last name', () {
      final p = _profile(first: 'Anita', last: 'Gurung');
      expect(p.displayName.contains('Gurung'), isFalse);
    });
  });

  group('UserProfile.copyWith', () {
    test('mutates only emailVerified / coinBalance / codeOfConduct', () {
      final p = _profile();
      final updated = p.copyWith(
        emailVerified: true,
        coinBalance: 200,
        codeOfConductAcceptedAt: DateTime(2026, 2, 2),
      );

      expect(updated.emailVerified, isTrue);
      expect(updated.coinBalance, 200);
      expect(updated.codeOfConductAcceptedAt, DateTime(2026, 2, 2));

      // Identity fields are immutable through copyWith.
      expect(updated.id, p.id);
      expect(updated.firstName, p.firstName);
      expect(updated.lastName, p.lastName);
      expect(updated.email, p.email);
      expect(updated.phone, p.phone);
      expect(updated.handle, p.handle);
      expect(updated.role, p.role);
    });

    test('with no arguments equals the original', () {
      final p = _profile();
      expect(p.copyWith(), p);
    });
  });
}
