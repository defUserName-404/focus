import '../entities/task.dart';
import '../entities/task_priority.dart';
import '../../presentation/providers/task_filter_state.dart';
import '../../../all_tasks/domain/entities/all_tasks_filter_state.dart';

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

  /// Watch ALL tasks across all projects with filtering/sorting.
  Stream<List<Task>> watchAllFilteredTasks({
    String searchQuery,
    AllTasksSortCriteria sortCriteria,
    AllTasksSortOrder sortOrder,
    TaskPriority? priorityFilter,
    TaskCompletionFilter completionFilter,
  });
}
