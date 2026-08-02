import 'package:drift/drift.dart';

import '../../../../core/services/db_service.dart';
import '../../../../core/services/log_service.dart';
import '../../domain/entities/project_list_filter_state.dart';
import '../../domain/entities/project_status.dart';

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
    ProjectStatus? statusFilter,
  });
}

class ProjectLocalDataSourceImpl implements IProjectLocalDataSource {
  ProjectLocalDataSourceImpl(this._db);

  final AppDatabase _db;
  final _log = LogService.instance;

  @override
  Future<List<ProjectTableData>> getAllProjects() async {
    return await (_db.select(_db.projectTable)..where((t) => t.deletedAt.isNull())).get();
  }

  @override
  Future<ProjectTableData?> getProjectById(int id) async {
    final query = _db.select(_db.projectTable)..where((t) => t.id.equals(id) & t.deletedAt.isNull());
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
    // Soft-delete: ON DELETE CASCADE no longer applies, so tombstone the project,
    // all of its tasks, and their focus sessions in one transaction.
    try {
      await _db.transaction(() async {
        final now = DateTime.now();
        final taskIds =
            await (_db.selectOnly(_db.taskTable)
                  ..addColumns([_db.taskTable.id])
                  ..where(_db.taskTable.projectId.equals(id) & _db.taskTable.deletedAt.isNull()))
                .map((row) => row.read(_db.taskTable.id)!)
                .get();

        if (taskIds.isNotEmpty) {
          await (_db.update(_db.focusSessionTable)..where((t) => t.taskId.isIn(taskIds) & t.deletedAt.isNull())).write(
            FocusSessionTableCompanion(deletedAt: Value(now)),
          );

          await (_db
                  .update(_db.taskCompletionTable)
                ..where((t) => t.taskId.isIn(taskIds) & t.deletedAt.isNull()))
              .write(
                TaskCompletionTableCompanion(deletedAt: Value(now), updatedAt: Value(now)),
              );

          await (_db.delete(_db.taskTagTable)..where((t) => t.taskId.isIn(taskIds))).go();

          await (_db.update(_db.taskTable)..where((t) => t.projectId.equals(id) & t.deletedAt.isNull())).write(
            TaskTableCompanion(deletedAt: Value(now), updatedAt: Value(now)),
          );
        }

        await (_db.update(_db.milestoneTable)..where((t) => t.projectId.equals(id) & t.deletedAt.isNull())).write(
          MilestoneTableCompanion(deletedAt: Value(now), updatedAt: Value(now)),
        );

        await (_db.update(_db.projectTable)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).write(
          ProjectTableCompanion(deletedAt: Value(now), updatedAt: Value(now)),
        );
      });
    } catch (e, st) {
      _log.error('deleteProject failed', tag: 'ProjectLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<ProjectTableData?> watchProjectById(int id) {
    return (_db.select(_db.projectTable)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).watchSingleOrNull();
  }

  @override
  Stream<List<ProjectTableData>> watchAllProjects() {
    return (_db.select(_db.projectTable)..where((t) => t.deletedAt.isNull())).watch();
  }

  @override
  Stream<List<ProjectTableData>> watchFilteredProjects({
    String searchQuery = '',
    ProjectSortCriteria sortCriteria = ProjectSortCriteria.recentlyModified,
    ProjectSortOrder sortOrder = ProjectSortOrder.none,
    ProjectStatus? statusFilter,
  }) {
    final query = _db.select(_db.projectTable)..where((t) => t.deletedAt.isNull());

    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      query.where((t) => t.title.lower().like('%$q%') | t.description.lower().like('%$q%'));
    }

    if (statusFilter != null) {
      query.where((t) => t.status.equalsValue(statusFilter));
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
