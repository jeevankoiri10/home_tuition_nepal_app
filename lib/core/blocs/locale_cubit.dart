import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit(this._prefs, {this.onLanguageChanged}) : super(null);

  final SharedPreferences _prefs;

  /// Called with the language code whenever the user picks a language, so the
  /// choice can be mirrored server-side (e.g. to localize admin broadcasts).
  /// Optional so the cubit stays usable in tests without a backend.
  final Future<void> Function(String languageCode)? onLanguageChanged;

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
    await onLanguageChanged?.call(locale.languageCode);
  }

  bool get hasUserSelection => state != null;
}
