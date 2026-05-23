import 'package:equatable/equatable.dart';

import 'request_enums.dart';

class JobPost extends Equatable {
  const JobPost({
    this.id,
    required this.studentId,
    required this.title,
    this.description,
    this.jobType = JobType.homeTuition,
    this.subject,
    this.gradeLevel,
    this.areaLabel,
    this.schedule,
    this.engagementType,
    this.dueDate,
    this.budgetMinNpr,
    this.budgetMaxNpr,
    this.budgetPeriod = BudgetPeriod.month,
    this.mode = JobMode.inPerson,
    this.genderPref = GenderPref.any,
    this.communicateLanguages = const [],
    this.canTravel = true,
    this.status = JobStatus.open,
    this.createdAt,
  });

  final String? id;
  final String studentId;
  final String title;
  final String? description;
  final JobType jobType;
  final String? subject;
  final String? gradeLevel;
  final String? areaLabel;
  final String? schedule;
  final EngagementType? engagementType;
  final DateTime? dueDate;
  final num? budgetMinNpr;
  final num? budgetMaxNpr;
  final BudgetPeriod budgetPeriod;
  final JobMode mode;
  final GenderPref genderPref;
  final List<String> communicateLanguages;
  final bool canTravel;
  final JobStatus status;
  final DateTime? createdAt;

  String formatBudget() {
    if (budgetMinNpr == null) return '—';
    final min = _formatNpr(budgetMinNpr!);
    if (budgetPeriod == BudgetPeriod.fixed) {
      return 'Rs. $min (fixed)';
    }
    if (budgetMaxNpr != null && budgetMaxNpr != budgetMinNpr) {
      return 'Rs. $min–${_formatNpr(budgetMaxNpr!)}${budgetPeriod.suffix}';
    }
    return 'Rs. $min${budgetPeriod.suffix}';
  }

  JobPost copyWith({
    String? id,
    String? title,
    String? description,
    JobType? jobType,
    String? subject,
    String? gradeLevel,
    String? areaLabel,
    String? schedule,
    EngagementType? engagementType,
    DateTime? dueDate,
    num? budgetMinNpr,
    num? budgetMaxNpr,
    BudgetPeriod? budgetPeriod,
    JobMode? mode,
    GenderPref? genderPref,
    List<String>? communicateLanguages,
    bool? canTravel,
    JobStatus? status,
  }) {
    return JobPost(
      id: id ?? this.id,
      studentId: studentId,
      title: title ?? this.title,
      description: description ?? this.description,
      jobType: jobType ?? this.jobType,
      subject: subject ?? this.subject,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      areaLabel: areaLabel ?? this.areaLabel,
      schedule: schedule ?? this.schedule,
      engagementType: engagementType ?? this.engagementType,
      dueDate: dueDate ?? this.dueDate,
      budgetMinNpr: budgetMinNpr ?? this.budgetMinNpr,
      budgetMaxNpr: budgetMaxNpr ?? this.budgetMaxNpr,
      budgetPeriod: budgetPeriod ?? this.budgetPeriod,
      mode: mode ?? this.mode,
      genderPref: genderPref ?? this.genderPref,
      communicateLanguages: communicateLanguages ?? this.communicateLanguages,
      canTravel: canTravel ?? this.canTravel,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toInsertRow() => {
        'student_id': studentId,
        'title': title,
        'description': description,
        'job_type': jobType.value,
        'subject': subject,
        'grade_level': gradeLevel,
        'area_label': areaLabel,
        'schedule': schedule,
        'engagement_type': engagementType?.value,
        'due_date': dueDate?.toIso8601String(),
        'budget_min_npr': budgetMinNpr,
        'budget_max_npr': budgetMaxNpr,
        'budget_period': budgetPeriod.value,
        'mode': mode.value,
        'gender_pref': genderPref.value,
        'communicate_languages': communicateLanguages,
        'can_travel': canTravel,
        'status': status.value,
      };

  static JobPost fromRow(Map<String, dynamic> row) => JobPost(
        id: row['id'] as String?,
        studentId: row['student_id'] as String,
        title: (row['title'] as String?) ?? 'Untitled',
        description: row['description'] as String?,
        jobType: JobType.fromString(row['job_type'] as String?),
        subject: row['subject'] as String?,
        gradeLevel: row['grade_level'] as String?,
        areaLabel: row['area_label'] as String?,
        schedule: row['schedule'] as String?,
        engagementType: EngagementType.fromString(row['engagement_type'] as String?),
        dueDate: row['due_date'] == null ? null : DateTime.tryParse(row['due_date'] as String),
        budgetMinNpr: row['budget_min_npr'] as num?,
        budgetMaxNpr: row['budget_max_npr'] as num?,
        budgetPeriod: BudgetPeriod.fromString(row['budget_period'] as String?),
        mode: JobMode.fromString(row['mode'] as String?),
        genderPref: GenderPref.fromString(row['gender_pref'] as String?),
        communicateLanguages:
            ((row['communicate_languages'] as List?) ?? const []).map((v) => v as String).toList(),
        canTravel: (row['can_travel'] as bool?) ?? true,
        status: JobStatus.fromString(row['status'] as String?),
        createdAt:
            row['created_at'] == null ? null : DateTime.tryParse(row['created_at'] as String),
      );

  static String _formatNpr(num n) {
    final s = n.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  List<Object?> get props => [
        id,
        studentId,
        title,
        description,
        jobType,
        subject,
        gradeLevel,
        areaLabel,
        schedule,
        engagementType,
        dueDate,
        budgetMinNpr,
        budgetMaxNpr,
        budgetPeriod,
        mode,
        genderPref,
        communicateLanguages,
        canTravel,
        status,
      ];
}
