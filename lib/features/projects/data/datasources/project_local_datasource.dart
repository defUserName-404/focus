import 'package:drift/drift.dart';
import 'package:focus/core/services/db_service.dart' as db;

abstract class IProjectLocalDataSource {
  Future<List<db.Project>> getAllProjects();

  Future<db.Project?> getProjectById(String id);

  Future<void> createProject(db.ProjectsCompanion companion);

  Future<void> updateProject(db.ProjectsCompanion companion);

  Future<void> deleteProject(String id);

  Stream<List<db.Project>> watchAllProjects();
}

class ProjectLocalDataSourceImpl implements IProjectLocalDataSource {
  ProjectLocalDataSourceImpl(this._db);

  final db.AppDatabase _db;

  @override
  Future<List<db.Project>> getAllProjects() async {
    final rows = await _db.select(_db.projects).get();
    return rows;
  }

  @override
  Future<db.Project?> getProjectById(String id) async {
    final query = _db.select(_db.projects)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row;
  }

  @override
  Future<void> createProject(db.ProjectsCompanion companion) async {
    await _db.into(_db.projects).insert(companion);
  }

  @override
  Future<void> updateProject(db.ProjectsCompanion companion) async {
    await _db.into(_db.projects).insert(companion, mode: InsertMode.insertOrReplace);
  }

  @override
  Future<void> deleteProject(String id) async {
    final deleteQuery = _db.delete(_db.projects)..where((t) => t.id.equals(id));
    await deleteQuery.go();
  }

  @override
  Stream<List<db.Project>> watchAllProjects() {
    return _db.select(_db.projects).watch();
  }
}
