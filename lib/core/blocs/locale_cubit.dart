import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit(this._prefs) : super(null);

  final SharedPreferences _prefs;

  Future<void> load() async {
    final String? stored = _prefs.getString(AppConstants.prefsLocaleKey);
    if (stored == null) {
      emit(null);
      return;
    }
    emit(Locale(stored));
  }

  Future<void> set(Locale locale) async {
    await _prefs.setString(AppConstants.prefsLocaleKey, locale.languageCode);
    emit(locale);
  }

  bool get hasUserSelection => state != null;
}
