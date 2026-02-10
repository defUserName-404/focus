import 'package:drift/drift.dart';
import 'package:focus/core/services/db_service.dart';

abstract class ITaskLocalDataSource {
  Future<List<TaskTableData>> getTasksByProjectId(BigInt projectId);

  Future<TaskTableData?> getTaskById(BigInt id);

  Future<List<TaskTableData>> getSubtasks(BigInt parentTaskId);

  Future<int> createTask(TaskTableCompanion companion);

  Future<void> updateTask(TaskTableCompanion companion);

  Future<void> deleteTask(BigInt id);

  Stream<List<TaskTableData>> watchTasksByProjectId(BigInt projectId);
}

class TaskLocalDataSourceImpl implements ITaskLocalDataSource {
  TaskLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<TaskTableData>> getTasksByProjectId(BigInt projectId) async {
    return await (_db.select(_db.taskTable)..where((t) => t.projectId.equals(projectId))).get();
  }

  @override
  Future<TaskTableData?> getTaskById(BigInt id) async {
    return await (_db.select(_db.taskTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  @override
  Future<List<TaskTableData>> getSubtasks(BigInt parentTaskId) async {
    return await (_db.select(_db.taskTable)..where((t) => t.parentTaskId.equals(parentTaskId))).get();
  }

  @override
  Future<int> createTask(TaskTableCompanion companion) async {
    return await _db.into(_db.taskTable).insert(companion);
  }

  @override
  Future<void> updateTask(TaskTableCompanion companion) async {
    await (_db.update(_db.taskTable)
          ..where((t) => t.id.equals(companion.id.value)))
        .write(companion);
  }

  @override
  Future<void> deleteTask(BigInt id) async {
    await (_db.delete(_db.taskTable)..where((t) => t.id.equals(id))).go();
  }

  @override
  Stream<List<TaskTableData>> watchTasksByProjectId(BigInt projectId) {
    return (_db.select(_db.taskTable)..where((t) => t.projectId.equals(projectId))).watch();
  }
}
