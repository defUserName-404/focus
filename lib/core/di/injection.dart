import 'package:get_it/get_it.dart';

import '../../features/projects/data/datasources/project_local_datasource.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/domain/repositories/i_project_repository.dart';
import '../services/db_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Register Drift AppDatabase as a singleton
  getIt.registerSingleton<AppDatabase>(AppDatabase());

  // Data Sources
  getIt.registerLazySingleton<IProjectLocalDataSource>(() => ProjectLocalDataSourceImpl(getIt<AppDatabase>()));

  // Repositories
  getIt.registerLazySingleton<IProjectRepository>(() => ProjectRepositoryImpl(getIt<IProjectLocalDataSource>()));
}
