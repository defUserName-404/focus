import '../../domain/entities/task.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../mappers/task_extensions.dart';

class TaskRepositoryImpl implements ITaskRepository {
  final ITaskLocalDataSource _local;

  TaskRepositoryImpl(this._local);

  @override
  Future<List<Task>> getTasksByProjectId(BigInt projectId) async {
    final rows = await _local.getTasksByProjectId(projectId);
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<Task?> getTaskById(BigInt id) async {
    final row = await _local.getTaskById(id);
    return row?.toDomain();
  }

  @override
  Future<List<Task>> getSubtasks(BigInt parentTaskId) async {
    final rows = await _local.getSubtasks(parentTaskId);
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<void> createTask(Task task) async {
    final companion = task.toCompanion();
    await _local.createTask(companion);
  }

  @override
  Future<void> updateTask(Task task) async {
    final companion = task.toCompanion();
    await _local.updateTask(companion);
  }

  @override
  Future<void> deleteTask(BigInt id) async {
    await _local.deleteTask(id);
  }

  @override
  Stream<List<Task>> watchTasksByProjectId(BigInt projectId) {
    return _local.watchTasksByProjectId(projectId).map((rows) => rows.map((r) => r.toDomain()).toList());
  }
}
