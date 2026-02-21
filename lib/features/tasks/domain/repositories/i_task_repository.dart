import '../entities/all_tasks_filter_state.dart';
import '../entities/task.dart';
import '../entities/task_filter_state.dart';
import '../entities/task_priority.dart';

abstract class ITaskRepository {
  Future<List<Task>> getTasksByProjectId(int projectId);

  Future<Task?> getTaskById(int id);

  Future<List<Task>> getSubtasks(int parentTaskId);

  Future<Task> createTask(Task task);

  Future<void> updateTask(Task task);

  Future<void> deleteTask(int id);

  Stream<List<Task>> watchTasksByProjectId(int projectId);

  Stream<List<Task>> watchFilteredTasks({
    required int projectId,
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
