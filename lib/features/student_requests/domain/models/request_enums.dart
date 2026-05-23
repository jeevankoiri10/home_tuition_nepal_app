enum JobType {
  homeTuition('home_tuition', 'Home tuition'),
  onlineTuition('online_tuition', 'Online tuition'),
  assignmentHelp('assignment_help', 'Assignment help');

  const JobType(this.value, this.label);
  final String value;
  final String label;

  static JobType fromString(String? raw) => JobType.values.firstWhere(
        (t) => t.value == raw,
        orElse: () => JobType.homeTuition,
      );
}

enum JobStatus {
  open('open', 'Open'),
  shortlisting('shortlisting', 'Shortlisting'),
  hired('hired', 'Hired'),
  closed('closed', 'Closed'),
  expired('expired', 'Expired');

  const JobStatus(this.value, this.label);
  final String value;
  final String label;

  static JobStatus fromString(String? raw) => JobStatus.values.firstWhere(
        (s) => s.value == raw,
        orElse: () => JobStatus.open,
      );
}

enum EngagementType {
  fullTime('full_time', 'Full time'),
  partTime('part_time', 'Part time'),
  oneOff('one_off', 'One-off');

  const EngagementType(this.value, this.label);
  final String value;
  final String label;

  static EngagementType? fromString(String? raw) {
    if (raw == null) return null;
    for (final e in EngagementType.values) {
      if (e.value == raw) return e;
    }
    return null;
  }
}

enum BudgetPeriod {
  hour('hour', '/hour'),
  day('day', '/day'),
  month('month', '/month'),
  session('session', '/session'),
  fixed('fixed', ' fixed');

  const BudgetPeriod(this.value, this.suffix);
  final String value;
  final String suffix;

  static BudgetPeriod fromString(String? raw) => BudgetPeriod.values.firstWhere(
        (p) => p.value == raw,
        orElse: () => BudgetPeriod.month,
      );
}

enum JobMode {
  inPerson('in-person', 'In-person'),
  online('online', 'Online'),
  either('either', 'Either');

  const JobMode(this.value, this.label);
  final String value;
  final String label;

  static JobMode fromString(String? raw) => JobMode.values.firstWhere(
        (m) => m.value == raw,
        orElse: () => JobMode.inPerson,
      );
}

enum GenderPref {
  any('any', 'Any'),
  male('male', 'Male'),
  female('female', 'Female');

  const GenderPref(this.value, this.label);
  final String value;
  final String label;

  static GenderPref fromString(String? raw) => GenderPref.values.firstWhere(
        (g) => g.value == raw,
        orElse: () => GenderPref.any,
      );
}

enum VacancyStatus {
  pendingAdminReview('pending_admin_review', 'Pending admin review'),
  open('open', 'Open'),
  applicationsClosed('applications_closed', 'Applications closed'),
  filled('filled', 'Filled'),
  cancelled('cancelled', 'Cancelled');

  const VacancyStatus(this.value, this.label);
  final String value;
  final String label;

  static VacancyStatus fromString(String? raw) => VacancyStatus.values.firstWhere(
        (s) => s.value == raw,
        orElse: () => VacancyStatus.pendingAdminReview,
      );
}
