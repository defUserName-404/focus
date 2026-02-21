import 'package:flutter_riverpod/flutter_riverpod.dart' show StreamProvider;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/common/result.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../../domain/services/task_service.dart';
import 'task_filter_state.dart';

part 'task_provider.g.dart';

@Riverpod(keepAlive: true)
ITaskRepository taskRepository(Ref ref) {
  return getIt<ITaskRepository>();
}

@Riverpod(keepAlive: true)
Stream<List<Task>> tasksByProject(Ref ref, String projectId) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchTasksByProjectId(int.parse(projectId));
}

@Riverpod(keepAlive: true)
Future<Task> taskById(Ref ref, String taskId) async {
  final repository = ref.watch(taskRepositoryProvider);
  final task = await repository.getTaskById(int.parse(taskId));
  if (task == null) throw Exception('Task not found: $taskId');
  return task;
}

//  Filter state provider (per-project family)
@Riverpod(keepAlive: true)
class TaskListFilter extends _$TaskListFilter {
  @override
  TaskListFilterState build(String projectId) {
    return const TaskListFilterState();
  }

  void updateFilter({
    String? searchQuery,
    TaskSortCriteria? sortCriteria,
    TaskSortOrder? sortOrder,
    TaskPriority? priorityFilter,
  }) {
    state = state.copyWith(
      searchQuery: searchQuery,
      sortCriteria: sortCriteria,
      sortOrder: sortOrder,
      priorityFilter: priorityFilter,
    );
  }
}

//  Filtered task list — delegates to DB-level filtering

final filteredTasksProvider = StreamProvider.family<List<Task>, String>((ref, projectId) {
  final repository = ref.watch(taskRepositoryProvider);
  final filter = ref.watch(taskListFilterProvider(projectId));

  return repository.watchFilteredTasks(
    projectId: int.parse(projectId),
    searchQuery: filter.searchQuery,
    sortCriteria: filter.sortCriteria,
    sortOrder: filter.sortOrder,
    priorityFilter: filter.priorityFilter,
  );
});

@Riverpod(keepAlive: true)
class TaskNotifier extends _$TaskNotifier {
  late final TaskService _service;

  @override
  AsyncValue<List<Task>> build(String projectId) {
    _service = getIt<TaskService>();
    _loadTasks(projectId);
    return const AsyncValue.loading();
  }

  Future<void> _loadTasks(String projectId) async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _service.getTasksByProjectId(int.parse(projectId));
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Task> createTask({
    required String projectId,
    int? parentTaskId,
    required String title,
    TaskPriority? priority,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    required int depth,
  }) async {
    final result = await _service.createTask(
      projectId: int.parse(projectId),
      parentTaskId: parentTaskId,
      title: title,
      description: description,
      priority: priority ?? TaskPriority.medium,
      startDate: startDate,
      endDate: endDate,
      depth: depth,
    );
    switch (result) {
      case Success(:final value):
        await _loadTasks(projectId);
        return value;
      case Failure(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
        throw failure;
    }
  }

  Future<void> updateTask(Task task) async {
    final result = await _service.updateTask(task);
    switch (result) {
      case Success():
        await _loadTasks(task.projectId.toString());
      case Failure(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  Future<void> deleteTask(int id, String projectId) async {
    final result = await _service.deleteTask(id);
    switch (result) {
      case Success():
        await _loadTasks(projectId);
      case Failure(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final result = await _service.toggleTaskCompletion(task);
    switch (result) {
      case Success():
        await _loadTasks(task.projectId.toString());
      case Failure(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }
}
