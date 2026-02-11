import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_extensions.dart';
import '../../domain/repositories/i_project_repository.dart';
import 'project_list_filter_state.dart';

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
Stream<Project?> projectById(Ref ref, String id) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchProjectById(BigInt.parse(id));
}

// ── Filter state provider ──────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class ProjectListFilter extends _$ProjectListFilter {
  @override
  ProjectListFilterState build() {
    return const ProjectListFilterState();
  }

  void updateFilter({
    String? searchQuery,
    ProjectSortCriteria? sortCriteria,
    ProjectSortOrder? sortOrder,
  }) {
    state = state.copyWith(
      searchQuery: searchQuery,
      sortCriteria: sortCriteria,
      sortOrder: sortOrder,
    );
  }
}

// ── Filtered project list — delegates to DB-level filtering ────────────────

final filteredProjectListProvider = StreamProvider<List<Project>>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  final filter = ref.watch(projectListFilterProvider);

  return repository.watchFilteredProjects(
    searchQuery: filter.searchQuery,
    sortCriteria: filter.sortCriteria,
    sortOrder: filter.sortOrder,
  );
});

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

  Future<Project> createProject({
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

    final createdProject = await _repository.createProject(project);
    await _loadProjects();
    return createdProject;
  }

  Future<void> updateProject(Project project) async {
    final updated = project.copyWith(updatedAt: DateTime.now());
    await _repository.updateProject(updated);
    await _loadProjects();
  }

  Future<void> deleteProject(BigInt id) async {
    await _repository.deleteProject(id);
    await _loadProjects();
  }
}
