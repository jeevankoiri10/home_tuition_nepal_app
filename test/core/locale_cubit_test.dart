import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/blocs/locale_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs([Map<String, Object> seed = const {}]) async {
  SharedPreferences.setMockInitialValues(seed);
  return SharedPreferences.getInstance();
}

void main() {
  group('LocaleCubit', () {
    test('starts null (follow system) with no selection', () async {
      final cubit = LocaleCubit(await _prefs());
      expect(cubit.state, isNull);
      expect(cubit.hasUserSelection, isFalse);
    });

    test('load with no stored value stays null', () async {
      final cubit = LocaleCubit(await _prefs());
      await cubit.load();
      expect(cubit.state, isNull);
    });

    test('load reads a stored language code', () async {
      final cubit = LocaleCubit(await _prefs({'app.locale': 'ne'}));
      await cubit.load();
      expect(cubit.state, const Locale('ne'));
      expect(cubit.hasUserSelection, isTrue);
    });

    test('set emits and persists the locale', () async {
      final prefs = await _prefs();
      final cubit = LocaleCubit(prefs);
      await cubit.set(const Locale('en'));
      expect(cubit.state, const Locale('en'));
      expect(prefs.getString('app.locale'), 'en');
      expect(cubit.hasUserSelection, isTrue);
    });
  });
}
