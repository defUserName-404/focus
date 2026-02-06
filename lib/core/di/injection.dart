import 'package:get_it/get_it.dart';
import 'package:isar_community/isar.dart';

import '../../features/projects/data/datasources/project_local_datasource.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/domain/repositories/i_project_repository.dart';
import '../services/db_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Register Isar as an asynchronous singleton
  getIt.registerSingletonAsync<Isar>(() => IsarDatabase.getInstance());

  await getIt.allReady(); // Ensure all async singletons are ready

  // Data Sources
  getIt.registerLazySingleton<IProjectLocalDataSource>(() => ProjectLocalDataSourceImpl(getIt<Isar>()));

  // Repositories
  getIt.registerLazySingleton<IProjectRepository>(() => ProjectRepositoryImpl(getIt<IProjectLocalDataSource>()));
}
