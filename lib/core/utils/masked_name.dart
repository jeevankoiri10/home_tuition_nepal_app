/// Derives the public-facing masked name from a user's real first and last name.
///
/// Examples:
///   maskedName('Ramesh', 'Shrestha') => 'Ramesh S*'
///   maskedName('Sita',   'Khanal')   => 'Sita K*'
///   maskedName('John',   'D')        => 'John D*'
///   maskedName('Madonna', '')        => 'Madonna'
///
/// The masked form is what every other user sees in the app. The real name is
/// only revealed to the counterparty after a paid contact unlock or an admin
/// assignment, per docs/plan.md §5.5.
String maskedName(String first, String last) {
  final f = first.trim();
  final l = last.trim();
  if (l.isEmpty) return f;
  return '$f ${l[0].toUpperCase()}*';
}
