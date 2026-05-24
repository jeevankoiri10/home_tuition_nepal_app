import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/phone_ban_regex.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/phone_ban_warning.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/contract.dart';

/// Result returned to the caller when the user submits the propose form.
class ProposeContractResult {
  ProposeContractResult({
    required this.subject,
    required this.rateNpr,
    required this.ratePeriod,
    required this.scheduleText,
  });

  final String subject;
  final num? rateNpr;
  final ContractRatePeriod ratePeriod;
  final String? scheduleText;
}

/// Bottom sheet to propose a contract from chat. Returns a
/// [ProposeContractResult] via Navigator.pop, or null if cancelled.
class ProposeContractSheet extends StatefulWidget {
  const ProposeContractSheet({super.key});

  @override
  State<ProposeContractSheet> createState() => _ProposeContractSheetState();
}

class _ProposeContractSheetState extends State<ProposeContractSheet> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _rate = TextEditingController();
  final _schedule = TextEditingController();
  ContractRatePeriod _period = ContractRatePeriod.month;

  @override
  void dispose() {
    _subject.dispose();
    _rate.dispose();
    _schedule.dispose();
    super.dispose();
  }

  String? _noPhone(AppLocalizations l10n, String? v) {
    if (v == null) return null;
    return PhoneBanRegex.isViolation(v) ? l10n.phoneInTextValidation : null;
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_subject.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.contractSubjectRequired)),
      );
      return;
    }
    Navigator.of(context).pop(
      ProposeContractResult(
        subject: _subject.text.trim(),
        rateNpr: num.tryParse(_rate.text.trim()),
        ratePeriod: _period,
        scheduleText: _schedule.text.trim().isEmpty ? null : _schedule.text.trim(),
      ),
    );
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.contractProposeTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.contractProposeSubtitle,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l10n.contractSubjectLabel,
                controller: _subject,
                validator: (v) => _noPhone(l10n, v),
              ),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: l10n.contractRateLabel,
                      controller: _rate,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: DropdownButtonFormField<ContractRatePeriod>(
                      initialValue: _period,
                      decoration: InputDecoration(labelText: l10n.contractPeriodLabel),
                      items: [
                        for (final p in ContractRatePeriod.values)
                          DropdownMenuItem(value: p, child: Text(p.value)),
                      ],
                      onChanged: (v) => setState(() => _period = v ?? _period),
                    ),
                  ),
                ],
              ),
              AppTextField(
                label: l10n.contractScheduleLabel,
                controller: _schedule,
                validator: (v) => _noPhone(l10n, v),
              ),
              const SizedBox(height: AppSpacing.sm),
              PhoneBanWarning(message: l10n.phoneBanFormHint),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(label: l10n.contractProposeSubmit, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
