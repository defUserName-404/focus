import 'package:get_it/get_it.dart';

import '../../features/focus/data/datasources/focus_local_datasource.dart';
import '../../features/focus/data/repositories/focus_session_repository_impl.dart';
import '../../features/focus/domain/repositories/i_focus_session_repository.dart';
import '../../features/projects/data/datasources/project_local_datasource.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/domain/repositories/i_project_repository.dart';
import '../../features/tasks/data/datasources/task_local_datasource.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/i_task_repository.dart';
import '../services/audio_service.dart';
import '../services/db_service.dart';
import '../services/notification_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // ── Core Services ──
  getIt.registerSingleton<AppDatabase>(AppDatabase());
  getIt.registerLazySingleton<AudioService>(() => AudioService());

  final notificationService = NotificationService();
  await notificationService.init();
  getIt.registerSingleton<NotificationService>(notificationService);

  // ── Data Sources ──
  getIt.registerLazySingleton<IProjectLocalDataSource>(
    () => ProjectLocalDataSourceImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<ITaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<IFocusLocalDataSource>(
    () => FocusLocalDataSourceImpl(getIt<AppDatabase>()),
  );

  // ── Repositories ──
  getIt.registerLazySingleton<IProjectRepository>(
    () => ProjectRepositoryImpl(getIt<IProjectLocalDataSource>()),
  );
  getIt.registerLazySingleton<ITaskRepository>(
    () => TaskRepositoryImpl(getIt<ITaskLocalDataSource>()),
  );
  getIt.registerLazySingleton<IFocusSessionRepository>(
    () => FocusSessionRepositoryImpl(getIt<IFocusLocalDataSource>()),
  );
}
