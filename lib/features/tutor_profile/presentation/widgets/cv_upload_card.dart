import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/tutor_profile.dart';
import '../../domain/tutor_repository.dart';
import '../blocs/tutor_profile_bloc.dart';

/// Picks a PDF, enforces the 300 KB cap before uploading, then pushes the
/// returned URL back into the draft profile so the rest of the wizard (and
/// the student-side viewer in [TutorMapCard]) can see it.
class CvUploadCard extends StatefulWidget {
  const CvUploadCard({super.key, required this.profile});

  final TutorProfile profile;

  @override
  State<CvUploadCard> createState() => _CvUploadCardState();
}

class _CvUploadCardState extends State<CvUploadCard> {
  bool _busy = false;

  Future<void> _pick() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.wizardCvReadFailed)));
      return;
    }
    if (bytes.lengthInBytes > AppConstants.tutorCvMaxBytes) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.wizardCvTooLarge)));
      return;
    }
    setState(() => _busy = true);
    try {
      final url = await sl<TutorRepository>().uploadCv(
        tutorId: widget.profile.tutorId,
        bytes: bytes,
        fileName: file.name,
      );
      if (!mounted) return;
      context.read<TutorProfileBloc>().add(
            TutorProfileDraftUpdated(widget.profile.copyWith(cvUrl: url)),
          );
      messenger.showSnackBar(SnackBar(content: Text(l10n.wizardCvUploaded)));
    } on TutorRepositoryException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _viewCv(String url) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(url);
    final ok = uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.tutorCardCvOpenFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final url = widget.profile.cvUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.wizardCvSizeHint,
          style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (url != null) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf_outlined),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(l10n.wizardCvCurrent, style: tt.bodyMedium),
                ),
                TextButton(
                  onPressed: () => _viewCv(url),
                  child: Text(l10n.tutorCardViewCv),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        FilledButton.icon(
          onPressed: _busy ? null : _pick,
          icon: _busy
              ? const SizedBox(
                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.upload_file_outlined),
          label: Text(url == null
              ? l10n.wizardCvUploadButton
              : l10n.wizardCvReplaceButton),
        ),
      ],
    );
  }
}
