import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/blocs/auth_bloc.dart';
import '../../chat/presentation/pages/chat_list_page.dart';
import '../../student_requests/presentation/blocs/student_requests_bloc.dart';
import '../../settings/presentation/pages/tutor_settings_page.dart';
import '../../tutor_profile/presentation/blocs/tutor_profile_bloc.dart';
import '../../vacancies/presentation/blocs/vacancies_bloc.dart';
import '../../vacancies/presentation/blocs/vacancy_map_bloc.dart';
import '../../vacancies/presentation/pages/vacancies_feed_page.dart';
import '../../vacancies/presentation/pages/vacancy_map_page.dart';
import '../../wallet/presentation/blocs/wallet_bloc.dart';

/// Bottom-nav shell shown after a tutor signs in. Hosts four tabs that map
/// directly to the spec: Home (vacancy map), Chats, Vacancies (list), Settings.
///
/// The four child pages each own their own bloc(s); we use [IndexedStack] so
/// switching tabs keeps the child state alive (scroll positions, fetched
/// data) the way native bottom-nav apps do.
class TutorShellPage extends StatefulWidget {
  const TutorShellPage({super.key});

  @override
  State<TutorShellPage> createState() => _TutorShellPageState();
}

class _TutorShellPageState extends State<TutorShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          // Home — the vacancy map (open vacancies plotted near the tutor).
          // WalletBloc backs the app-bar coin chip (realtime ledger).
          MultiBlocProvider(
            providers: [
              BlocProvider<VacancyMapBloc>(create: (_) => sl<VacancyMapBloc>()),
              BlocProvider<WalletBloc>(create: (ctx) {
                final user = ctx.read<AuthBloc>().state.user;
                final bloc = sl<WalletBloc>();
                if (user != null) bloc.add(WalletLoaded(user.id));
                return bloc;
              }),
            ],
            child: const VacancyMapPage(),
          ),
          const ChatListPage(),
          // Vacancies — feed page needs VacanciesBloc + a WalletBloc for the
          // Apply sheet's debit feedback.
          MultiBlocProvider(
            providers: [
              BlocProvider<VacanciesBloc>(create: (ctx) {
                final user = ctx.read<AuthBloc>().state.user;
                final bloc = sl<VacanciesBloc>();
                if (user != null &&
                    bloc.state.status == VacanciesStatus.initial) {
                  bloc.add(VacanciesLoaded(user.id));
                }
                return bloc;
              }),
              BlocProvider<WalletBloc>(create: (ctx) {
                final user = ctx.read<AuthBloc>().state.user;
                final bloc = sl<WalletBloc>();
                if (user != null) bloc.add(WalletLoaded(user.id));
                return bloc;
              }),
              BlocProvider<StudentRequestsBloc>(create: (ctx) {
                final user = ctx.read<AuthBloc>().state.user;
                final bloc = sl<StudentRequestsBloc>();
                if (user != null &&
                    bloc.state.status == StudentRequestsStatus.initial) {
                  bloc.add(StudentRequestsLoaded(user.id));
                }
                return bloc;
              }),
            ],
            child: const VacanciesFeedPage(),
          ),
          BlocProvider<TutorProfileBloc>(
            create: (ctx) {
              final user = ctx.read<AuthBloc>().state.user;
              final bloc = sl<TutorProfileBloc>();
              if (user != null) bloc.add(TutorProfileLoaded(user.id));
              return bloc;
            },
            child: const TutorSettingsPage(),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.tutorNavHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.forum_outlined),
            selectedIcon: const Icon(Icons.forum),
            label: l10n.tutorNavChats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: const Icon(Icons.assignment),
            label: l10n.tutorNavVacancies,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.tutorNavSettings,
          ),
        ],
      ),
    );
  }
}
