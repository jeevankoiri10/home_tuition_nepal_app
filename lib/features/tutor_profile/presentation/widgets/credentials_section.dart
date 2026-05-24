import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/tutor_credentials.dart';

class EducationEditor extends StatelessWidget {
  const EducationEditor({super.key, required this.items, required this.onChanged});

  final List<TutorEducation> items;
  final ValueChanged<List<TutorEducation>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _CredentialList<TutorEducation>(
      items: items,
      emptyMessage: l10n.educationEmpty,
      addLabel: l10n.addEducation,
      onChanged: onChanged,
      buildAdd: (i) => TutorEducation(sortOrder: i),
      rowBuilder: (e, onEdit, onRemove) => _EducationRow(item: e, onChanged: onEdit, onRemove: onRemove),
    );
  }
}

class ExperienceEditor extends StatelessWidget {
  const ExperienceEditor({super.key, required this.items, required this.onChanged});

  final List<TutorExperience> items;
  final ValueChanged<List<TutorExperience>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _CredentialList<TutorExperience>(
      items: items,
      emptyMessage: l10n.experienceEmpty,
      addLabel: l10n.addExperience,
      onChanged: onChanged,
      buildAdd: (i) => TutorExperience(sortOrder: i),
      rowBuilder: (e, onEdit, onRemove) =>
          _ExperienceRow(item: e, onChanged: onEdit, onRemove: onRemove),
    );
  }
}

class CertificatesEditor extends StatelessWidget {
  const CertificatesEditor({super.key, required this.items, required this.onChanged});

  final List<TutorCertificate> items;
  final ValueChanged<List<TutorCertificate>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _CredentialList<TutorCertificate>(
      items: items,
      emptyMessage: l10n.certificatesEmpty,
      addLabel: l10n.addCertificate,
      onChanged: onChanged,
      buildAdd: (i) => TutorCertificate(sortOrder: i),
      rowBuilder: (e, onEdit, onRemove) =>
          _CertificateRow(item: e, onChanged: onEdit, onRemove: onRemove),
    );
  }
}

// ─── Generic list shell ───────────────────────────────────────────────────────

class _CredentialList<T> extends StatelessWidget {
  const _CredentialList({
    required this.items,
    required this.emptyMessage,
    required this.addLabel,
    required this.onChanged,
    required this.buildAdd,
    required this.rowBuilder,
  });

  final List<T> items;
  final String emptyMessage;
  final String addLabel;
  final ValueChanged<List<T>> onChanged;
  final T Function(int sortOrder) buildAdd;
  final Widget Function(T item, ValueChanged<T> onEdit, VoidCallback onRemove) rowBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(emptyMessage,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
        for (int i = 0; i < items.length; i++)
          rowBuilder(items[i], (next) {
            final list = List<T>.from(items);
            list[i] = next;
            onChanged(list);
          }, () {
            final list = List<T>.from(items)..removeAt(i);
            onChanged(list);
          }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: Text(addLabel),
            onPressed: () => onChanged([...items, buildAdd(items.length)]),
          ),
        ),
      ],
    );
  }
}

// ─── Row widgets ──────────────────────────────────────────────────────────────

class _EducationRow extends StatefulWidget {
  const _EducationRow({required this.item, required this.onChanged, required this.onRemove});
  final TutorEducation item;
  final ValueChanged<TutorEducation> onChanged;
  final VoidCallback onRemove;

  @override
  State<_EducationRow> createState() => _EducationRowState();
}

class _EducationRowState extends State<_EducationRow> {
  late final _degree = TextEditingController(text: widget.item.degree ?? '');
  late final _institution = TextEditingController(text: widget.item.institution ?? '');
  late final _field = TextEditingController(text: widget.item.fieldOfStudy ?? '');
  late final _start = TextEditingController(text: widget.item.startYear?.toString() ?? '');
  late final _end = TextEditingController(text: widget.item.endYear?.toString() ?? '');

  @override
  void dispose() {
    _degree.dispose();
    _institution.dispose();
    _field.dispose();
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(widget.item.copyWith(
      degree: _degree.text.trim(),
      institution: _institution.text.trim(),
      fieldOfStudy: _field.text.trim(),
      startYear: int.tryParse(_start.text.trim()),
      endYear: int.tryParse(_end.text.trim()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _RowShell(
      onRemove: widget.onRemove,
      children: [
        TextField(controller: _degree, decoration: InputDecoration(labelText: l10n.degreeLabel), onChanged: (_) => _emit()),
        TextField(controller: _institution, decoration: InputDecoration(labelText: l10n.institutionLabel), onChanged: (_) => _emit()),
        TextField(controller: _field, decoration: InputDecoration(labelText: l10n.fieldOfStudyLabel), onChanged: (_) => _emit()),
        Row(children: [
          Expanded(child: TextField(controller: _start, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.startYearLabel), onChanged: (_) => _emit())),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: TextField(controller: _end, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.endYearLabel), onChanged: (_) => _emit())),
        ]),
      ],
    );
  }
}

class _ExperienceRow extends StatefulWidget {
  const _ExperienceRow({required this.item, required this.onChanged, required this.onRemove});
  final TutorExperience item;
  final ValueChanged<TutorExperience> onChanged;
  final VoidCallback onRemove;

  @override
  State<_ExperienceRow> createState() => _ExperienceRowState();
}

class _ExperienceRowState extends State<_ExperienceRow> {
  late final _role = TextEditingController(text: widget.item.roleTitle ?? '');
  late final _org = TextEditingController(text: widget.item.organization ?? '');
  late final _start = TextEditingController(text: widget.item.startYear?.toString() ?? '');
  late final _end = TextEditingController(text: widget.item.endYear?.toString() ?? '');

  @override
  void dispose() {
    _role.dispose();
    _org.dispose();
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(widget.item.copyWith(
      roleTitle: _role.text.trim(),
      organization: _org.text.trim(),
      startYear: int.tryParse(_start.text.trim()),
      endYear: int.tryParse(_end.text.trim()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _RowShell(
      onRemove: widget.onRemove,
      children: [
        TextField(controller: _role, decoration: InputDecoration(labelText: l10n.roleTitleLabel), onChanged: (_) => _emit()),
        TextField(controller: _org, decoration: InputDecoration(labelText: l10n.organizationLabel), onChanged: (_) => _emit()),
        Row(children: [
          Expanded(child: TextField(controller: _start, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.startYearLabel), onChanged: (_) => _emit())),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: TextField(controller: _end, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.endYearLabel), onChanged: (_) => _emit())),
        ]),
      ],
    );
  }
}

class _CertificateRow extends StatefulWidget {
  const _CertificateRow({required this.item, required this.onChanged, required this.onRemove});
  final TutorCertificate item;
  final ValueChanged<TutorCertificate> onChanged;
  final VoidCallback onRemove;

  @override
  State<_CertificateRow> createState() => _CertificateRowState();
}

class _CertificateRowState extends State<_CertificateRow> {
  late final _title = TextEditingController(text: widget.item.title ?? '');
  late final _issuer = TextEditingController(text: widget.item.issuer ?? '');
  late final _year = TextEditingController(text: widget.item.yearAwarded?.toString() ?? '');

  @override
  void dispose() {
    _title.dispose();
    _issuer.dispose();
    _year.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(widget.item.copyWith(
      title: _title.text.trim(),
      issuer: _issuer.text.trim(),
      yearAwarded: int.tryParse(_year.text.trim()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _RowShell(
      onRemove: widget.onRemove,
      children: [
        TextField(controller: _title, decoration: InputDecoration(labelText: l10n.certificateTitleLabel), onChanged: (_) => _emit()),
        TextField(controller: _issuer, decoration: InputDecoration(labelText: l10n.issuerLabel), onChanged: (_) => _emit()),
        TextField(controller: _year, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.yearAwardedLabel), onChanged: (_) => _emit()),
        // File upload — wired in Phase 3 to a private Supabase Storage bucket; UI stub for now.
        OutlinedButton.icon(
          icon: const Icon(Icons.attach_file),
          label: Text(l10n.attachCertificateLabel),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.attachCertificateNotReady)),
            );
          },
        ),
      ],
    );
  }
}

class _RowShell extends StatelessWidget {
  const _RowShell({required this.children, required this.onRemove});
  final List<Widget> children;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...children
              .expand((w) => [w, const SizedBox(height: AppSpacing.sm)])
              .toList()
            ..removeLast(),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
              label: Text(AppLocalizations.of(context).removeAction),
            ),
          ),
        ],
      ),
    );
  }
}
