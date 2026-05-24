import 'package:flutter/material.dart';

import '../../../../app/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/phone_ban_regex.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../reviews/domain/reviews_repository.dart';

/// Prompted right after a contract is completed so the student can rate the
/// tutor. Reuses the existing [ReviewsRepository]; the contract-completion
/// gate is already satisfied because the parties have an unlocked thread.
class ReviewSheet extends StatefulWidget {
  const ReviewSheet({super.key, required this.tutorId, required this.tutorName});

  final String tutorId;
  final String tutorName;

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  int _stars = 5;
  final _text = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final body = _text.text.trim();
    if (body.isNotEmpty && PhoneBanRegex.isViolation(body)) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.phoneInTextValidation)));
      return;
    }
    setState(() => _busy = true);
    try {
      await sl<ReviewsRepository>().submit(
        tutorId: widget.tutorId,
        stars: _stars,
        text: body.isEmpty ? null : body,
      );
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.reviewThanks)));
      Navigator.of(context).pop(true);
    } on ReviewsException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.reviewTitle(widget.tutorName),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 5; i++)
                  IconButton(
                    onPressed: () => setState(() => _stars = i),
                    icon: Icon(
                      i <= _stars ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFB300),
                      size: 36,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _text,
              maxLines: 3,
              decoration: InputDecoration(hintText: l10n.reviewHint),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: l10n.reviewSubmit,
              busy: _busy,
              onPressed: _busy ? null : _submit,
            ),
            TextButton(
              onPressed: _busy ? null : () => Navigator.of(context).pop(false),
              child: Text(l10n.reviewSkip,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
