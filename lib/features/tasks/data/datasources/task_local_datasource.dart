import 'package:drift/drift.dart';
import 'package:focus/core/services/db_service.dart';
import 'package:focus/features/tasks/domain/entities/task_priority.dart';
import 'package:focus/features/tasks/presentation/providers/task_filter_state.dart';

import '../../domain/entities/all_tasks_filter_state.dart';

abstract class ITaskLocalDataSource {
  Future<List<TaskTableData>> getTasksByProjectId(BigInt projectId);
  Future<TaskTableData?> getTaskById(BigInt id);
  Future<List<TaskTableData>> getSubtasks(BigInt parentTaskId);
  Future<int> createTask(TaskTableCompanion companion);
  Future<void> updateTask(TaskTableCompanion companion);
  Future<void> deleteTask(BigInt id);
  Stream<List<TaskTableData>> watchTasksByProjectId(BigInt projectId);
  Stream<List<TaskTableData>> watchFilteredTasks({
    required BigInt projectId,
    String searchQuery,
    TaskSortCriteria sortCriteria,
    TaskSortOrder sortOrder,
    TaskPriority? priorityFilter,
  });

  /// Watch ALL tasks across all projects with filtering/sorting.
  Stream<List<TaskTableData>> watchAllFilteredTasks({
    String searchQuery,
    AllTasksSortCriteria sortCriteria,
    AllTasksSortOrder sortOrder,
    TaskPriority? priorityFilter,
    TaskCompletionFilter completionFilter,
  });
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
    await (_db.update(_db.taskTable)..where((t) => t.id.equals(companion.id.value))).write(companion);
  }

  @override
  Future<void> deleteTask(BigInt id) async {
    // Cascade: delete child tasks first
    final children = await (_db.select(_db.taskTable)..where((t) => t.parentTaskId.equals(id))).get();
    for (final child in children) {
      await deleteTask(child.id);
    }
    await (_db.delete(_db.taskTable)..where((t) => t.id.equals(id))).go();
  }

  @override
  Stream<List<TaskTableData>> watchTasksByProjectId(BigInt projectId) {
    return (_db.select(_db.taskTable)..where((t) => t.projectId.equals(projectId))).watch();
  }

  @override
  Stream<List<TaskTableData>> watchFilteredTasks({
    required BigInt projectId,
    String searchQuery = '',
    TaskSortCriteria sortCriteria = TaskSortCriteria.recentlyModified,
    TaskSortOrder sortOrder = TaskSortOrder.none,
    TaskPriority? priorityFilter,
  }) {
    final query = _db.select(_db.taskTable)..where((t) => t.projectId.equals(projectId));

    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      query.where((t) => t.title.lower().like('%$q%') | t.description.lower().like('%$q%'));
    }

    if (priorityFilter != null) {
      query.where((t) => t.priority.equalsValue(priorityFilter));
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
    TaskCompletionFilter completionFilter = TaskCompletionFilter.all,
  }) {
    final query = _db.select(_db.taskTable)..where((t) => t.depth.equals(0)); // root tasks only

    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      query.where((t) => t.title.lower().like('%$q%') | t.description.lower().like('%$q%'));
    }

    if (priorityFilter != null) {
      query.where((t) => t.priority.equalsValue(priorityFilter));
    }

    switch (completionFilter) {
      case TaskCompletionFilter.completed:
        query.where((t) => t.isCompleted.equals(true));
      case TaskCompletionFilter.incomplete:
        query.where((t) => t.isCompleted.equals(false));
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
}
