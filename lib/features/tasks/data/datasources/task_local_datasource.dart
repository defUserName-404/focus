import 'package:drift/drift.dart';
import 'package:focus/core/services/db_service.dart';
import 'package:focus/core/services/log_service.dart';
import 'package:focus/features/tasks/domain/entities/task_filter_state.dart';
import 'package:focus/features/tasks/domain/entities/task_priority.dart';
import 'package:focus/features/tasks/domain/entities/task_status.dart';

import '../../domain/entities/all_tasks_filter_state.dart';

abstract class ITaskLocalDataSource {
  Future<List<TaskTableData>> getTasksByProjectId(int projectId);
  Future<TaskTableData?> getTaskById(int id);
  Future<List<TaskTableData>> getTasksWithDeadlines();
  Future<List<TaskTableData>> getSubtasks(int parentTaskId);
  Future<int> createTask(TaskTableCompanion companion);
  Future<void> updateTask(TaskTableCompanion companion);
  Future<void> deleteTask(int id);
  Stream<List<TaskTableData>> watchTasksByProjectId(int projectId);
  Stream<List<TaskTableData>> watchTasksWithDeadlines();
  Stream<List<TaskTableData>> watchFilteredTasks({
    required int projectId,
    String searchQuery,
    TaskSortCriteria sortCriteria,
    TaskSortOrder sortOrder,
    TaskPriority? priorityFilter,
    TaskStatus? statusFilter,
  });

  /// Watch ALL tasks across all projects with filtering/sorting.
  Stream<List<TaskTableData>> watchAllFilteredTasks({
    String searchQuery,
    AllTasksSortCriteria sortCriteria,
    AllTasksSortOrder sortOrder,
    TaskPriority? priorityFilter,
    TaskStatus? statusFilter,
    TaskCompletionFilter completionFilter,
  });

  Future<List<TaskCompletionTableData>> getCompletionsForTask(int taskId);

  Future<TaskCompletionTableData?> getCompletion(int taskId, String occurrenceDateKey);

  /// Inserts or undeletes a completion for `(taskId, occurrenceDate)`.
  Future<TaskCompletionTableData> upsertCompletion(TaskCompletionTableCompanion companion);

  Future<void> softDeleteCompletion(int id);

  Stream<List<TaskCompletionTableData>> watchCompletionsForTask(int taskId);

  /// Watches all non-deleted occurrence completions (for agenda / habit strip).
  Stream<List<TaskCompletionTableData>> watchAllCompletions();
}

class TaskLocalDataSourceImpl implements ITaskLocalDataSource {
  TaskLocalDataSourceImpl(this._db);

  final AppDatabase _db;
  final _log = LogService.instance;

  @override
  Future<List<TaskTableData>> getTasksByProjectId(int projectId) async {
    try {
      return await (_db.select(
        _db.taskTable,
      )..where((t) => t.projectId.equals(projectId) & t.deletedAt.isNull())).get();
    } catch (e, st) {
      _log.error('getTasksByProjectId failed', tag: 'TaskLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<TaskTableData?> getTaskById(int id) async {
    try {
      return await (_db.select(_db.taskTable)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    } catch (e, st) {
      _log.error('getTaskById failed', tag: 'TaskLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<List<TaskTableData>> getSubtasks(int parentTaskId) async {
    try {
      return await (_db.select(
        _db.taskTable,
      )..where((t) => t.parentTaskId.equals(parentTaskId) & t.deletedAt.isNull())).get();
    } catch (e, st) {
      _log.error('getSubtasks failed', tag: 'TaskLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<List<TaskTableData>> getTasksWithDeadlines() async {
    try {
      return await (_db.select(_db.taskTable)..where(
            (t) =>
                (t.endDate.isNotNull() | t.recurrenceRule.isNotNull()) &
                t.status.equalsValue(TaskStatus.done).not() &
                t.deletedAt.isNull(),
          ))
          .get();
    } catch (e, st) {
      _log.error('getTasksWithDeadlines failed', tag: 'TaskLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<int> createTask(TaskTableCompanion companion) async {
    try {
      return await _db.into(_db.taskTable).insert(companion);
    } catch (e, st) {
      _log.error('createTask failed', tag: 'TaskLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> updateTask(TaskTableCompanion companion) async {
    try {
      await (_db.update(_db.taskTable)..where((t) => t.id.equals(companion.id.value))).write(companion);
    } catch (e, st) {
      _log.error('updateTask failed', tag: 'TaskLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(int id) async {
    // Soft-delete the task, all descendants, their completions, and sessions.
    try {
      await _db.transaction(() async {
        final now = DateTime.now();
        final idsToDelete = await _collectDescendantIds(id);
        idsToDelete.add(id);

        await (_db.update(_db.focusSessionTable)..where((t) => t.taskId.isIn(idsToDelete) & t.deletedAt.isNull()))
            .write(FocusSessionTableCompanion(deletedAt: Value(now)));

        await (_db.update(_db.taskCompletionTable)..where((t) => t.taskId.isIn(idsToDelete) & t.deletedAt.isNull()))
            .write(TaskCompletionTableCompanion(deletedAt: Value(now), updatedAt: Value(now)));

        await (_db.update(_db.taskTagTable)..where((t) => t.taskId.isIn(idsToDelete) & t.deletedAt.isNull())).write(
          TaskTagTableCompanion(deletedAt: Value(now), updatedAt: Value(now)),
        );

        await (_db.update(_db.taskTable)..where((t) => t.id.isIn(idsToDelete) & t.deletedAt.isNull())).write(
          TaskTableCompanion(deletedAt: Value(now), updatedAt: Value(now)),
        );
      });
    } catch (e, st) {
      _log.error('deleteTask failed', tag: 'TaskLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// BFS collect of all descendant task ids under [rootId].
  Future<List<int>> _collectDescendantIds(int rootId) async {
    final result = <int>[];
    var frontier = [rootId];
    while (frontier.isNotEmpty) {
      final children =
          await (_db.selectOnly(_db.taskTable)
                ..addColumns([_db.taskTable.id])
                ..where(_db.taskTable.parentTaskId.isIn(frontier) & _db.taskTable.deletedAt.isNull()))
              .map((row) => row.read(_db.taskTable.id)!)
              .get();
      result.addAll(children);
      frontier = children;
    }
    return result;
  }

  @override
  Stream<List<TaskTableData>> watchTasksByProjectId(int projectId) {
    return (_db.select(_db.taskTable)..where((t) => t.projectId.equals(projectId) & t.deletedAt.isNull())).watch();
  }

  @override
  Stream<List<TaskTableData>> watchTasksWithDeadlines() {
    return (_db.select(_db.taskTable)
          ..where(
            (t) =>
                (t.endDate.isNotNull() | t.recurrenceRule.isNotNull()) &
                t.status.equalsValue(TaskStatus.done).not() &
                t.deletedAt.isNull(),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.endDate)]))
        .watch();
  }

  @override
  Stream<List<TaskTableData>> watchFilteredTasks({
    required int projectId,
    String searchQuery = '',
    TaskSortCriteria sortCriteria = TaskSortCriteria.recentlyModified,
    TaskSortOrder sortOrder = TaskSortOrder.none,
    TaskPriority? priorityFilter,
    TaskStatus? statusFilter,
  }) {
    final query = _db.select(_db.taskTable)..where((t) => t.projectId.equals(projectId) & t.deletedAt.isNull());

    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      query.where((t) => t.title.lower().like('%$q%') | t.description.lower().like('%$q%'));
    }

    if (priorityFilter != null) {
      query.where((t) => t.priority.equalsValue(priorityFilter));
    }

    if (statusFilter != null) {
      query.where((t) => t.status.equalsValue(statusFilter));
    }

    if (sortOrder != TaskSortOrder.none) {
      final mode = sortOrder == TaskSortOrder.ascending ? OrderingMode.asc : OrderingMode.desc;
      query.orderBy([
        (t) {
          switch (sortCriteria) {
            case TaskSortCriteria.recentlyModified:
              return OrderingTerm(expression: t.updatedAt, mode: mode);
            case TaskSortCriteria.deadline:
              return OrderingTerm(expression: t.endDate, mode: mode);
            case TaskSortCriteria.priority:
              return OrderingTerm(expression: t.priority, mode: mode);
            case TaskSortCriteria.title:
              return OrderingTerm(expression: t.title, mode: mode);
            case TaskSortCriteria.createdDate:
              return OrderingTerm(expression: t.createdAt, mode: mode);
          }
        },
      ]);
    } else {
      // Default: recently modified descending
      query.orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    }

    return query.watch();
  }

  @override
  Stream<List<TaskTableData>> watchAllFilteredTasks({
    String searchQuery = '',
    AllTasksSortCriteria sortCriteria = AllTasksSortCriteria.recentlyModified,
    AllTasksSortOrder sortOrder = AllTasksSortOrder.none,
    TaskPriority? priorityFilter,
    TaskStatus? statusFilter,
    TaskCompletionFilter completionFilter = TaskCompletionFilter.all,
  }) {
    final query = _db.select(_db.taskTable)..where((t) => t.depth.equals(0) & t.deletedAt.isNull());

    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      query.where((t) => t.title.lower().like('%$q%') | t.description.lower().like('%$q%'));
    }

    if (priorityFilter != null) {
      query.where((t) => t.priority.equalsValue(priorityFilter));
    }

    if (statusFilter != null) {
      query.where((t) => t.status.equalsValue(statusFilter));
    }

    switch (completionFilter) {
      case TaskCompletionFilter.completed:
        query.where((t) => t.status.equalsValue(TaskStatus.done));
      case TaskCompletionFilter.incomplete:
        query.where((t) => t.status.equalsValue(TaskStatus.done).not());
      case TaskCompletionFilter.all:
        break;
    }

    if (sortOrder != AllTasksSortOrder.none) {
      final mode = sortOrder == AllTasksSortOrder.ascending ? OrderingMode.asc : OrderingMode.desc;
      query.orderBy([
        (t) {
          switch (sortCriteria) {
            case AllTasksSortCriteria.recentlyModified:
              return OrderingTerm(expression: t.updatedAt, mode: mode);
            case AllTasksSortCriteria.deadline:
              return OrderingTerm(expression: t.endDate, mode: mode);
            case AllTasksSortCriteria.priority:
              return OrderingTerm(expression: t.priority, mode: mode);
            case AllTasksSortCriteria.title:
              return OrderingTerm(expression: t.title, mode: mode);
            case AllTasksSortCriteria.createdDate:
              return OrderingTerm(expression: t.createdAt, mode: mode);
          }
        },
      ]);
    } else {
      query.orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    }

    return query.watch();
  }

  @override
  Future<List<TaskCompletionTableData>> getCompletionsForTask(int taskId) async {
    try {
      return await (_db.select(_db.taskCompletionTable)
            ..where((t) => t.taskId.equals(taskId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.occurrenceDate)]))
          .get();
    } catch (e, st) {
      _log.error('getCompletionsForTask failed', tag: 'TaskLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<TaskCompletionTableData?> getCompletion(int taskId, String occurrenceDateKey) async {
    try {
      return await (_db.select(_db.taskCompletionTable)
            ..where((t) => t.taskId.equals(taskId) & t.occurrenceDate.equals(occurrenceDateKey) & t.deletedAt.isNull()))
          .getSingleOrNull();
    } catch (e, st) {
      _log.error('getCompletion failed', tag: 'TaskLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<TaskCompletionTableData> upsertCompletion(TaskCompletionTableCompanion companion) async {
    try {
      return await _db.transaction(() async {
        final taskId = companion.taskId.value;
        final dateKey = companion.occurrenceDate.value;

        // Prefer an existing live row (idempotent complete).
        final live =
            await (_db.select(_db.taskCompletionTable)
                  ..where((t) => t.taskId.equals(taskId) & t.occurrenceDate.equals(dateKey) & t.deletedAt.isNull()))
                .getSingleOrNull();
        if (live != null) return live;

        // Revive a soft-deleted row for the same occurrence if present.
        final tombstoned =
            await (_db.select(_db.taskCompletionTable)
                  ..where((t) => t.taskId.equals(taskId) & t.occurrenceDate.equals(dateKey) & t.deletedAt.isNotNull()))
                .getSingleOrNull();
        if (tombstoned != null) {
          final now = DateTime.now();
          await (_db.update(_db.taskCompletionTable)..where((t) => t.id.equals(tombstoned.id))).write(
            TaskCompletionTableCompanion(
              completedAt: companion.completedAt.present ? companion.completedAt : Value(now),
              updatedAt: companion.updatedAt.present ? companion.updatedAt : Value(now),
              deletedAt: const Value(null),
            ),
          );
          return (await (_db.select(_db.taskCompletionTable)..where((t) => t.id.equals(tombstoned.id))).getSingle());
        }

        final id = await _db.into(_db.taskCompletionTable).insert(companion);
        return (await (_db.select(_db.taskCompletionTable)..where((t) => t.id.equals(id))).getSingle());
      });
    } catch (e, st) {
      _log.error('upsertCompletion failed', tag: 'TaskLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> softDeleteCompletion(int id) async {
    try {
      final now = DateTime.now();
      await (_db.update(_db.taskCompletionTable)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).write(
        TaskCompletionTableCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
    } catch (e, st) {
      _log.error('softDeleteCompletion failed', tag: 'TaskLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<List<TaskCompletionTableData>> watchCompletionsForTask(int taskId) {
    return (_db.select(_db.taskCompletionTable)
          ..where((t) => t.taskId.equals(taskId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.occurrenceDate)]))
        .watch();
  }

  @override
  Stream<List<TaskCompletionTableData>> watchAllCompletions() {
    return (_db.select(_db.taskCompletionTable)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.occurrenceDate)]))
        .watch();
  }
}
