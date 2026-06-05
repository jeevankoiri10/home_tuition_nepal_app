import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/blocs/locale_cubit.dart';
import '../core/blocs/theme_cubit.dart';
import '../core/constants/app_constants.dart';
import '../core/services/push_notification_coordinator.dart';
import '../core/services/push_notification_service.dart';
import '../core/services/presence_service.dart';
import '../core/services/usage/usage_repository.dart';
import '../core/services/usage_tracker.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/blocs/auth_bloc.dart';
import '../features/notifications/presentation/blocs/notifications_bloc.dart';
import '../l10n/generated/app_localizations.dart';
import 'di.dart';
import 'router.dart';

class HomeTuitionNepalApp extends StatefulWidget {
  const HomeTuitionNepalApp({super.key});

  @override
  State<HomeTuitionNepalApp> createState() => _HomeTuitionNepalAppState();
}

class _HomeTuitionNepalAppState extends State<HomeTuitionNepalApp> {
  late final _router = buildRouter(sl<AuthBloc>());
  PushNotificationCoordinator? _pushCoordinator;
  UsageTracker? _usageTracker;
  bool _presenceStarted = false;

  @override
  void dispose() {
    _pushCoordinator?.dispose();
    _usageTracker?.dispose();
    sl<PresenceService>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>(create: (_) => sl<LocaleCubit>()..load()),
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()..load()),
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<NotificationsBloc>(create: (_) => sl<NotificationsBloc>()),
      ],
      child: Builder(
        builder: (ctx) {
          // Start the push coordinator once the auth bloc is reachable via
          // context. It self-cancels when this state is disposed.
          final authBloc = ctx.read<AuthBloc>();
          _pushCoordinator ??= PushNotificationCoordinator(
            push: sl<PushNotificationService>(),
            auth: sl<AuthRepository>(),
            authStates: authBloc.stream,
            currentAuthState: () => authBloc.state,
            navigate: _router.push,
          )..start();
          // Active-usage telemetry (time spent per role). Self-cancels on
          // dispose; no-op when Supabase isn't configured.
          _usageTracker ??= UsageTracker(
            repository: sl<UsageRepository>(),
            authStates: authBloc.stream,
            currentAuthState: () => authBloc.state,
          )..start();
          // Live online/offline presence + last-seen heartbeat. Singleton so
          // widgets (map pins, chat) can read its `online` set via get_it.
          if (!_presenceStarted) {
            _presenceStarted = true;
            sl<PresenceService>().start();
          }
          return BlocListener<AuthBloc, AuthState>(
            listenWhen: (a, b) =>
                a.status != AuthStatus.authenticated &&
                b.status == AuthStatus.authenticated,
            listener: (ctx, state) {
              final user = state.user;
              if (user == null) return;
              ctx.read<NotificationsBloc>().add(NotificationsLoaded(user.id));
            },
            child: BlocBuilder<LocaleCubit, Locale?>(
              builder: (context, locale) {
                return BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeMode) {
                    return MaterialApp.router(
                      title: AppConstants.appName,
                      debugShowCheckedModeBanner: false,
                      theme: AppTheme.light(),
                      darkTheme: AppTheme.dark(),
                      themeMode: themeMode,
                      locale: locale,
                      supportedLocales: const [Locale('en'), Locale('ne')],
                      localizationsDelegates: const [
                        AppLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      routerConfig: _router,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
