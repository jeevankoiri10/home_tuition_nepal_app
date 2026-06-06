import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../app/di.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/coin_pack.dart';
import '../../domain/models/top_up.dart';
import '../../domain/top_ups_repository.dart';

/// Renders the eSewa QR pointing at the platform-owner account, takes a
/// receipt upload from the user once they've paid, then returns the
/// finalized `TopUp` to the caller. The caller (CoinPacksPage) shows the
/// "we'll credit your wallet once an admin verifies" confirmation.
class EsewaPaymentSheet extends StatefulWidget {
  const EsewaPaymentSheet({super.key, required this.pack});

  final CoinPack pack;

  @override
  State<EsewaPaymentSheet> createState() => _EsewaPaymentSheetState();
}

class _EsewaPaymentSheetState extends State<EsewaPaymentSheet> {
  TopUp? _topUp;
  bool _starting = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() => _starting = true);
    try {
      final t = await sl<TopUpsRepository>()
          .startTopUp(pack: widget.pack, provider: PaymentProvider.esewa);
      if (!mounted) return;
      setState(() => _topUp = t);
    } on TopUpsException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? l10n.topUpFailedGeneric)),
      );
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _pickReceipt() async {
    final topUp = _topUp;
    if (topUp == null) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.esewaReceiptReadFailed)));
      return;
    }
    if (bytes.lengthInBytes > AppConstants.topUpReceiptMaxBytes) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.esewaReceiptTooLarge)));
      return;
    }
    setState(() => _uploading = true);
    try {
      final updated = await sl<TopUpsRepository>().attachReceipt(
        topUpId: topUp.id,
        bytes: bytes,
        fileName: file.name,
      );
      if (!mounted) return;
      setState(() => _topUp = updated);
      messenger.showSnackBar(SnackBar(content: Text(l10n.esewaReceiptUploaded)));
    } on TopUpsException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final topUp = _topUp;
    final hasReceipt = topUp?.receiptUrl != null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.esewaSheetTitle, style: tt.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.esewaSheetSubtitle(widget.pack.formatPrice()),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Image.asset(
                  AppConstants.esewaQrAsset,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  // Until the owner's QR image is added at esewaQrAsset, fall
                  // back to a placeholder instead of throwing. The payee number
                  // shown below still lets users pay manually.
                  errorBuilder: (_, _, _) => const SizedBox(
                    width: 200,
                    height: 200,
                    child: Icon(Icons.qr_code_2,
                        size: 120, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _PayeeLine(
              label: l10n.esewaPayeeNameLabel,
              value: AppConstants.esewaPayeeName,
            ),
            const SizedBox(height: AppSpacing.xs),
            _PayeeLine(
              label: l10n.esewaPayeeNumberLabel,
              value: AppConstants.esewaPayeeNumber,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_starting)
              const Center(child: CircularProgressIndicator())
            else if (topUp == null)
              const SizedBox.shrink()
            else ...[
              if (hasReceipt)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.3),
                    borderRadius: AppRadii.cardBorder,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(l10n.esewaReceiptOnFile)),
                    ],
                  ),
                ),
              if (hasReceipt) const SizedBox(height: AppSpacing.sm),
              FilledButton.icon(
                onPressed: _uploading ? null : _pickReceipt,
                icon: _uploading
                    ? const SizedBox(
                        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.receipt_long_outlined),
                label: Text(hasReceipt
                    ? l10n.esewaReplaceReceipt
                    : l10n.esewaUploadReceipt),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed:
                    hasReceipt ? () => Navigator.of(context).pop(topUp) : null,
                child: Text(l10n.esewaDoneLabel),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.esewaAdminReviewHint,
                style:
                    tt.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PayeeLine extends StatelessWidget {
  const _PayeeLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(label,
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
