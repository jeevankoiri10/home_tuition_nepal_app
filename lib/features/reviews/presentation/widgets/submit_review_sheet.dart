import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/phone_ban_regex.dart';
import '../../../../core/widgets/phone_ban_warning.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    if (PhoneBanRegex.isViolation(_text.text)) {
      setState(() => _error = l10n.reviewPhoneRejected);
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
        SnackBar(content: Text(l10n.reviewThanks)),
      );
    } on ReviewsException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.isGateNotMet
            ? l10n.reviewGateNotMet
            : (e.isPhoneInReview
                ? l10n.reviewPhoneRejected
                : (e.message ?? l10n.reviewFailedGeneric));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            Text(l10n.reviewRateTitle(widget.tutorMaskedName),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            StarRatingInput(
              value: _stars,
              onChanged: (v) => setState(() => _stars = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            PhoneBanWarning(
              message: l10n.reviewPhoneBanWarning,
            ),
            TextField(
              controller: _text,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.reviewTextLabel,
                hintText: l10n.reviewTextHint,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_error!,
                  style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w500)),
            ],
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: _busy ? l10n.reviewSending : l10n.reviewSubmit,
              busy: _busy,
              onPressed: _busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
