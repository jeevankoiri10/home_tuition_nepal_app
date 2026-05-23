import 'package:equatable/equatable.dart';

import '../../../../core/utils/masked_name.dart';
import 'user_role.dart';

/// In-memory representation of the `profiles` row for the current user.
/// Private fields (`firstName`, `lastName`, `phone`, `email`) are only ever
/// available to the owner — they are never sent to other clients.
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.emailVerified,
    required this.role,
    required this.handle,
    required this.tosAcceptedAt,
    this.codeOfConductAcceptedAt,
    this.coinBalance = 0,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final bool emailVerified;
  final UserRole role;
  final String handle;
  final DateTime tosAcceptedAt;
  final DateTime? codeOfConductAcceptedAt;
  final int coinBalance;

  /// Public-facing display name. Never expose `firstName + lastName` directly.
  String get displayName => maskedName(firstName, lastName);

  UserProfile copyWith({
    bool? emailVerified,
    int? coinBalance,
    DateTime? codeOfConductAcceptedAt,
  }) {
    return UserProfile(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      emailVerified: emailVerified ?? this.emailVerified,
      role: role,
      handle: handle,
      tosAcceptedAt: tosAcceptedAt,
      codeOfConductAcceptedAt: codeOfConductAcceptedAt ?? this.codeOfConductAcceptedAt,
      coinBalance: coinBalance ?? this.coinBalance,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phone,
        emailVerified,
        role,
        handle,
        tosAcceptedAt,
        codeOfConductAcceptedAt,
        coinBalance,
      ];
}
