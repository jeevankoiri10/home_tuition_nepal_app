/// User role — exactly one per account, immutable after first set.
/// See docs/plan.md §5.1.
enum UserRole {
  tutor,
  student;

  String get value => name;

  static UserRole fromString(String raw) {
    return UserRole.values.firstWhere(
      (r) => r.name == raw,
      orElse: () => UserRole.student,
    );
  }
}
