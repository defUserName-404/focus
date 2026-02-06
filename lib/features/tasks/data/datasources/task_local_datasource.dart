import 'package:drift/drift.dart';
import 'package:focus/core/services/db_service.dart';

abstract class ITaskLocalDataSource {
  Future<List<TaskTableData>> getTasksByProjectId(String projectId);

  Future<TaskTableData?> getTaskById(String id);

  Future<List<TaskTableData>> getSubtasks(String parentTaskId);

  Future<void> createTask(TaskTableCompanion companion);

  Future<void> updateTask(TaskTableCompanion companion);

  Future<void> deleteTask(String id);

  Stream<List<TaskTableData>> watchTasksByProjectId(String projectId);
}

class TaskLocalDataSourceImpl implements ITaskLocalDataSource {
  TaskLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<TaskTableData>> getTasksByProjectId(String projectId) async {
    return await (_db.select(_db.taskTable)..where((t) => t.projectId.equals(projectId))).get();
  }

  @override
  Future<TaskTableData?> getTaskById(String id) async {
    return await (_db.select(_db.taskTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  @override
  Future<List<TaskTableData>> getSubtasks(String parentTaskId) async {
    return await (_db.select(_db.taskTable)..where((t) => t.parentTaskId.equals(parentTaskId))).get();
  }

  @override
  Future<void> createTask(TaskTableCompanion companion) async {
    await _db.into(_db.taskTable).insert(companion);
  }

  @override
  Future<void> updateTask(TaskTableCompanion companion) async {
    await _db.into(_db.taskTable).insert(companion, mode: InsertMode.insertOrReplace);
  }

  @override
  Future<void> deleteTask(String id) async {
    await (_db.delete(_db.taskTable)..where((t) => t.id.equals(id))).go();
  }

  @override
  Stream<List<TaskTableData>> watchTasksByProjectId(String projectId) {
    return (_db.select(_db.taskTable)..where((t) => t.projectId.equals(projectId))).watch();
  }
}
