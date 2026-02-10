import '../entities/task.dart';

abstract class ITaskRepository {
  Future<List<Task>> getTasksByProjectId(BigInt projectId);
  Future<Task?> getTaskById(BigInt id);
  Future<List<Task>> getSubtasks(BigInt parentTaskId);
  Future<Task> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(BigInt id);
  Stream<List<Task>> watchTasksByProjectId(BigInt projectId);
}
