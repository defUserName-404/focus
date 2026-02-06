import '../entities/task.dart';

abstract class ITaskRepository {
  Future<List<Task>> getTasksByProjectId(String projectId);
  Future<Task?> getTaskById(String id);
  Future<List<Task>> getSubtasks(String parentTaskId);
  Future<void> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Stream<List<Task>> watchTasksByProjectId(String projectId);
}
