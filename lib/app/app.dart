import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/blocs/locale_cubit.dart';
import '../core/blocs/theme_cubit.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
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
  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>(create: (_) => sl<LocaleCubit>()..load()),
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()..load()),
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<NotificationsBloc>(create: (_) => sl<NotificationsBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (a, b) =>
            a.status != AuthStatus.authenticated && b.status == AuthStatus.authenticated,
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
      ),
    );
  }
}
