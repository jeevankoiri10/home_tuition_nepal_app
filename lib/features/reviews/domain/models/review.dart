import 'package:equatable/equatable.dart';

class Review extends Equatable {
  const Review({
    required this.id,
    required this.tutorId,
    required this.studentId,
    required this.stars,
    this.text,
    required this.createdAt,
  });

  final String id;
  final String tutorId;
  final String studentId;
  final int stars;
  final String? text;
  final DateTime createdAt;

  static Review fromRow(Map<String, dynamic> row) => Review(
        id: row['id'] as String,
        tutorId: row['tutor_id'] as String,
        studentId: row['student_id'] as String,
        stars: (row['stars'] as num).toInt(),
        text: row['text'] as String?,
        createdAt: row['created_at'] == null
            ? DateTime.now()
            : DateTime.parse(row['created_at'] as String),
      );

  @override
  List<Object?> get props => [id, tutorId, studentId, stars, text, createdAt];
}

class TutorRatingSummary extends Equatable {
  const TutorRatingSummary({required this.average, required this.count});
  final double average;
  final int count;

  @override
  List<Object?> get props => [average, count];
}
