import '../entities/task.dart';
import '../entities/task_extensions.dart';
import '../entities/task_priority.dart';
import '../repositories/i_task_repository.dart';

/// Domain service for task operations.
///
/// Sits between the presentation layer (providers/commands) and the
/// repository. Encapsulates business logic such as timestamping,
/// completion toggling, and depth management.
class TaskService {
  final ITaskRepository _repository;

  TaskService(this._repository);

  //  Read

  Future<List<Task>> getTasksByProjectId(BigInt projectId) => _repository.getTasksByProjectId(projectId);

  Future<Task?> getTaskById(BigInt id) => _repository.getTaskById(id);

  Stream<List<Task>> watchTasksByProjectId(BigInt projectId) => _repository.watchTasksByProjectId(projectId);

  //  Write

  Future<Task> createTask({
    required BigInt projectId,
    BigInt? parentTaskId,
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? startDate,
    DateTime? endDate,
    required int depth,
  }) async {
    final now = DateTime.now();
    final task = Task(
      projectId: projectId,
      parentTaskId: parentTaskId,
      title: title,
      description: description,
      priority: priority,
      startDate: startDate,
      endDate: endDate,
      depth: depth,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );
    return _repository.createTask(task);
  }

  Future<void> updateTask(Task task) async {
    final updated = task.copyWith(updatedAt: DateTime.now());
    return _repository.updateTask(updated);
  }

  Future<void> deleteTask(BigInt id) => _repository.deleteTask(id);

  Future<void> toggleTaskCompletion(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted, updatedAt: DateTime.now());
    return _repository.updateTask(updated);
  }
}
