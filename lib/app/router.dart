import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/models/user_role.dart';
import '../features/auth/presentation/blocs/auth_bloc.dart';
import '../features/auth/presentation/pages/email_verification_page.dart';
import '../features/auth/presentation/pages/blocked_screen.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/login_role_chooser_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/home/presentation/tutor_shell_page.dart';
import '../features/map/presentation/blocs/map_bloc.dart';
import '../features/map/presentation/pages/map_page.dart';
import '../features/splash/presentation/splash_page.dart';
import '../features/student_profile/presentation/cubit/student_onboarding_cubit.dart';
import '../features/student_profile/presentation/pages/student_onboarding_page.dart';
import '../features/student_requests/presentation/blocs/student_requests_bloc.dart';
import '../features/student_requests/presentation/pages/my_posts_page.dart';
import '../features/student_requests/presentation/pages/post_detail_page.dart';
import '../features/student_requests/presentation/pages/post_job_page.dart';
import '../features/student_requests/presentation/pages/request_tutor_page.dart';
import '../features/tutor_profile/presentation/blocs/tutor_profile_bloc.dart';
import '../features/tutor_profile/presentation/pages/tutor_onboarding_wizard_page.dart';
import '../features/tutor_profile/presentation/pages/tutor_profile_settings_page.dart';
import '../features/chat/presentation/blocs/chat_bloc.dart';
import '../features/chat/presentation/pages/chat_list_page.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/contracts/presentation/blocs/contract_bloc.dart';
import '../features/notifications/presentation/pages/notice_details_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/settings/presentation/pages/student_settings_page.dart';
import '../features/topups/presentation/pages/coin_packs_page.dart';
import '../features/vacancies/presentation/blocs/vacancies_bloc.dart';
import '../features/vacancies/presentation/pages/vacancies_feed_page.dart';
import '../features/vacancies/presentation/pages/vacancy_detail_page.dart';
import '../features/wallet/presentation/blocs/wallet_bloc.dart';
import '../features/wallet/presentation/pages/wallet_page.dart';
import 'di.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String loginRoleChooser = '/login/choose-role';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String tutorHome = '/tutor';
  static const String tutorOnboarding = '/tutor/onboarding';
  static const String studentOnboarding = '/student/onboarding';
  static const String blocked = '/blocked';
  static const String tutorProfileSettings = '/tutor/settings';
  static const String studentSettings = '/student/settings';
  static const String map = '/map';
  static const String wallet = '/wallet';
  static const String buyCoins = '/wallet/buy';
  static const String myPosts = '/posts';
  static const String postJob = '/posts/new-job';
  static const String requestTutor = '/posts/request-tutor';
  static const String postDetail = '/posts/:id';
  static const String vacancies = '/vacancies';
  static const String vacancyDetail = '/vacancies/:id';
  static const String notifications = '/notifications';
  static const String noticeDetail = '/notifications/:id';
  static const String chatList = '/chats';
  static const String chat = '/chat/:counterpartyId';

  static String routeForRole(UserRole role) {
    switch (role) {
      case UserRole.tutor:
        return tutorHome;
      case UserRole.student:
        return map;
    }
  }

  /// Where to land after a successful login, given the roles the account may
  /// act as. Two roles → the chooser; one → that role's home; none (shouldn't
  /// happen) → back to login. Pure so it can be unit-tested without a router.
  static String postLoginLocation(Set<UserRole> roles) {
    if (roles.length > 1) return loginRoleChooser;
    if (roles.isEmpty) return login;
    return routeForRole(roles.first);
  }
}

GoRouter buildRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    // Re-run [redirect] whenever auth state changes (sign-in, sign-out, and —
    // critically — when an onboarding RPC flips onboardingComplete).
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) => _guard(authBloc, state.matchedLocation),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashPage()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
      GoRoute(
        path: AppRoutes.blocked,
        builder: (_, _) => const BlockedScreen(),
      ),
      GoRoute(
        path: AppRoutes.loginRoleChooser,
        builder: (_, _) => const LoginRoleChooserPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, _) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (_, _) => const EmailVerificationPage(),
      ),
      GoRoute(
        path: AppRoutes.tutorHome,
        builder: (_, _) => const TutorShellPage(),
      ),
      GoRoute(
        path: AppRoutes.tutorOnboarding,
        builder: (_, _) => _withTutorProfile(const TutorOnboardingWizardPage()),
      ),
      GoRoute(
        path: AppRoutes.studentOnboarding,
        builder: (_, _) => BlocProvider<StudentOnboardingCubit>(
          create: (_) => sl<StudentOnboardingCubit>(),
          child: const StudentOnboardingPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.tutorProfileSettings,
        builder: (_, _) => _withTutorProfile(const TutorProfileSettingsPage()),
      ),
      GoRoute(
        path: AppRoutes.studentSettings,
        builder: (_, _) => const StudentSettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.map,
        builder: (_, _) => MultiBlocProvider(
          providers: [
            BlocProvider<MapBloc>(create: (_) => sl<MapBloc>()),
            BlocProvider<WalletBloc>(
              create: (ctx) {
                final user = ctx.read<AuthBloc>().state.user;
                final bloc = sl<WalletBloc>();
                if (user != null) bloc.add(WalletLoaded(user.id));
                return bloc;
              },
            ),
          ],
          child: const MapPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.wallet,
        builder: (_, _) => _withWallet(const WalletPage()),
      ),
      GoRoute(
        path: AppRoutes.buyCoins,
        builder: (_, _) => _withWallet(const CoinPacksPage()),
      ),
      GoRoute(
        path: AppRoutes.myPosts,
        builder: (_, _) => _withStudentRequests(const MyPostsPage()),
      ),
      GoRoute(
        path: AppRoutes.postJob,
        builder: (_, _) => _withStudentRequests(const PostJobPage()),
      ),
      GoRoute(
        path: AppRoutes.requestTutor,
        builder: (_, _) => _withStudentRequests(const RequestTutorPage()),
      ),
      GoRoute(
        path: AppRoutes.postDetail,
        builder: (_, st) => _withStudentRequests(
          PostDetailPage(jobId: st.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        path: AppRoutes.vacancies,
        builder: (_, _) => _withVacancies(const VacanciesFeedPage()),
      ),
      GoRoute(
        path: AppRoutes.vacancyDetail,
        builder: (_, st) => _withVacancies(
          VacancyDetailPage(vacancyId: st.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, _) => const NotificationsPage(),
      ),
      GoRoute(
        path: AppRoutes.noticeDetail,
        builder: (_, st) =>
            NoticeDetailsPage(notificationId: st.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.chatList,
        builder: (_, _) => const ChatListPage(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (_, st) => MultiBlocProvider(
          providers: [
            BlocProvider<ChatBloc>(create: (_) => sl<ChatBloc>()),
            BlocProvider<ContractBloc>(create: (_) => sl<ContractBloc>()),
          ],
          child: ChatPage(
            counterpartyId: st.pathParameters['counterpartyId'] ?? '',
            counterpartyMaskedName: st.uri.queryParameters['name'],
          ),
        ),
      ),
    ],
  );
}

/// Bridges a [Stream] to a [Listenable] so GoRouter re-evaluates `redirect`
/// whenever auth state changes. (go_router no longer exports its own version.)
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// The auth funnel: routes a signed-out (or mid-verification) user may sit on.
const Set<String> _authRoutes = {
  AppRoutes.splash,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.loginRoleChooser,
  AppRoutes.verifyEmail,
};

const Set<String> _onboardingRoutes = {
  AppRoutes.studentOnboarding,
  AppRoutes.tutorOnboarding,
};

/// Single source of truth for navigation gating:
///  • signed out → the auth funnel only;
///  • signed in but onboarding unfinished → locked onto that role's onboarding
///    route (which is also where a relaunch resumes);
///  • signed in and onboarded → kept out of the auth funnel + onboarding routes.
/// Returns the path to redirect to, or null to stay put.
String? _guard(AuthBloc authBloc, String location) {
  final auth = authBloc.state;

  // Cold start: status not resolved yet — let SplashPage do the first routing.
  if (auth.status == AuthStatus.unknown) return null;

  final user = auth.user;
  final loggedIn = auth.status == AuthStatus.authenticated && user != null;

  if (!loggedIn) {
    if (auth.status == AuthStatus.awaitingEmailVerification) {
      return location == AppRoutes.verifyEmail ? null : AppRoutes.verifyEmail;
    }
    return _authRoutes.contains(location) ? null : AppRoutes.login;
  }

  // Deactivated accounts are trapped on the non-dismissable blocked screen —
  // this takes precedence over onboarding and everything else.
  if (user.isBlocked) {
    return location == AppRoutes.blocked ? null : AppRoutes.blocked;
  }
  // Reactivated while sitting on the blocked screen — resume normal routing.
  if (location == AppRoutes.blocked) {
    return AppRoutes.routeForRole(user.activeRole);
  }

  // Signed in. Enforce the onboarding gate for the ACTIVE role before anything
  // else — switching into a role that hasn't been onboarded lands here.
  if (!user.activeRoleOnboarded) {
    final target = user.activeRole == UserRole.tutor
        ? AppRoutes.tutorOnboarding
        : AppRoutes.studentOnboarding;
    return location == target ? null : target;
  }

  // Onboarded — don't let them linger on the auth funnel or onboarding routes.
  if (_authRoutes.contains(location) || _onboardingRoutes.contains(location)) {
    return AppRoutes.routeForRole(user.activeRole);
  }
  return null;
}

BlocProvider<TutorProfileBloc> _withTutorProfile(Widget child) {
  return BlocProvider<TutorProfileBloc>(
    create: (ctx) {
      final user = ctx.read<AuthBloc>().state.user;
      final bloc = sl<TutorProfileBloc>();
      if (user != null) bloc.add(TutorProfileLoaded(user.id));
      return bloc;
    },
    child: child,
  );
}

BlocProvider<WalletBloc> _withWallet(Widget child) {
  return BlocProvider<WalletBloc>(
    create: (ctx) {
      final user = ctx.read<AuthBloc>().state.user;
      final bloc = sl<WalletBloc>();
      if (user != null) bloc.add(WalletLoaded(user.id));
      return bloc;
    },
    child: child,
  );
}

BlocProvider<StudentRequestsBloc> _withStudentRequests(Widget child) {
  return BlocProvider<StudentRequestsBloc>(
    create: (ctx) {
      final user = ctx.read<AuthBloc>().state.user;
      final bloc = sl<StudentRequestsBloc>();
      if (user != null && bloc.state.status == StudentRequestsStatus.initial) {
        bloc.add(StudentRequestsLoaded(user.id));
      }
      return bloc;
    },
    child: child,
  );
}

MultiBlocProvider _withVacancies(Widget child) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<VacanciesBloc>(
        create: (ctx) {
          final user = ctx.read<AuthBloc>().state.user;
          final bloc = sl<VacanciesBloc>();
          if (user != null && bloc.state.status == VacanciesStatus.initial) {
            bloc.add(VacanciesLoaded(user.id));
          }
          return bloc;
        },
      ),
      // Wallet bloc is also useful so the Apply sheet can refresh it after a
      // successful debit; provide a fresh instance if one isn't already in scope.
      BlocProvider<WalletBloc>(
        create: (ctx) {
          final user = ctx.read<AuthBloc>().state.user;
          final bloc = sl<WalletBloc>();
          if (user != null) bloc.add(WalletLoaded(user.id));
          return bloc;
        },
      ),
    ],
    child: child,
  );
}
