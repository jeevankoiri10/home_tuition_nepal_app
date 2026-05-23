import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/models/user_role.dart';
import '../features/auth/presentation/blocs/auth_bloc.dart';
import '../features/auth/presentation/pages/email_verification_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/home/presentation/student_home_page.dart';
import '../features/home/presentation/tutor_home_page.dart';
import '../features/map/presentation/blocs/map_bloc.dart';
import '../features/map/presentation/pages/map_page.dart';
import '../features/splash/presentation/splash_page.dart';
import '../features/student_requests/presentation/blocs/student_requests_bloc.dart';
import '../features/student_requests/presentation/pages/my_posts_page.dart';
import '../features/student_requests/presentation/pages/post_detail_page.dart';
import '../features/student_requests/presentation/pages/post_job_page.dart';
import '../features/student_requests/presentation/pages/request_tutor_page.dart';
import '../features/tutor_profile/presentation/blocs/tutor_profile_bloc.dart';
import '../features/tutor_profile/presentation/pages/tutor_onboarding_wizard_page.dart';
import '../features/tutor_profile/presentation/pages/tutor_profile_settings_page.dart';
import '../features/chat/presentation/blocs/chat_bloc.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
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
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String tutorHome = '/tutor';
  static const String tutorOnboarding = '/tutor/onboarding';
  static const String tutorProfileSettings = '/tutor/settings';
  static const String studentHome = '/student';
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
  static const String chat = '/chat/:counterpartyId';

  static String routeForRole(UserRole role) {
    switch (role) {
      case UserRole.tutor:
        return tutorHome;
      case UserRole.student:
        return map;
    }
  }
}

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashPage()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: AppRoutes.register, builder: (_, _) => const RegisterPage()),
      GoRoute(path: AppRoutes.verifyEmail, builder: (_, _) => const EmailVerificationPage()),
      GoRoute(path: AppRoutes.tutorHome, builder: (_, _) => const TutorHomePage()),
      GoRoute(
        path: AppRoutes.tutorOnboarding,
        builder: (_, _) => _withTutorProfile(const TutorOnboardingWizardPage()),
      ),
      GoRoute(
        path: AppRoutes.tutorProfileSettings,
        builder: (_, _) => _withTutorProfile(const TutorProfileSettingsPage()),
      ),
      GoRoute(path: AppRoutes.studentHome, builder: (_, _) => const StudentHomePage()),
      GoRoute(
        path: AppRoutes.map,
        builder: (_, _) => MultiBlocProvider(
          providers: [
            BlocProvider<MapBloc>(create: (_) => sl<MapBloc>()),
            BlocProvider<WalletBloc>(create: (ctx) {
              final user = ctx.read<AuthBloc>().state.user;
              final bloc = sl<WalletBloc>();
              if (user != null) bloc.add(WalletLoaded(user.id));
              return bloc;
            }),
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
        path: AppRoutes.chat,
        builder: (_, st) => BlocProvider<ChatBloc>(
          create: (_) => sl<ChatBloc>(),
          child: ChatPage(
            counterpartyId: st.pathParameters['counterpartyId'] ?? '',
            counterpartyMaskedName: st.uri.queryParameters['name'],
          ),
        ),
      ),
    ],
  );
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
      BlocProvider<VacanciesBloc>(create: (ctx) {
        final user = ctx.read<AuthBloc>().state.user;
        final bloc = sl<VacanciesBloc>();
        if (user != null && bloc.state.status == VacanciesStatus.initial) {
          bloc.add(VacanciesLoaded(user.id));
        }
        return bloc;
      }),
      // Wallet bloc is also useful so the Apply sheet can refresh it after a
      // successful debit; provide a fresh instance if one isn't already in scope.
      BlocProvider<WalletBloc>(create: (ctx) {
        final user = ctx.read<AuthBloc>().state.user;
        final bloc = sl<WalletBloc>();
        if (user != null) bloc.add(WalletLoaded(user.id));
        return bloc;
      }),
    ],
    child: child,
  );
}
