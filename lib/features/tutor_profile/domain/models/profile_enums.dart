/// Closed taxonomies that map 1:1 to Postgres CHECK constraints.
/// Keep the `value` strings in sync with supabase/migrations/0002_phase3_tutors.sql.
library;

enum TeachingMode {
  online,
  offline,
  both;

  String get value => name;

  String get label {
    switch (this) {
      case TeachingMode.online:
        return 'Online';
      case TeachingMode.offline:
        return 'Offline (in-person)';
      case TeachingMode.both:
        return 'Both';
    }
  }

  static TeachingMode fromString(String? raw) => TeachingMode.values.firstWhere(
        (m) => m.name == raw,
        orElse: () => TeachingMode.offline,
      );
}

enum StudentLevel {
  belowClass9('below_class_9', 'Below Class 9'),
  see('see', 'SEE'),
  plus2('plus_2', '+2'),
  aLevel('a_level', 'A Level');

  const StudentLevel(this.value, this.label);

  final String value;
  final String label;

  static StudentLevel fromValue(String raw) => StudentLevel.values.firstWhere(
        (l) => l.value == raw,
        orElse: () => StudentLevel.belowClass9,
      );
}

enum PricePeriod {
  hour('hour', '/hour'),
  day('day', '/day'),
  month('month', '/month'),
  session('session', '/session');

  const PricePeriod(this.value, this.suffix);

  final String value;
  final String suffix;

  static PricePeriod fromString(String? raw) => PricePeriod.values.firstWhere(
        (p) => p.value == raw,
        orElse: () => PricePeriod.month,
      );
}

enum TimeBand {
  pre10am('pre_10am', 'Pre 10 am'),
  midday('10_5pm', '10 am – 5 pm'),
  after5pm('after_5pm', 'After 5 pm');

  const TimeBand(this.value, this.label);

  final String value;
  final String label;

  static TimeBand fromString(String raw) => TimeBand.values.firstWhere(
        (b) => b.value == raw,
        orElse: () => TimeBand.midday,
      );
}

enum Weekday {
  sun('sun', 'Sun'),
  mon('mon', 'Mon'),
  tue('tue', 'Tue'),
  wed('wed', 'Wed'),
  thu('thu', 'Thu'),
  fri('fri', 'Fri'),
  sat('sat', 'Sat');

  const Weekday(this.value, this.short);

  final String value;
  final String short;

  static Weekday fromValue(String raw) => Weekday.values.firstWhere(
        (d) => d.value == raw,
        orElse: () => Weekday.mon,
      );
}
