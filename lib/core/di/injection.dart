import 'package:get_it/get_it.dart';

import '../../features/projects/data/datasources/project_local_datasource.dart';
import '../../features/projects/data/datasources/project_template_local_datasource.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/data/repositories/project_template_repository_impl.dart';
import '../../features/projects/domain/repositories/i_project_repository.dart';
import '../../features/projects/domain/repositories/i_project_template_repository.dart';
import '../../features/projects/domain/services/project_service.dart';
import '../../features/projects/domain/services/project_template_service.dart';
import '../../features/milestones/data/datasources/milestone_local_datasource.dart';
import '../../features/milestones/data/repositories/milestone_repository_impl.dart';
import '../../features/milestones/domain/repositories/i_milestone_repository.dart';
import '../../features/milestones/domain/services/milestone_service.dart';
import '../../features/notifications/data/datasources/notification_inbox_local_datasource.dart';
import '../../features/notifications/data/repositories/notification_inbox_repository_impl.dart';
import '../../features/notifications/domain/repositories/i_notification_inbox_repository.dart';
import '../../features/notifications/domain/services/notification_inbox_sync_service.dart';
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
import '../../features/onboarding/domain/services/onboarding_service.dart';
import '../../features/sync/data/datasources/sync_local_datasource.dart';
import '../../features/sync/data/services/google_drive_service.dart';
import '../../features/sync/domain/services/i_cloud_storage_service.dart';
import '../../features/sync/domain/services/sync_auto_sync_service.dart';
import '../../features/sync/domain/services/sync_backup_service.dart';
import '../../features/sync/domain/services/sync_engine.dart';
import '../../features/sync/domain/services/sync_purge_service.dart';
import '../../features/tags/data/datasources/tag_local_datasource.dart';
import '../../features/tags/data/repositories/tag_repository_impl.dart';
import '../../features/tags/domain/repositories/i_tag_repository.dart';
import '../../features/tags/domain/services/tag_service.dart';
import '../../features/tasks/data/datasources/task_local_datasource.dart';
import '../../features/tasks/data/datasources/task_stats_local_datasource.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/data/repositories/task_stats_repository_impl.dart';
import '../../features/tasks/domain/repositories/i_task_repository.dart';
import '../../features/tasks/domain/repositories/i_task_stats_repository.dart';
import '../../features/tasks/domain/services/task_notification_service.dart';
import '../../features/tasks/domain/services/task_service.dart';
import '../services/audio_service.dart';
import '../services/audio_session_manager.dart';
import '../services/data_change_bus.dart';
import '../services/db_service.dart';
import '../services/desktop_lifecycle_service.dart';
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
    ..registerSingleton<DataChangeBus>(DataChangeBus())
    ..registerLazySingleton<AudioService>(() => AudioService());

  // Platform-specific services
  if (PlatformUtils.supportsMediaSession) {
    final audioHandler = await FocusAudioHandler.init();
    getIt.registerSingleton<FocusAudioHandler>(audioHandler);
  }

  // Notification service for native platforms with local notification support.
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
  _initMilestonesDi();
  _initTagsDi();
  _initNotificationsDi();
  _initTasksDi();
  _initSettingsDi();
  _initOnboardingDi();

  if (PlatformUtils.isDesktop) {
    getIt.registerLazySingleton<DesktopLifecycleService>(() => DesktopLifecycleService(getIt<ISettingsRepository>()));
  }

  _initSessionDi();
  _initSyncDi();
}

void _initProjectsDi() {
  getIt
    ..registerLazySingleton<IProjectLocalDataSource>(() => ProjectLocalDataSourceImpl(getIt<AppDatabase>()))
    ..registerLazySingleton<IProjectRepository>(
      () => ProjectRepositoryImpl(getIt<IProjectLocalDataSource>(), getIt<DataChangeBus>()),
    )
    ..registerLazySingleton<ProjectService>(() => ProjectService(getIt<IProjectRepository>()))
    ..registerLazySingleton<IProjectTemplateLocalDataSource>(
      () => ProjectTemplateLocalDataSourceImpl(getIt<AppDatabase>()),
    )
    ..registerLazySingleton<IProjectTemplateRepository>(
      () => ProjectTemplateRepositoryImpl(getIt<IProjectTemplateLocalDataSource>(), getIt<DataChangeBus>()),
    )
    ..registerLazySingleton<ProjectTemplateService>(
      () => ProjectTemplateService(
        getIt<IProjectTemplateRepository>(),
        getIt<IProjectRepository>(),
        getIt<ProjectService>(),
        getIt<TaskService>(),
        getIt<MilestoneService>(),
        getIt<TagService>(),
      ),
    );
}

void _initMilestonesDi() {
  getIt
    ..registerLazySingleton<IMilestoneLocalDataSource>(() => MilestoneLocalDataSourceImpl(getIt<AppDatabase>()))
    ..registerLazySingleton<IMilestoneRepository>(
      () => MilestoneRepositoryImpl(getIt<IMilestoneLocalDataSource>(), getIt<DataChangeBus>()),
    )
    ..registerLazySingleton<MilestoneService>(() => MilestoneService(getIt<IMilestoneRepository>()));
}

void _initTagsDi() {
  getIt
    ..registerLazySingleton<ITagLocalDataSource>(() => TagLocalDataSourceImpl(getIt<AppDatabase>()))
    ..registerLazySingleton<ITagRepository>(
      () => TagRepositoryImpl(getIt<ITagLocalDataSource>(), getIt<DataChangeBus>()),
    )
    ..registerLazySingleton<TagService>(() => TagService(getIt<ITagRepository>()));
}

void _initNotificationsDi() {
  getIt
    ..registerLazySingleton<INotificationInboxLocalDataSource>(
      () => NotificationInboxLocalDataSourceImpl(getIt<AppDatabase>()),
    )
    ..registerLazySingleton<INotificationInboxRepository>(
      () => NotificationInboxRepositoryImpl(getIt<INotificationInboxLocalDataSource>()),
    )
    ..registerLazySingleton<NotificationInboxSyncService>(
      () => NotificationInboxSyncService(getIt<INotificationService>(), getIt<INotificationInboxRepository>()),
    );
}

void _initTasksDi() {
  getIt
    ..registerLazySingleton<ITaskLocalDataSource>(() => TaskLocalDataSourceImpl(getIt<AppDatabase>()))
    ..registerLazySingleton<ITaskStatsLocalDataSource>(() => TaskStatsLocalDataSourceImpl(getIt<AppDatabase>()))
    ..registerLazySingleton<ITaskRepository>(
      () => TaskRepositoryImpl(getIt<ITaskLocalDataSource>(), getIt<DataChangeBus>()),
    )
    ..registerLazySingleton<ITaskStatsRepository>(() => TaskStatsRepositoryImpl(getIt<ITaskStatsLocalDataSource>()))
    ..registerLazySingleton<TaskNotificationService>(
      () => TaskNotificationService(getIt<INotificationService>(), getIt<ITaskRepository>()),
    )
    ..registerLazySingleton<TaskService>(() => TaskService(getIt<ITaskRepository>(), getIt<TaskNotificationService>()));
}

void _initSettingsDi() {
  getIt
    ..registerLazySingleton<ISettingsLocalDataSource>(() => SettingsLocalDataSourceImpl(getIt<AppDatabase>()))
    ..registerLazySingleton<ISettingsRepository>(
      () => SettingsRepositoryImpl(getIt<ISettingsLocalDataSource>(), getIt<DataChangeBus>()),
    )
    ..registerLazySingleton<SettingsService>(() => SettingsService(getIt<ISettingsRepository>()));
}

void _initOnboardingDi() {
  getIt.registerLazySingleton<OnboardingService>(() => OnboardingService(getIt<SettingsService>()));
}

void _initSessionDi() {
  getIt
    ..registerLazySingleton<IFocusLocalDataSource>(() => FocusLocalDataSourceImpl(getIt<AppDatabase>()))
    ..registerLazySingleton<IFocusSessionRepository>(
      () => FocusSessionRepositoryImpl(getIt<IFocusLocalDataSource>(), getIt<DataChangeBus>()),
    )
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

void _initSyncDi() {
  getIt
    ..registerLazySingleton<ICloudStorageService>(() => GoogleDriveService())
    ..registerLazySingleton<ISyncLocalDataSource>(() => SyncLocalDataSourceImpl(getIt<AppDatabase>()))
    ..registerLazySingleton<SyncPurgeService>(() => SyncPurgeService(getIt<AppDatabase>()))
    ..registerLazySingleton<SyncEngine>(
      () => SyncEngine(getIt<ICloudStorageService>(), getIt<ISyncLocalDataSource>(), getIt<ISettingsRepository>()),
    )
    ..registerLazySingleton<SyncBackupService>(() => SyncBackupService(getIt<SyncEngine>()))
    ..registerLazySingleton<SyncAutoSyncService>(
      () => SyncAutoSyncService(
        syncEngine: getIt<SyncEngine>(),
        cloudService: getIt<ICloudStorageService>(),
        dataChangeBus: getIt<DataChangeBus>(),
      ),
    );
}
