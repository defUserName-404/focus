import 'package:flutter_riverpod/flutter_riverpod.dart' show StreamProvider;
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_extensions.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/repositories/i_task_repository.dart';
import 'task_filter_state.dart';

part 'task_provider.g.dart';

@Riverpod(keepAlive: true)
ITaskRepository taskRepository(Ref ref) {
  return getIt<ITaskRepository>();
}

@Riverpod(keepAlive: true)
Stream<List<Task>> tasksByProject(Ref ref, String projectId) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchTasksByProjectId(BigInt.parse(projectId));
}

// ── Filter state provider (per-project family) ─────────────────────────────

final taskListFilterStateProvider = StateProvider.family<TaskListFilterState, String>(
  (ref, projectId) => const TaskListFilterState(),
);

// ── Filtered task list — delegates to DB-level filtering ───────────────────

final filteredTasksProvider = StreamProvider.family<List<Task>, String>((ref, projectId) {
  final repository = ref.watch(taskRepositoryProvider);
  final filter = ref.watch(taskListFilterStateProvider(projectId));

  return repository.watchFilteredTasks(
    projectId: BigInt.parse(projectId),
    searchQuery: filter.searchQuery,
    sortCriteria: filter.sortCriteria,
    priorityFilter: filter.priorityFilter,
  );
});

@Riverpod(keepAlive: true)
class TaskNotifier extends _$TaskNotifier {
  late final ITaskRepository _repository;

  @override
  AsyncValue<List<Task>> build(String projectId) {
    _repository = ref.watch(taskRepositoryProvider);
    _loadTasks(projectId);
    return const AsyncValue.loading();
  }

  Future<void> _loadTasks(String projectId) async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _repository.getTasksByProjectId(BigInt.parse(projectId));
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Task> createTask({
    required String projectId,
    BigInt? parentTaskId,
    required String title,
    TaskPriority? priority,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    required int depth,
  }) async {
    final time = DateTime.now();
    final task = Task(
      projectId: BigInt.parse(projectId),
      parentTaskId: parentTaskId,
      title: title,
      description: description,
      priority: priority ?? TaskPriority.medium,
      startDate: startDate,
      endDate: endDate,
      depth: depth,
      isCompleted: false,
      createdAt: time,
      updatedAt: time,
    );

    final created = await _repository.createTask(task);
    await _loadTasks(projectId);
    return created;
  }

  Future<void> updateTask(Task task) async {
    final updated = task.copyWith(updatedAt: DateTime.now());
    await _repository.updateTask(updated);
    await _loadTasks(task.projectId.toString());
  }

  Future<void> deleteTask(BigInt id, String projectId) async {
    await _repository.deleteTask(id);
    await _loadTasks(projectId);
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted, updatedAt: DateTime.now());
    await _repository.updateTask(updatedTask);
    await _loadTasks(task.projectId.toString());
  }
}
