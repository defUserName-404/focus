import 'package:drift/drift.dart';

import '../../../../core/services/db_service.dart';

abstract class IProjectLocalDataSource {
  Future<List<ProjectTableData>> getAllProjects();

  Future<ProjectTableData?> getProjectById(BigInt id);

  Future<int> createProject(ProjectTableCompanion companion);

  Future<void> updateProject(ProjectTableCompanion companion);

  Future<void> deleteProject(BigInt id);

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
  Future<ProjectTableData?> getProjectById(BigInt id) async {
    final query = _db.select(_db.projectTable)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row;
  }

  @override
  Future<int> createProject(ProjectTableCompanion companion) async {
    return await _db.into(_db.projectTable).insert(companion);
  }

  @override
  Future<void> updateProject(ProjectTableCompanion companion) async {
    await (_db.update(_db.projectTable)
          ..where((t) => t.id.equals(companion.id.value)))
        .write(companion);
  }

  @override
  Future<void> deleteProject(BigInt id) async {
    final deleteQuery = _db.delete(_db.projectTable)..where((t) => t.id.equals(id));
    await deleteQuery.go();
  }

  @override
  Stream<List<ProjectTableData>> watchAllProjects() {
    return _db.select(_db.projectTable).watch();
  }
}
