import 'package:equatable/equatable.dart';

class TutorEducation extends Equatable {
  const TutorEducation({
    this.id,
    this.degree,
    this.institution,
    this.fieldOfStudy,
    this.startYear,
    this.endYear,
    this.description,
    this.sortOrder = 0,
  });

  final String? id;
  final String? degree;
  final String? institution;
  final String? fieldOfStudy;
  final int? startYear;
  final int? endYear;
  final String? description;
  final int sortOrder;

  TutorEducation copyWith({
    String? degree,
    String? institution,
    String? fieldOfStudy,
    int? startYear,
    int? endYear,
    String? description,
    int? sortOrder,
  }) {
    return TutorEducation(
      id: id,
      degree: degree ?? this.degree,
      institution: institution ?? this.institution,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toRow(String tutorId) => {
        'tutor_id': tutorId,
        'degree': degree,
        'institution': institution,
        'field_of_study': fieldOfStudy,
        'start_year': startYear,
        'end_year': endYear,
        'description': description,
        'sort_order': sortOrder,
      };

  static TutorEducation fromRow(Map<String, dynamic> row) => TutorEducation(
        id: row['id'] as String?,
        degree: row['degree'] as String?,
        institution: row['institution'] as String?,
        fieldOfStudy: row['field_of_study'] as String?,
        startYear: row['start_year'] as int?,
        endYear: row['end_year'] as int?,
        description: row['description'] as String?,
        sortOrder: (row['sort_order'] as int?) ?? 0,
      );

  @override
  List<Object?> get props =>
      [id, degree, institution, fieldOfStudy, startYear, endYear, description, sortOrder];
}

class TutorExperience extends Equatable {
  const TutorExperience({
    this.id,
    this.roleTitle,
    this.organization,
    this.startYear,
    this.endYear,
    this.description,
    this.sortOrder = 0,
  });

  final String? id;
  final String? roleTitle;
  final String? organization;
  final int? startYear;
  final int? endYear;
  final String? description;
  final int sortOrder;

  TutorExperience copyWith({
    String? roleTitle,
    String? organization,
    int? startYear,
    int? endYear,
    String? description,
    int? sortOrder,
  }) {
    return TutorExperience(
      id: id,
      roleTitle: roleTitle ?? this.roleTitle,
      organization: organization ?? this.organization,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toRow(String tutorId) => {
        'tutor_id': tutorId,
        'role_title': roleTitle,
        'organization': organization,
        'start_year': startYear,
        'end_year': endYear,
        'description': description,
        'sort_order': sortOrder,
      };

  static TutorExperience fromRow(Map<String, dynamic> row) => TutorExperience(
        id: row['id'] as String?,
        roleTitle: row['role_title'] as String?,
        organization: row['organization'] as String?,
        startYear: row['start_year'] as int?,
        endYear: row['end_year'] as int?,
        description: row['description'] as String?,
        sortOrder: (row['sort_order'] as int?) ?? 0,
      );

  @override
  List<Object?> get props =>
      [id, roleTitle, organization, startYear, endYear, description, sortOrder];
}

class TutorCertificate extends Equatable {
  const TutorCertificate({
    this.id,
    this.title,
    this.issuer,
    this.yearAwarded,
    this.filePath,
    this.sortOrder = 0,
  });

  final String? id;
  final String? title;
  final String? issuer;
  final int? yearAwarded;
  final String? filePath;
  final int sortOrder;

  TutorCertificate copyWith({
    String? title,
    String? issuer,
    int? yearAwarded,
    String? filePath,
    int? sortOrder,
  }) {
    return TutorCertificate(
      id: id,
      title: title ?? this.title,
      issuer: issuer ?? this.issuer,
      yearAwarded: yearAwarded ?? this.yearAwarded,
      filePath: filePath ?? this.filePath,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toRow(String tutorId) => {
        'tutor_id': tutorId,
        'title': title,
        'issuer': issuer,
        'year_awarded': yearAwarded,
        'file_path': filePath,
        'sort_order': sortOrder,
      };

  static TutorCertificate fromRow(Map<String, dynamic> row) => TutorCertificate(
        id: row['id'] as String?,
        title: row['title'] as String?,
        issuer: row['issuer'] as String?,
        yearAwarded: row['year_awarded'] as int?,
        filePath: row['file_path'] as String?,
        sortOrder: (row['sort_order'] as int?) ?? 0,
      );

  @override
  List<Object?> get props => [id, title, issuer, yearAwarded, filePath, sortOrder];
}
