import 'package:flutter/material.dart';

import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

/// Persistent orange-tinted warning shown above every free-text input in the
/// app (job descriptions, bid cover notes, About sections, reviews, chat).
///
/// Enforces docs/plan.md §5.6 — *"Do not include phone numbers, WhatsApp
/// links, email addresses, or external contact details in this field."*
class PhoneBanWarning extends StatelessWidget {
  const PhoneBanWarning({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: AppRadii.inputBorder,
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFED6C02), size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFED6C02), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
