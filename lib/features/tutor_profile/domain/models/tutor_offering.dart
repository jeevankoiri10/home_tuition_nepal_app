import 'package:equatable/equatable.dart';

import 'profile_enums.dart';

/// One row of the "Subjects Offered" table: per (level, subject) the tutor
/// quotes a price or a price range with a period.
class TutorOffering extends Equatable {
  const TutorOffering({
    this.id,
    required this.level,
    required this.subject,
    required this.priceMinNpr,
    this.priceMaxNpr,
    this.period = PricePeriod.month,
  });

  final String? id;
  final StudentLevel level;
  final String subject;
  final num priceMinNpr;
  final num? priceMaxNpr;
  final PricePeriod period;

  /// Human-friendly price string for cards: "रू 8,000/month" or "रू 4,000–5,000/day".
  String formatPrice() {
    final min = _formatNpr(priceMinNpr);
    if (priceMaxNpr != null && priceMaxNpr != priceMinNpr) {
      return 'रू $min–${_formatNpr(priceMaxNpr!)}${period.suffix}';
    }
    return 'रू $min${period.suffix}';
  }

  TutorOffering copyWith({
    StudentLevel? level,
    String? subject,
    num? priceMinNpr,
    num? priceMaxNpr,
    PricePeriod? period,
  }) {
    return TutorOffering(
      id: id,
      level: level ?? this.level,
      subject: subject ?? this.subject,
      priceMinNpr: priceMinNpr ?? this.priceMinNpr,
      priceMaxNpr: priceMaxNpr ?? this.priceMaxNpr,
      period: period ?? this.period,
    );
  }

  Map<String, dynamic> toRow(String tutorId) => {
        'tutor_id': tutorId,
        'level': level.value,
        'subject': subject,
        'price_min_npr': priceMinNpr,
        'price_max_npr': priceMaxNpr,
        'price_period': period.value,
      };

  static TutorOffering fromRow(Map<String, dynamic> row) => TutorOffering(
        id: row['id'] as String?,
        level: StudentLevel.fromValue(row['level'] as String),
        subject: row['subject'] as String,
        priceMinNpr: row['price_min_npr'] as num,
        priceMaxNpr: row['price_max_npr'] as num?,
        period: PricePeriod.fromString(row['price_period'] as String?),
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
  List<Object?> get props => [id, level, subject, priceMinNpr, priceMaxNpr, period];
}
