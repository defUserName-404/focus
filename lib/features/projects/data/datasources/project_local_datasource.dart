import 'package:drift/drift.dart';

import '../../../../core/services/db_service.dart';
import '../../../../core/services/log_service.dart';
import '../../domain/entities/project_list_filter_state.dart';

abstract interface class IProjectLocalDataSource {
  Future<List<ProjectTableData>> getAllProjects();

  Future<ProjectTableData?> getProjectById(int id);

  Future<int> createProject(ProjectTableCompanion companion);

  Future<void> updateProject(ProjectTableCompanion companion);

  Future<void> deleteProject(int id);

  Stream<ProjectTableData?> watchProjectById(int id);

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
  final _log = LogService.instance;

  @override
  Future<List<ProjectTableData>> getAllProjects() async {
    return await _db.select(_db.projectTable).get();
  }

  @override
  Future<ProjectTableData?> getProjectById(int id) async {
    final query = _db.select(_db.projectTable)..where((t) => t.id.equals(id));
    return await query.getSingleOrNull();
  }

  @override
  Future<int> createProject(ProjectTableCompanion companion) async {
    try {
      return await _db.into(_db.projectTable).insert(companion);
    } catch (e, st) {
      _log.error('createProject failed', tag: 'ProjectLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> updateProject(ProjectTableCompanion companion) async {
    try {
      await (_db.update(_db.projectTable)..where((t) => t.id.equals(companion.id.value))).write(companion);
    } catch (e, st) {
      _log.error('updateProject failed', tag: 'ProjectLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> deleteProject(int id) async {
    // ON DELETE CASCADE on TaskTable.projectId propagates the delete to all
    // tasks (and transitively to their focus sessions). A single statement suffices.
    try {
      await (_db.delete(_db.projectTable)..where((t) => t.id.equals(id))).go();
    } catch (e, st) {
      _log.error('deleteProject failed', tag: 'ProjectLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<ProjectTableData?> watchProjectById(int id) {
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
