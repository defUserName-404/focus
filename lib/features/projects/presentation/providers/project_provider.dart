import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/i_project_repository.dart';

part 'project_provider.g.dart';

@Riverpod(keepAlive: true)
IProjectRepository projectRepository(Ref ref) {
  return getIt<IProjectRepository>();
}

@Riverpod(keepAlive: true)
Stream<List<Project>> projectList(Ref ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchAllProjects();
}

@Riverpod(keepAlive: true)
class ProjectNotifier extends _$ProjectNotifier {
  late final IProjectRepository _repository;

  @override
  AsyncValue<List<Project>> build() {
    _repository = ref.watch(projectRepositoryProvider);
    _loadProjects();
    return const AsyncValue.loading();
  }

  Future<void> _loadProjects() async {
    state = const AsyncValue.loading();
    try {
      final projects = await _repository.getAllProjects();
      state = AsyncValue.data(projects);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createProject({
    required String title,
    String? description,
    DateTime? startDate,
    DateTime? deadline,
  }) async {
    final time = DateTime.now();
    final project = Project(
      title: title,
      description: description,
      startDate: startDate,
      deadline: deadline,
      createdAt: time,
      updatedAt: time,
    );

    await _repository.createProject(project);
    await _loadProjects();
  }

  Future<void> updateProject(Project project) async {
    await _repository.updateProject(project);
    await _loadProjects();
  }

  Future<void> deleteProject(BigInt id) async {
    await _repository.deleteProject(id);
    await _loadProjects();
  }
}
