import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../core/config/env.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('[BLoC error] ${bloc.runtimeType}: $error');
    }
    if (Env.hasSentry) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({'bloc': bloc.runtimeType.toString()}),
      );
    }
    super.onError(bloc, error, stackTrace);
  }
}
