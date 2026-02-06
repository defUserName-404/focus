import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_extensions.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/repositories/i_task_repository.dart';

part 'task_provider.g.dart';

@Riverpod(keepAlive: true)
ITaskRepository taskRepository(Ref ref) {
  return getIt<ITaskRepository>();
}

@Riverpod(keepAlive: true)
Stream<List<Task>> tasksByProject(Ref ref, String projectId) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchTasksByProjectId(projectId);
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
      final tasks = await _repository.getTasksByProjectId(projectId);
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createTask({
    required String projectId,
    String? parentTaskId,
    required String title,
    TaskPriority? priority,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required int depth,
  }) async {
    final time = DateTime.now();
    final task = Task(
      id: const Uuid().v4(),
      projectId: projectId,
      parentTaskId: parentTaskId,
      title: title,
      description: description,
      priority: priority ?? taskPriorityDefault(),
      startDate: startDate,
      endDate: endDate,
      depth: depth,
      isCompleted: false,
      createdAt: time,
      updatedAt: time,
    );

    await _repository.createTask(task);
    await _loadTasks(projectId);
  }

  Future<void> updateTask(Task task) async {
    await _repository.updateTask(task);
    await _loadTasks(task.projectId);
  }

  Future<void> deleteTask(String id, String projectId) async {
    await _repository.deleteTask(id);
    await _loadTasks(projectId);
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted, updatedAt: DateTime.now());
    await updateTask(updatedTask);
  }

  TaskPriority taskPriorityDefault() => TaskPriority.medium;
}
