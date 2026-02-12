import 'package:drift/drift.dart';

import '../../../../core/services/db_service.dart';
import '../../domain/entities/project_list_filter_state.dart';

abstract interface class IProjectLocalDataSource {
  Future<List<ProjectTableData>> getAllProjects();

  Future<ProjectTableData?> getProjectById(BigInt id);

  Future<int> createProject(ProjectTableCompanion companion);

  Future<void> updateProject(ProjectTableCompanion companion);

  Future<void> deleteProject(BigInt id);

  Stream<ProjectTableData?> watchProjectById(BigInt id);

  Stream<List<ProjectTableData>> watchAllProjects();

  Stream<List<ProjectTableData>> watchFilteredProjects({
    String searchQuery,
    ProjectSortCriteria sortCriteria,
    ProjectSortOrder sortOrder,
  });
}

class ProjectLocalDataSourceImpl implements IProjectLocalDataSource {
  ProjectLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<ProjectTableData>> getAllProjects() async {
    return await _db.select(_db.projectTable).get();
  }

  @override
  Future<ProjectTableData?> getProjectById(BigInt id) async {
    final query = _db.select(_db.projectTable)..where((t) => t.id.equals(id));
    return await query.getSingleOrNull();
  }

  @override
  Future<int> createProject(ProjectTableCompanion companion) async {
    return await _db.into(_db.projectTable).insert(companion);
  }

  @override
  Future<void> updateProject(ProjectTableCompanion companion) async {
    await (_db.update(_db.projectTable)..where((t) => t.id.equals(companion.id.value))).write(companion);
  }

  @override
  Future<void> deleteProject(BigInt id) async {
    // Cascade: delete all tasks belonging to this project first
    await (_db.delete(_db.taskTable)..where((t) => t.projectId.equals(id))).go();
    await (_db.delete(_db.projectTable)..where((t) => t.id.equals(id))).go();
  }

  @override
  Stream<ProjectTableData?> watchProjectById(BigInt id) {
    return (_db.select(_db.projectTable)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  @override
  Stream<List<ProjectTableData>> watchAllProjects() {
    return _db.select(_db.projectTable).watch();
  }

  @override
  Stream<List<ProjectTableData>> watchFilteredProjects({
    String searchQuery = '',
    ProjectSortCriteria sortCriteria = ProjectSortCriteria.recentlyModified,
    ProjectSortOrder sortOrder = ProjectSortOrder.none,
  }) {
    final query = _db.select(_db.projectTable);

    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      query.where((t) => t.title.lower().like('%$q%') | t.description.lower().like('%$q%'));
    }

    if (sortOrder != ProjectSortOrder.none) {
      final mode = sortOrder == ProjectSortOrder.ascending ? OrderingMode.asc : OrderingMode.desc;
      query.orderBy([
        (t) {
          switch (sortCriteria) {
            case ProjectSortCriteria.recentlyModified:
              return OrderingTerm(expression: t.updatedAt, mode: mode);
            case ProjectSortCriteria.deadline:
              return OrderingTerm(expression: t.deadline, mode: mode);
            case ProjectSortCriteria.startDate:
              return OrderingTerm(expression: t.startDate, mode: mode);
            case ProjectSortCriteria.title:
              return OrderingTerm(expression: t.title, mode: mode);
            case ProjectSortCriteria.createdDate:
              return OrderingTerm(expression: t.createdAt, mode: mode);
          }
        },
      ]);
    } else {
      query.orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    }

    return query.watch();
  }
}
