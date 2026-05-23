import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/phone_ban_regex.dart';
import '../../../../core/widgets/phone_ban_warning.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/reviews_repository.dart';
import 'star_rating_input.dart';

class SubmitReviewSheet extends StatefulWidget {
  const SubmitReviewSheet({
    super.key,
    required this.tutorId,
    required this.tutorMaskedName,
    required this.reviews,
  });

  final String tutorId;
  final String tutorMaskedName;
  final ReviewsRepository reviews;

  @override
  State<SubmitReviewSheet> createState() => _SubmitReviewSheetState();
}

class _SubmitReviewSheetState extends State<SubmitReviewSheet> {
  int _stars = 5;
  final _text = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (PhoneBanRegex.isViolation(_text.text)) {
      setState(() => _error = 'Remove phone numbers or contact details from your review.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.reviews.submit(
        tutorId: widget.tutorId,
        stars: _stars,
        text: _text.text.trim().isEmpty ? null : _text.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanks for your review!')),
      );
    } on ReviewsException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.isGateNotMet
            ? 'You need to unlock this tutor first.'
            : (e.isPhoneInReview
                ? 'Phone numbers and contact details are not allowed.'
                : (e.message ?? 'Could not submit review.'));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Rate ${widget.tutorMaskedName}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            StarRatingInput(
              value: _stars,
              onChanged: (v) => setState(() => _stars = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            const PhoneBanWarning(
              message:
                  'Do not include phone numbers or contact details in your review.',
            ),
            TextField(
              controller: _text,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Tell other students about this tutor',
                hintText: 'Optional. Stay specific and respectful.',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_error!,
                  style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w500)),
            ],
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: _busy ? 'Sending…' : 'Submit review',
              busy: _busy,
              onPressed: _busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
