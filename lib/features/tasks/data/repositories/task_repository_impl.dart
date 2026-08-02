import '../../domain/entities/all_tasks_filter_state.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_completion.dart';
import '../../domain/entities/task_extensions.dart';
import '../../domain/entities/task_filter_state.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../mappers/task_completion_extensions.dart';
import '../mappers/task_extensions.dart';
import '../../../../core/services/data_change_bus.dart';
import '../../../../core/services/log_service.dart';

final _log = LogService.instance;

class TaskRepositoryImpl implements ITaskRepository {
  final ITaskLocalDataSource _local;
  final DataChangeBus? _dataChangeBus;

  TaskRepositoryImpl(this._local, [this._dataChangeBus]);

  void _emitChange() => _dataChangeBus?.notify();

  @override
  Future<List<Task>> getTasksByProjectId(int projectId) async {
    final rows = await _local.getTasksByProjectId(projectId);
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<Task?> getTaskById(int id) async {
    final row = await _local.getTaskById(id);
    return row?.toDomain();
  }

  @override
  Future<List<Task>> getTasksWithDeadlines() async {
    final rows = await _local.getTasksWithDeadlines();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<List<Task>> getSubtasks(int parentTaskId) async {
    final rows = await _local.getSubtasks(parentTaskId);
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<Task> createTask(Task task) async {
    try {
      final companion = task.toCompanion();
      final id = await _local.createTask(companion);
      _log.debug('Task created (id=$id)', tag: 'TaskRepository');
      _emitChange();
      return task.copyWith(id: id);
    } catch (e, st) {
      _log.error('Failed to create task', tag: 'TaskRepository', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    try {
      final companion = task.toCompanion();
      await _local.updateTask(companion);
      _emitChange();
    } catch (e, st) {
      _log.error('Failed to update task (id=${task.id})', tag: 'TaskRepository', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(int id) async {
    try {
      await _local.deleteTask(id);
      _emitChange();
    } catch (e, st) {
      _log.error('Failed to delete task (id=$id)', tag: 'TaskRepository', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<List<Task>> watchTasksByProjectId(int projectId) {
    return _local.watchTasksByProjectId(projectId).map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Stream<List<Task>> watchTasksWithDeadlines() {
    return _local.watchTasksWithDeadlines().map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Stream<List<Task>> watchFilteredTasks({
    required int projectId,
    String searchQuery = '',
    TaskSortCriteria sortCriteria = TaskSortCriteria.recentlyModified,
    TaskSortOrder sortOrder = TaskSortOrder.none,
    TaskPriority? priorityFilter,
    TaskStatus? statusFilter,
    TaskCompletionFilter completionFilter = TaskCompletionFilter.all,
  }) {
    return _local
        .watchFilteredTasks(
          projectId: projectId,
          searchQuery: searchQuery,
          sortCriteria: sortCriteria,
          sortOrder: sortOrder,
          priorityFilter: priorityFilter,
          statusFilter: statusFilter,
          completionFilter: completionFilter,
        )
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Stream<List<Task>> watchAllFilteredTasks({
    String searchQuery = '',
    AllTasksSortCriteria sortCriteria = AllTasksSortCriteria.recentlyModified,
    AllTasksSortOrder sortOrder = AllTasksSortOrder.none,
    TaskPriority? priorityFilter,
    TaskStatus? statusFilter,
    TaskCompletionFilter completionFilter = TaskCompletionFilter.all,
  }) {
    return _local
        .watchAllFilteredTasks(
          searchQuery: searchQuery,
          sortCriteria: sortCriteria,
          sortOrder: sortOrder,
          priorityFilter: priorityFilter,
          statusFilter: statusFilter,
          completionFilter: completionFilter,
        )
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Future<List<TaskCompletion>> getCompletionsForTask(int taskId) async {
    final rows = await _local.getCompletionsForTask(taskId);
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<TaskCompletion?> getCompletion(int taskId, DateTime occurrenceDate) async {
    final row = await _local.getCompletion(taskId, occurrenceDateKey(occurrenceDate));
    return row?.toDomain();
  }

  @override
  Future<TaskCompletion> upsertCompletion(TaskCompletion completion) async {
    final row = await _local.upsertCompletion(completion.toCompanion());
    _emitChange();
    return row.toDomain();
  }

  @override
  Future<void> softDeleteCompletion(int id) async {
    await _local.softDeleteCompletion(id);
    _emitChange();
  }

  @override
  Stream<List<TaskCompletion>> watchCompletionsForTask(int taskId) {
    return _local.watchCompletionsForTask(taskId).map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Stream<List<TaskCompletion>> watchAllCompletions() {
    return _local.watchAllCompletions().map((rows) => rows.map((r) => r.toDomain()).toList());
  }
}
