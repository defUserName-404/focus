import '../entities/task.dart';
import '../entities/task_priority.dart';
import '../../presentation/providers/task_filter_state.dart';

abstract class ITaskRepository {
  Future<List<Task>> getTasksByProjectId(BigInt projectId);

  Future<Task?> getTaskById(BigInt id);

  Future<List<Task>> getSubtasks(BigInt parentTaskId);

  Future<Task> createTask(Task task);

  Future<void> updateTask(Task task);

  Future<void> deleteTask(BigInt id);

  Stream<List<Task>> watchTasksByProjectId(BigInt projectId);

  Stream<List<Task>> watchFilteredTasks({
    required BigInt projectId,
    String searchQuery,
    TaskSortOrder sortOrder,
    TaskSortCriteria sortCriteria,
    TaskPriority? priorityFilter,
  });
}
