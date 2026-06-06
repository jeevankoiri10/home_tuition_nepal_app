import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/blocs/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs([Map<String, Object> seed = const {}]) async {
  SharedPreferences.setMockInitialValues(seed);
  return SharedPreferences.getInstance();
}

void main() {
  group('ThemeCubit', () {
    test('defaults to system before load', () async {
      final cubit = ThemeCubit(await _prefs());
      expect(cubit.state, ThemeMode.system);
    });

    test('load with no stored value stays on system', () async {
      final cubit = ThemeCubit(await _prefs());
      await cubit.load();
      expect(cubit.state, ThemeMode.system);
    });

    test('load parses a stored dark value', () async {
      final cubit = ThemeCubit(await _prefs({'app.themeMode': 'dark'}));
      await cubit.load();
      expect(cubit.state, ThemeMode.dark);
    });

    test('load falls back to system on an unknown value', () async {
      final cubit = ThemeCubit(await _prefs({'app.themeMode': 'sepia'}));
      await cubit.load();
      expect(cubit.state, ThemeMode.system);
    });

    test('set emits and persists the chosen mode', () async {
      final prefs = await _prefs();
      final cubit = ThemeCubit(prefs);
      await cubit.set(ThemeMode.light);
      expect(cubit.state, ThemeMode.light);
      expect(prefs.getString('app.themeMode'), 'light');
    });
  });
}
