import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(ThemeMode.system);

  final SharedPreferences _prefs;

  Future<void> load() async {
    final String? stored = _prefs.getString(AppConstants.prefsThemeModeKey);
    emit(_parse(stored));
  }

  Future<void> set(ThemeMode mode) async {
    await _prefs.setString(AppConstants.prefsThemeModeKey, mode.name);
    emit(mode);
  }

  ThemeMode _parse(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
