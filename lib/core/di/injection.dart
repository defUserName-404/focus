import 'package:get_it/get_it.dart';

import '../../features/focus/data/repositories/focus_session_repository_impl.dart';
import '../../features/focus/domain/repositories/i_focus_session_repository.dart';
import '../../features/projects/data/datasources/project_local_datasource.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/domain/repositories/i_project_repository.dart';
import '../../features/tasks/data/datasources/task_local_datasource.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/i_task_repository.dart';
import '../services/db_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Register Drift AppDatabase as a singleton
  getIt.registerSingleton<AppDatabase>(AppDatabase());

  // Data Sources
  getIt.registerLazySingleton<IProjectLocalDataSource>(() => ProjectLocalDataSourceImpl(getIt<AppDatabase>()));
  getIt.registerLazySingleton<ITaskLocalDataSource>(() => TaskLocalDataSourceImpl(getIt<AppDatabase>()));

  // Repositories
  getIt.registerLazySingleton<IProjectRepository>(() => ProjectRepositoryImpl(getIt<IProjectLocalDataSource>()));
  getIt.registerLazySingleton<ITaskRepository>(() => TaskRepositoryImpl(getIt<ITaskLocalDataSource>()));
  getIt.registerLazySingleton<IFocusSessionRepository>(
    () => FocusSessionRepositoryImpl(getIt<AppDatabase>()),
  );
}
