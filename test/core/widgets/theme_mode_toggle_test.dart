import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/blocs/theme_cubit.dart';
import 'package:home_tuition_nepal_app/core/widgets/theme_mode_toggle.dart';
import 'package:home_tuition_nepal_app/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ThemeCubit> _cubit() async {
  SharedPreferences.setMockInitialValues({});
  return ThemeCubit(await SharedPreferences.getInstance());
}

Widget _host(ThemeCubit cubit) => BlocProvider.value(
      value: cubit,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ThemeModeToggle()),
      ),
    );

void main() {
  testWidgets('selecting Dark updates the ThemeCubit', (tester) async {
    final cubit = await _cubit();
    await tester.pumpWidget(_host(cubit));
    await tester.pumpAndSettle();

    expect(cubit.state, ThemeMode.system);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(cubit.state, ThemeMode.dark);
  });
}
