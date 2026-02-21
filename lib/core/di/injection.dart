import 'package:get_it/get_it.dart';

import '../../features/focus/data/datasources/focus_local_datasource.dart';
import '../../features/focus/data/repositories/focus_session_repository_impl.dart';
import '../../features/focus/domain/repositories/i_focus_session_repository.dart';
import '../../features/focus/domain/services/focus_audio_coordinator.dart';
import '../../features/focus/domain/services/focus_media_session_coordinator.dart';
import '../../features/focus/domain/services/focus_notification_coordinator.dart';
import '../../features/focus/domain/services/focus_session_service.dart';
import '../../features/projects/data/datasources/project_local_datasource.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/domain/repositories/i_project_repository.dart';
import '../../features/projects/domain/services/project_service.dart';
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/i_settings_repository.dart';
import '../../features/settings/domain/services/settings_service.dart';
import '../../features/tasks/data/datasources/task_local_datasource.dart';
import '../../features/tasks/data/datasources/task_stats_local_datasource.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/data/repositories/task_stats_repository_impl.dart';
import '../../features/tasks/domain/repositories/i_task_repository.dart';
import '../../features/tasks/domain/repositories/i_task_stats_repository.dart';
import '../../features/tasks/domain/services/task_service.dart';
import '../common/utils/platform_utils.dart';
import '../routing/navigation_service.dart';
import '../services/audio_service.dart';
import '../services/audio_session_manager.dart';
import '../services/db_service.dart';
import '../services/focus_audio_handler.dart';
import '../services/notification_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  //  Core Services
  getIt.registerSingleton<AppDatabase>(AppDatabase());
  getIt.registerLazySingleton<AudioService>(() => AudioService());
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());

  // Platform-specific services — only initialise where supported.
  if (PlatformUtils.supportsMediaSession) {
    // audio_service - MediaStyle notification & lock-screen controls.
    // Must init BEFORE notification service so the Android plugin context is ready.
    final audioHandler = await FocusAudioHandler.init();
    getIt.registerSingleton<FocusAudioHandler>(audioHandler);
  }

  if (PlatformUtils.supportsLocalNotifications) {
    final notificationService = NotificationService();
    await notificationService.init();
    getIt.registerSingleton<NotificationService>(notificationService);
  }

  if (PlatformUtils.supportsMediaSession) {
    // audio_session — headphone unplug, audio focus interruptions.
    final audioSessionManager = AudioSessionManager();
    await audioSessionManager.init();
    getIt.registerSingleton<AudioSessionManager>(audioSessionManager);
  }

  //  Data Sources
  getIt.registerLazySingleton<IProjectLocalDataSource>(() => ProjectLocalDataSourceImpl(getIt<AppDatabase>()));
  getIt.registerLazySingleton<ITaskLocalDataSource>(() => TaskLocalDataSourceImpl(getIt<AppDatabase>()));
  getIt.registerLazySingleton<IFocusLocalDataSource>(() => FocusLocalDataSourceImpl(getIt<AppDatabase>()));
  getIt.registerLazySingleton<ITaskStatsLocalDataSource>(() => TaskStatsLocalDataSourceImpl(getIt<AppDatabase>()));
  getIt.registerLazySingleton<ISettingsLocalDataSource>(() => SettingsLocalDataSourceImpl(getIt<AppDatabase>()));

  //  Repositories
  getIt.registerLazySingleton<IProjectRepository>(() => ProjectRepositoryImpl(getIt<IProjectLocalDataSource>()));
  getIt.registerLazySingleton<ITaskRepository>(() => TaskRepositoryImpl(getIt<ITaskLocalDataSource>()));
  getIt.registerLazySingleton<IFocusSessionRepository>(
    () => FocusSessionRepositoryImpl(getIt<IFocusLocalDataSource>()),
  );
  getIt.registerLazySingleton<ITaskStatsRepository>(() => TaskStatsRepositoryImpl(getIt<ITaskStatsLocalDataSource>()));
  getIt.registerLazySingleton<ISettingsRepository>(() => SettingsRepositoryImpl(getIt<ISettingsLocalDataSource>()));

  //  Feature Services
  getIt.registerLazySingleton<ProjectService>(() => ProjectService(getIt<IProjectRepository>()));
  getIt.registerLazySingleton<TaskService>(() => TaskService(getIt<ITaskRepository>()));
  getIt.registerLazySingleton<SettingsService>(() => SettingsService(getIt<ISettingsRepository>()));

  //  Focus Coordinators & Service
  getIt.registerLazySingleton<FocusSessionService>(
    () => FocusSessionService(getIt<IFocusSessionRepository>(), getIt<ITaskRepository>()),
  );
  getIt.registerLazySingleton<FocusAudioCoordinator>(
    () => FocusAudioCoordinator(getIt<AudioService>(), getIt<ISettingsRepository>()),
  );

  // Notification & media-session coordinators — conditional on platform.
  if (PlatformUtils.supportsLocalNotifications) {
    getIt.registerLazySingleton<FocusNotificationCoordinator>(
      () => FocusNotificationCoordinator(getIt<NotificationService>()),
    );
  }
  if (PlatformUtils.supportsMediaSession) {
    getIt.registerLazySingleton<FocusMediaSessionCoordinator>(
      () => FocusMediaSessionCoordinator(getIt<FocusAudioHandler>(), getIt<AudioSessionManager>()),
    );
  }
}
