import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/locale_cubit.dart';
import '../constants/app_constants.dart';
import '../../l10n/generated/app_localizations.dart';

/// App bar action that toggles the app locale between English and Nepali.
///
/// Reads and writes [LocaleCubit] so the change is persisted and applied
/// app-wide. Use anywhere a quick language switch is appropriate
/// (login, settings, etc.).
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<LocaleCubit, Locale?>(
      builder: (context, locale) {
        final current =
            locale?.languageCode ?? Localizations.localeOf(context).languageCode;
        return PopupMenuButton<String>(
          tooltip: l10n.languageToggleTooltip,
          icon: const Icon(Icons.language),
          onSelected: (code) => context.read<LocaleCubit>().set(Locale(code)),
          itemBuilder: (_) => [
            _item(AppConstants.localeEn, l10n.languageEnglish, current),
            _item(AppConstants.localeNe, l10n.languageNepali, current),
          ],
        );
      },
    );
  }

  PopupMenuItem<String> _item(String code, String label, String current) {
    final selected = code == current;
    return PopupMenuItem<String>(
      value: code,
      child: Row(
        children: [
          Icon(selected ? Icons.check : null, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
