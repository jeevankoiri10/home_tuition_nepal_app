import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/theme_cubit.dart';
import '../../l10n/generated/app_localizations.dart';

/// Segmented control for the app theme (System / Light / Dark). Reads and writes
/// [ThemeCubit], so the choice is persisted and applied app-wide. Reusable
/// anywhere a theme switch belongs (settings, onboarding, …).
class ThemeModeToggle extends StatelessWidget {
  const ThemeModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        return SegmentedButton<ThemeMode>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: ThemeMode.system, label: Text(l10n.themeSystem)),
            ButtonSegment(value: ThemeMode.light, label: Text(l10n.themeLight)),
            ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDark)),
          ],
          selected: {mode},
          onSelectionChanged: (selection) =>
              context.read<ThemeCubit>().set(selection.first),
        );
      },
    );
  }
}
