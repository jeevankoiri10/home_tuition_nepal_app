import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../core/blocs/locale_cubit.dart';
import '../core/blocs/theme_cubit.dart';
import '../core/config/env.dart';
import '../core/services/cloudinary_service.dart';
import '../core/services/location_service.dart';
import '../core/services/firebase_messaging_push_service.dart';
import '../core/services/platform_settings_service.dart';
import '../core/services/push_notification_service.dart';
import '../core/services/presence_service.dart';
import '../core/services/usage/fake_usage_repository.dart';
import '../core/services/usage/supabase_usage_repository.dart';
import '../core/services/usage/usage_repository.dart';
import '../features/auth/data/fake_auth_repository.dart';
import '../features/auth/data/supabase_auth_repository.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/blocs/auth_bloc.dart';
import '../features/chat/data/fake_chat_repository.dart';
import '../features/chat/data/supabase_chat_repository.dart';
import '../features/chat/domain/chat_repository.dart';
import '../features/chat/presentation/blocs/chat_bloc.dart';
import '../features/contracts/data/fake_contracts_repository.dart';
import '../features/contracts/data/supabase_contracts_repository.dart';
import '../features/contracts/domain/contracts_repository.dart';
import '../features/contracts/presentation/blocs/contract_bloc.dart';
import '../features/map/data/fake_map_repository.dart';
import '../features/map/data/supabase_map_repository.dart';
import '../features/map/domain/map_repository.dart';
import '../features/map/presentation/blocs/map_bloc.dart';
import '../features/notifications/data/fake_notifications_repository.dart';
import '../features/notifications/data/supabase_notifications_repository.dart';
import '../features/notifications/domain/notifications_repository.dart';
import '../features/notifications/presentation/blocs/notifications_bloc.dart';
import '../features/reviews/data/fake_reviews_repository.dart';
import '../features/reviews/data/supabase_reviews_repository.dart';
import '../features/reviews/domain/reviews_repository.dart';
import '../features/reviews/presentation/cubit/reviews_cubit.dart';
import '../features/topups/data/fake_top_ups_repository.dart';
import '../features/topups/data/supabase_top_ups_repository.dart';
import '../features/topups/domain/top_ups_repository.dart';
import '../features/student_requests/data/fake_student_requests_repository.dart';
import '../features/student_requests/data/supabase_student_requests_repository.dart';
import '../features/student_requests/domain/student_requests_repository.dart';
import '../features/student_requests/presentation/blocs/student_requests_bloc.dart';
import '../features/student_profile/presentation/cubit/student_onboarding_cubit.dart';
import '../features/tutor_profile/data/fake_tutor_repository.dart';
import '../features/tutor_profile/data/supabase_tutor_repository.dart';
import '../features/tutor_profile/domain/tutor_repository.dart';
import '../features/tutor_profile/presentation/blocs/tutor_profile_bloc.dart';
import '../features/vacancies/data/fake_vacancies_repository.dart';
import '../features/vacancies/data/supabase_vacancies_repository.dart';
import '../features/vacancies/domain/vacancies_repository.dart';
import '../features/vacancies/presentation/blocs/vacancies_bloc.dart';
import '../features/vacancies/presentation/blocs/vacancy_map_bloc.dart';
import '../features/wallet/data/fake_wallet_repository.dart';
import '../features/wallet/data/supabase_wallet_repository.dart';
import '../features/wallet/domain/wallet_repository.dart';
import '../features/wallet/presentation/blocs/wallet_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<LocaleCubit>(
      () => LocaleCubit(
        sl<SharedPreferences>(),
        onLanguageChanged: (code) async {
          if (sl.isRegistered<AuthRepository>()) {
            await sl<AuthRepository>().setLanguage(code);
          }
        },
      ),
    )
    ..registerLazySingleton<ThemeCubit>(
      () => ThemeCubit(sl<SharedPreferences>()),
    )
    ..registerSingleton<LocationService>(LocationService())
    ..registerSingleton<CloudinaryService>(CloudinaryService())
    ..registerSingleton<PlatformSettingsService>(PlatformSettingsService())
    // Push channel — real FCM once Firebase is configured for the app
    // (see docs/push_setup.md); otherwise a no-op so the in-app feed still
    // works without push credentials.
    ..registerSingleton<PushNotificationService>(
      Env.pushNotificationsConfigured
          ? FirebaseMessagingPushService()
          : FakePushNotificationService(),
    );

  if (Env.hasSupabase) {
    await sb.Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    final client = sb.Supabase.instance.client;
    final cloudinary = sl<CloudinaryService>();
    sl
      ..registerSingleton<AuthRepository>(SupabaseAuthRepository(client))
      ..registerSingleton<TutorRepository>(
        SupabaseTutorRepository(client, cloudinary),
      )
      ..registerSingleton<MapRepository>(SupabaseMapRepository(client))
      ..registerSingleton<WalletRepository>(SupabaseWalletRepository(client))
      ..registerSingleton<StudentRequestsRepository>(
        SupabaseStudentRequestsRepository(client),
      )
      ..registerSingleton<VacanciesRepository>(
        SupabaseVacanciesRepository(client),
      )
      ..registerSingleton<NotificationsRepository>(
        SupabaseNotificationsRepository(client),
      )
      ..registerSingleton<ChatRepository>(SupabaseChatRepository(client))
      ..registerSingleton<ContractsRepository>(
        SupabaseContractsRepository(client),
      )
      ..registerSingleton<ReviewsRepository>(SupabaseReviewsRepository(client))
      ..registerSingleton<TopUpsRepository>(
        SupabaseTopUpsRepository(client, cloudinary),
      )
      ..registerSingleton<UsageRepository>(SupabaseUsageRepository(client));
  } else {
    sl
      ..registerSingleton<AuthRepository>(FakeAuthRepository())
      ..registerSingleton<TutorRepository>(FakeTutorRepository())
      ..registerSingleton<MapRepository>(FakeMapRepository())
      ..registerSingleton<WalletRepository>(
        FakeWalletRepository(sl<PlatformSettingsService>()),
      )
      ..registerSingleton<StudentRequestsRepository>(
        FakeStudentRequestsRepository(),
      )
      ..registerSingleton<VacanciesRepository>(
        FakeVacanciesRepository(
          sl<WalletRepository>(),
          sl<PlatformSettingsService>(),
        ),
      )
      ..registerSingleton<NotificationsRepository>(
        FakeNotificationsRepository(),
      )
      ..registerSingleton<ChatRepository>(
        FakeChatRepository(sl<WalletRepository>()),
      )
      ..registerSingleton<ContractsRepository>(FakeContractsRepository())
      ..registerSingleton<ReviewsRepository>(
        FakeReviewsRepository(
          sl<WalletRepository>(),
          sl<PlatformSettingsService>(),
        ),
      )
      ..registerSingleton<TopUpsRepository>(
        FakeTopUpsRepository(
          sl<WalletRepository>(),
          sl<PlatformSettingsService>(),
        ),
      )
      ..registerSingleton<UsageRepository>(FakeUsageRepository());
  }

  await sl<PlatformSettingsService>().refresh();

  sl
    // Singleton: the router's onboarding guard and the top-level provider must
    // observe the same auth bloc instance (its stream feeds GoRouterRefreshStream).
    ..registerLazySingleton<AuthBloc>(
      () => AuthBloc(sl<AuthRepository>())..add(const AuthStarted()),
    )
    ..registerLazySingleton<PresenceService>(
      () => PresenceService(
        client: Env.hasSupabase ? sb.Supabase.instance.client : null,
        authStates: sl<AuthBloc>().stream,
        currentAuthState: () => sl<AuthBloc>().state,
      ),
    )
    ..registerFactory<TutorProfileBloc>(
      () => TutorProfileBloc(sl<TutorRepository>()),
    )
    ..registerFactory<MapBloc>(
      () =>
          MapBloc(sl<MapRepository>(), sl<LocationService>())
            ..add(const MapStarted()),
    )
    ..registerFactory<WalletBloc>(() => WalletBloc(sl<WalletRepository>()))
    ..registerLazySingleton<StudentRequestsBloc>(
      () => StudentRequestsBloc(sl<StudentRequestsRepository>()),
    )
    ..registerLazySingleton<VacanciesBloc>(
      () => VacanciesBloc(sl<VacanciesRepository>()),
    )
    ..registerFactory<VacancyMapBloc>(
      () => VacancyMapBloc(sl<VacanciesRepository>(), sl<LocationService>()),
    )
    ..registerLazySingleton<NotificationsBloc>(
      () => NotificationsBloc(sl<NotificationsRepository>()),
    )
    ..registerFactory<StudentOnboardingCubit>(
      () => StudentOnboardingCubit(sl<AuthRepository>()),
    )
    ..registerFactory<ChatBloc>(() => ChatBloc(sl<ChatRepository>()))
    ..registerFactory<ContractBloc>(
      () => ContractBloc(sl<ContractsRepository>()),
    )
    ..registerFactory<ReviewsCubit>(
      () => ReviewsCubit(sl<ReviewsRepository>()),
    );
}
