import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/project.dart';
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

// ── Filter state provider (manual, no codegen needed) ──────────────────────

final projectListFilterStateProvider = StateProvider<ProjectListFilterState>((ref) => const ProjectListFilterState());

// ── Computed provider: filtered & sorted project list ──────────────────────

final filteredProjectListProvider = Provider<AsyncValue<List<Project>>>((ref) {
  final projectsAsync = ref.watch(projectListProvider);
  final filter = ref.watch(projectListFilterStateProvider);

  return projectsAsync.whenData((projects) => _filterAndSortProjects(projects, filter));
});

List<Project> _filterAndSortProjects(List<Project> projects, ProjectListFilterState filter) {
  var result = projects;

  // Search filter
  final q = filter.searchQuery.trim().toLowerCase();
  if (q.isNotEmpty) {
    result = result
        .where((p) => p.title.toLowerCase().contains(q) || (p.description?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  // Sort
  if (filter.sortOrder != ProjectSortOrder.none) {
    result = List.of(result);
    result.sort((a, b) {
      int comparison = 0;

      switch (filter.sortCriteria) {
        case ProjectSortCriteria.createdDate:
          comparison = a.createdAt.compareTo(b.createdAt);
        case ProjectSortCriteria.recentlyModified:
          comparison = a.updatedAt.compareTo(b.updatedAt);
        case ProjectSortCriteria.startDate:
          if (a.startDate == null && b.startDate == null) {
            comparison = 0;
          } else if (a.startDate == null) {
            comparison = 1;
          } else if (b.startDate == null) {
            comparison = -1;
          } else {
            comparison = a.startDate!.compareTo(b.startDate!);
          }
        case ProjectSortCriteria.deadline:
          if (a.deadline == null && b.deadline == null) {
            comparison = 0;
          } else if (a.deadline == null) {
            comparison = 1;
          } else if (b.deadline == null) {
            comparison = -1;
          } else {
            comparison = a.deadline!.compareTo(b.deadline!);
          }
        case ProjectSortCriteria.title:
          comparison = a.title.compareTo(b.title);
      }

      return filter.sortOrder == ProjectSortOrder.ascending ? comparison : -comparison;
    });
  }

  return result;
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
    await _repository.updateProject(project);
    await _loadProjects();
  }

  Future<void> deleteProject(BigInt id) async {
    await _repository.deleteProject(id);
    await _loadProjects();
  }
}
