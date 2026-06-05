import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/app.dart';
import 'app/bloc_observer.dart';
import 'app/di.dart';
import 'core/config/env.dart';
import 'core/services/firebase_messaging_push_service.dart';

Future<void> main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Remote push needs Firebase up before the DI container builds the
      // FirebaseMessagingPushService. No-op (and no Firebase dependency at
      // runtime) until PUSH_NOTIFICATIONS_CONFIGURED is set — see
      // docs/push_setup.md.
      if (Env.pushNotificationsConfigured) {
        await Firebase.initializeApp();
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      }

      await setupDependencies();
      Bloc.observer = AppBlocObserver();

      FlutterError.onError = (details) async {
        FlutterError.presentError(details);
        if (Env.hasSentry) {
          await Sentry.captureException(
            details.exception,
            stackTrace: details.stack,
          );
        }
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        if (Env.hasSentry) {
          Sentry.captureException(error, stackTrace: stack);
        } else if (kDebugMode) {
          debugPrint('[Uncaught] $error\n$stack');
        }
        return true;
      };

      if (Env.hasSentry) {
        await SentryFlutter.init(
          (o) {
            o.dsn = Env.sentryDsn;
            o.environment = Env.sentryEnvironment;
            if (Env.sentryRelease.isNotEmpty) o.release = Env.sentryRelease;
            // Sensible defaults — re-tune per project after a week of data.
            o.tracesSampleRate = kReleaseMode ? 0.1 : 1.0;
            o.attachScreenshot = false;       // privacy: never attach to errors
            // ignore: experimental_member_use
            o.attachViewHierarchy = false;
            o.sendDefaultPii = false;
          },
          appRunner: () => runApp(const HomeTuitionNepalApp()),
        );
      } else {
        runApp(const HomeTuitionNepalApp());
      }
    },
    (error, stack) {
      if (Env.hasSentry) {
        Sentry.captureException(error, stackTrace: stack);
      } else if (kDebugMode) {
        debugPrint('[Zone error] $error\n$stack');
      }
    },
  );
}
