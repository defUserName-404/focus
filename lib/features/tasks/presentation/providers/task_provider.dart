import 'package:flutter_riverpod/flutter_riverpod.dart' show StateProvider;
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

// ── Filter state provider (manual, per-project family) ─────────────────────

final taskListFilterStateProvider =
    StateProvider.family<TaskListFilterState, String>(
  (ref, projectId) => const TaskListFilterState(),
);

// ── Computed provider: filtered & sorted task list per project ──────────────

final filteredTasksProvider =
    Provider.family<AsyncValue<List<Task>>, String>((ref, projectId) {
  final tasksAsync = ref.watch(tasksByProjectProvider(projectId));
  final filter = ref.watch(taskListFilterStateProvider(projectId));

  return tasksAsync.whenData(
    (tasks) => _filterAndSortTasks(tasks, filter),
  );
});

List<Task> _filterAndSortTasks(
  List<Task> tasks,
  TaskListFilterState filter,
) {
  var result = tasks;

  // Search filter
  final q = filter.searchQuery.trim().toLowerCase();
  if (q.isNotEmpty) {
    result = result
        .where(
          (t) =>
              t.title.toLowerCase().contains(q) ||
              (t.description?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  // Priority filter
  if (filter.priorityFilter != null) {
    result = result.where((t) => t.priority == filter.priorityFilter).toList();
  }

  // Sort
  result = List.of(result);
  result.sort((a, b) {
    switch (filter.sortCriteria) {
      case TaskSortCriteria.recentlyModified:
        return b.updatedAt.compareTo(a.updatedAt);
      case TaskSortCriteria.deadline:
        if (a.endDate == null && b.endDate == null) return 0;
        if (a.endDate == null) return 1;
        if (b.endDate == null) return -1;
        return a.endDate!.compareTo(b.endDate!);
      case TaskSortCriteria.priority:
        return a.priority.index.compareTo(b.priority.index);
      case TaskSortCriteria.title:
        return a.title.compareTo(b.title);
      case TaskSortCriteria.createdDate:
        return b.createdAt.compareTo(a.createdAt);
    }
  });

  return result;
}

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
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now(),
    );
    await _repository.updateTask(updatedTask);
    await _loadTasks(task.projectId.toString());
  }
}
