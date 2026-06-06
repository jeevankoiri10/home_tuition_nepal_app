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
    this.whatsapp,
    this.lat,
    this.lng,
    this.onboardingComplete = false,
    this.onboardingStep = 0,
    UserRole? activeRole,
    this.tutorOnboarded = false,
    this.studentOnboarded = false,
    this.isBlocked = false,
  }) : _activeRole = activeRole;

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final bool emailVerified;

  /// Immutable PRIMARY role chosen at first sign-up.
  final UserRole role;
  final String handle;
  final DateTime tosAcceptedAt;
  final DateTime? codeOfConductAcceptedAt;
  final int coinBalance;

  /// WhatsApp number captured during first-run onboarding (nullable until set).
  final String? whatsapp;

  /// Home / service location dropped on the onboarding map (nullable until set).
  final double? lat;
  final double? lng;

  /// True once the user has finished onboarding for their primary role. Kept for
  /// the server-side `set_my_role` guard; per-role gating uses the flags below.
  final bool onboardingComplete;

  /// Zero-indexed onboarding step to resume on after the app is reopened.
  final int onboardingStep;

  /// Which dashboard the user is currently in. Falls back to [role] when unset.
  final UserRole? _activeRole;
  UserRole get activeRole => _activeRole ?? role;

  /// Per-role onboarding completion — drives the router guard so switching into
  /// a not-yet-onboarded role lands on that role's onboarding.
  final bool tutorOnboarded;
  final bool studentOnboarded;

  /// True when an admin has deactivated this account (`profiles.banned_at` set).
  /// The router guard traps blocked users on the non-dismissable blocked screen.
  final bool isBlocked;

  /// True when the role the user is currently acting as has been onboarded.
  bool get activeRoleOnboarded =>
      activeRole == UserRole.tutor ? tutorOnboarded : studentOnboarded;

  /// Public-facing display name. Never expose `firstName + lastName` directly.
  String get displayName => maskedName(firstName, lastName);

  UserProfile copyWith({
    bool? emailVerified,
    int? coinBalance,
    DateTime? codeOfConductAcceptedAt,
    String? whatsapp,
    double? lat,
    double? lng,
    bool? onboardingComplete,
    int? onboardingStep,
    UserRole? activeRole,
    bool? tutorOnboarded,
    bool? studentOnboarded,
    bool? isBlocked,
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
      codeOfConductAcceptedAt:
          codeOfConductAcceptedAt ?? this.codeOfConductAcceptedAt,
      coinBalance: coinBalance ?? this.coinBalance,
      whatsapp: whatsapp ?? this.whatsapp,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      activeRole: activeRole ?? _activeRole,
      tutorOnboarded: tutorOnboarded ?? this.tutorOnboarded,
      studentOnboarded: studentOnboarded ?? this.studentOnboarded,
      isBlocked: isBlocked ?? this.isBlocked,
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
    whatsapp,
    lat,
    lng,
    onboardingComplete,
    onboardingStep,
    activeRole,
    tutorOnboarded,
    studentOnboarded,
    isBlocked,
  ];
}
