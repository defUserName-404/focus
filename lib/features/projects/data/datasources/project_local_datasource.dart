import 'package:drift/drift.dart';

import '../../../../core/services/db_service.dart';

abstract class IProjectLocalDataSource {
  Future<List<ProjectTableData>> getAllProjects();

  Future<ProjectTableData?> getProjectById(String id);

  Future<void> createProject(ProjectTableCompanion companion);

  Future<void> updateProject(ProjectTableCompanion companion);

  Future<void> deleteProject(String id);

  Stream<List<ProjectTableData>> watchAllProjects();
}

class ProjectLocalDataSourceImpl implements IProjectLocalDataSource {
  ProjectLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<ProjectTableData>> getAllProjects() async {
    final rows = await _db.select(_db.projectTable).get();
    return rows;
  }

  @override
  Future<ProjectTableData?> getProjectById(String id) async {
    final query = _db.select(_db.projectTable)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row;
  }

  @override
  Future<void> createProject(ProjectTableCompanion companion) async {
    await _db.into(_db.projectTable).insert(companion);
  }

  @override
  Future<void> updateProject(ProjectTableCompanion companion) async {
    await _db.into(_db.projectTable).insert(companion, mode: InsertMode.insertOrReplace);
  }

  @override
  Future<void> deleteProject(String id) async {
    final deleteQuery = _db.delete(_db.projectTable)..where((t) => t.id.equals(id));
    await deleteQuery.go();
  }

  @override
  Stream<List<ProjectTableData>> watchAllProjects() {
    return _db.select(_db.projectTable).watch();
  }
}
