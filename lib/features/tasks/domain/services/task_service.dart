import '../../../../core/common/result.dart';
import '../../../../core/services/log_service.dart';
import '../entities/task.dart';
import '../entities/task_extensions.dart';
import '../entities/task_priority.dart';
import '../repositories/i_task_repository.dart';

final _log = LogService.instance;

/// Domain service for task operations.
///
/// Sits between the presentation layer (providers/commands) and the
/// repository. Encapsulates business logic such as timestamping,
/// completion toggling, and depth management.
class TaskService {
  final ITaskRepository _repository;

  TaskService(this._repository);

  //  Read

  Future<List<Task>> getTasksByProjectId(int projectId) => _repository.getTasksByProjectId(projectId);

  Future<Task?> getTaskById(int id) => _repository.getTaskById(id);

  Stream<List<Task>> watchTasksByProjectId(int projectId) => _repository.watchTasksByProjectId(projectId);

  //  Write

  Future<Result<Task>> createTask({
    required int projectId,
    int? parentTaskId,
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? startDate,
    DateTime? endDate,
    required int depth,
  }) async {
    try {
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
      final created = await _repository.createTask(task);
      _log.info('Task created: "$title" (id=${created.id})', tag: 'TaskService');
      return Success(created);
    } catch (e, st) {
      _log.error('Failed to create task "$title"', tag: 'TaskService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to create task', error: e, stackTrace: st));
    }
  }

  Future<Result<void>> updateTask(Task task) async {
    try {
      final updated = task.copyWith(updatedAt: DateTime.now());
      await _repository.updateTask(updated);
      return const Success(null);
    } catch (e, st) {
      _log.error('Failed to update task ${task.id}', tag: 'TaskService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to update task', error: e, stackTrace: st));
    }
  }

  Future<Result<void>> deleteTask(int id) async {
    try {
      await _repository.deleteTask(id);
      _log.info('Task $id deleted', tag: 'TaskService');
      return const Success(null);
    } catch (e, st) {
      _log.error('Failed to delete task $id', tag: 'TaskService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to delete task', error: e, stackTrace: st));
    }
  }

  Future<Result<void>> toggleTaskCompletion(Task task) async {
    try {
      final updated = task.copyWith(isCompleted: !task.isCompleted, updatedAt: DateTime.now());
      await _repository.updateTask(updated);
      return const Success(null);
    } catch (e, st) {
      _log.error('Failed to toggle task ${task.id}', tag: 'TaskService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to toggle task', error: e, stackTrace: st));
    }
  }
}
