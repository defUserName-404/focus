import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flutter/foundation.dart';
import '../../../../core/di/injection.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_progress.dart';
import '../../domain/repositories/i_project_repository.dart';
import '../../domain/entities/project_list_filter_state.dart';
import '../../domain/services/project_service.dart';

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

//  Filter state provider

@Riverpod(keepAlive: true)
class ProjectListFilter extends _$ProjectListFilter {
  @override
  ProjectListFilterState build() {
    return const ProjectListFilterState();
  }

  void updateFilter({String? searchQuery, ProjectSortCriteria? sortCriteria, ProjectSortOrder? sortOrder}) {
    state = state.copyWith(searchQuery: searchQuery, sortCriteria: sortCriteria, sortOrder: sortOrder);
  }
}

//  Filtered project list — delegates to DB-level filtering

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
Future<ProjectProgress> projectProgress(Ref ref, String projectId) async {
  final tasksAsync = ref.watch(tasksByProjectProvider(projectId));

  return tasksAsync.when(
    data: (tasks) async {
      if (tasks.isEmpty) return ProjectProgress.empty();
      return compute(_calculateProgress, tasks);
    },
    loading: () => ProjectProgress.empty(),
    error: (_, _) => ProjectProgress.empty(),
  );
}

ProjectProgress _calculateProgress(List<Task> tasks) {
  // Use dynamic to avoid type issues with compute if it's strict about list types
  // but better to use the specific type if possible.
  // Drift entities are usually fine.
  final total = tasks.length;
  final completed = tasks.where((t) => t.isCompleted == true).length;
  final progress = total > 0 ? completed / total : 0.0;
  final percent = (progress * 100).round();
  return ProjectProgress(progress: progress, percent: percent, label: '$completed of $total tasks');
}

@Riverpod(keepAlive: true)
class ProjectNotifier extends _$ProjectNotifier {
  late final ProjectService _service;

  @override
  AsyncValue<List<Project>> build() {
    _service = getIt<ProjectService>();
    _loadProjects();
    return const AsyncValue.loading();
  }

  Future<void> _loadProjects() async {
    state = const AsyncValue.loading();
    try {
      final projects = await _service.getAllProjects();
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
    final createdProject = await _service.createProject(
      title: title,
      description: description,
      startDate: startDate,
      deadline: deadline,
    );
    await _loadProjects();
    return createdProject;
  }

  Future<void> updateProject(Project project) async {
    await _service.updateProject(project);
    await _loadProjects();
  }

  Future<void> deleteProject(BigInt id) async {
    await _service.deleteProject(id);
    await _loadProjects();
  }
}
