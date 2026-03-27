import 'package:get_it/get_it.dart';

import '../../features/projects/data/datasources/project_local_datasource.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/domain/repositories/i_project_repository.dart';
import '../../features/projects/domain/services/project_service.dart';
import '../../features/session/data/datasources/focus_local_datasource.dart';
import '../../features/session/data/repositories/focus_session_repository_impl.dart';
import '../../features/session/domain/repositories/i_focus_session_repository.dart';
import '../../features/session/domain/services/focus_audio_coordinator.dart';
import '../../features/session/domain/services/focus_media_session_coordinator.dart';
import '../../features/session/domain/services/focus_notification_coordinator.dart';
import '../../features/session/domain/services/focus_session_service.dart';
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
import '../../features/tasks/domain/services/task_notification_service.dart';
import '../../features/tasks/domain/services/task_service.dart';
import '../routing/navigation_service.dart';
import '../services/audio_service.dart';
import '../services/audio_session_manager.dart';
import '../services/db_service.dart';
import '../services/focus_audio_handler.dart';
import '../services/i_notification_service.dart';
import '../services/no_op_notification_service.dart';
import '../services/notification_service.dart';
import '../utils/platform_utils.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Core Infrastructure Services
  getIt
    ..registerSingleton<AppDatabase>(AppDatabase())
    ..registerLazySingleton<AudioService>(() => AudioService())
    ..registerLazySingleton<NavigationService>(() => NavigationService());

  // Platform-specific services
  if (PlatformUtils.supportsMediaSession) {
    final audioHandler = await FocusAudioHandler.init();
    getIt.registerSingleton<FocusAudioHandler>(audioHandler);
  }

  // Notification service - use real implementation on supported platforms,
  // no-op implementation on platforms without notification support
  if (PlatformUtils.supportsLocalNotifications) {
    final notificationService = NotificationService();
    await notificationService.init();
    getIt.registerSingleton<INotificationService>(notificationService);
  } else {
    getIt.registerSingleton<INotificationService>(NoOpNotificationService());
  }

  if (PlatformUtils.supportsMediaSession) {
    final audioSessionManager = AudioSessionManager();
    await audioSessionManager.init();
    getIt.registerSingleton<AudioSessionManager>(audioSessionManager);
  }

  // Feature-based DI modules
  _initProjectsDi();
  _initTasksDi();
  _initSettingsDi();
  _initSessionDi();
}

void _initProjectsDi() {
  getIt
    ..registerLazySingleton<IProjectLocalDataSource>(() => ProjectLocalDataSourceImpl(getIt<AppDatabase>()))
    ..registerLazySingleton<IProjectRepository>(() => ProjectRepositoryImpl(getIt<IProjectLocalDataSource>()))
    ..registerLazySingleton<ProjectService>(() => ProjectService(getIt<IProjectRepository>()));
}

void _initTasksDi() {
  getIt
    ..registerLazySingleton<ITaskLocalDataSource>(() => TaskLocalDataSourceImpl(getIt<AppDatabase>()))
    ..registerLazySingleton<ITaskStatsLocalDataSource>(() => TaskStatsLocalDataSourceImpl(getIt<AppDatabase>()))
    ..registerLazySingleton<ITaskRepository>(() => TaskRepositoryImpl(getIt<ITaskLocalDataSource>()))
    ..registerLazySingleton<ITaskStatsRepository>(() => TaskStatsRepositoryImpl(getIt<ITaskStatsLocalDataSource>()))
    ..registerLazySingleton<TaskNotificationService>(
      () => TaskNotificationService(getIt<INotificationService>(), getIt<ITaskRepository>()),
    )
    ..registerLazySingleton<TaskService>(() => TaskService(getIt<ITaskRepository>(), getIt<TaskNotificationService>()));
}

void _initSettingsDi() {
  getIt
    ..registerLazySingleton<ISettingsLocalDataSource>(() => SettingsLocalDataSourceImpl(getIt<AppDatabase>()))
    ..registerLazySingleton<ISettingsRepository>(() => SettingsRepositoryImpl(getIt<ISettingsLocalDataSource>()))
    ..registerLazySingleton<SettingsService>(() => SettingsService(getIt<ISettingsRepository>()));
}

void _initSessionDi() {
  getIt
    ..registerLazySingleton<IFocusLocalDataSource>(() => FocusLocalDataSourceImpl(getIt<AppDatabase>()))
    ..registerLazySingleton<IFocusSessionRepository>(() => FocusSessionRepositoryImpl(getIt<IFocusLocalDataSource>()))
    ..registerLazySingleton<FocusSessionService>(
      () => FocusSessionService(getIt<IFocusSessionRepository>(), getIt<ITaskRepository>()),
    )
    ..registerLazySingleton<FocusAudioCoordinator>(
      () => FocusAudioCoordinator(getIt<AudioService>(), getIt<ISettingsRepository>()),
    )
    // FocusNotificationCoordinator always available - uses NoOpNotificationService on unsupported platforms
    ..registerLazySingleton<FocusNotificationCoordinator>(
      () => FocusNotificationCoordinator(getIt<INotificationService>()),
    );

  if (PlatformUtils.supportsMediaSession) {
    getIt.registerLazySingleton<FocusMediaSessionCoordinator>(
      () => FocusMediaSessionCoordinator(getIt<FocusAudioHandler>(), getIt<AudioSessionManager>()),
    );
  }
}
