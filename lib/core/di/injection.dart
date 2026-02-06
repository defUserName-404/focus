import 'package:get_it/get_it.dart';

import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/domain/repositories/i_project_repository.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Repositories
  getIt.registerLazySingleton<IProjectRepository>(() => ProjectRepositoryImpl());
}
