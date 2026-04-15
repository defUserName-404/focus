part of 'task_provider.dart';

@Riverpod(keepAlive: true)
class TaskNotifier extends _$TaskNotifier {
  late final TaskService _service;

  @override
  AsyncValue<List<Task>> build(String projectId) {
    _service = getIt<TaskService>();
    _loadTasks(projectId);
    return const AsyncValue.loading();
  }

  Future<void> _loadTasks(String projectId) async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _service.getTasksByProjectId(int.parse(projectId));
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Task> createTask({
    required String projectId,
    int? parentTaskId,
    required String title,
    TaskPriority? priority,
    TaskReminderMode reminderMode = TaskReminderMode.smart,
    int? customReminderMinutesBefore,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    required int depth,
  }) async {
    final result = await _service.createTask(
      projectId: int.parse(projectId),
      parentTaskId: parentTaskId,
      title: title,
      description: description,
      priority: priority ?? TaskPriority.medium,
      reminderMode: reminderMode,
      customReminderMinutesBefore: customReminderMinutesBefore,
      startDate: startDate,
      endDate: endDate,
      depth: depth,
    );
    switch (result) {
      case Success(:final value):
        await _loadTasks(projectId);
        return value;
      case Failure(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
        throw failure;
    }
  }

  Future<void> updateTask(Task task) async {
    final result = await _service.updateTask(task);
    switch (result) {
      case Success():
        await _loadTasks(task.projectId.toString());
      case Failure(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  Future<void> deleteTask(int id, String projectId) async {
    final result = await _service.deleteTask(id);
    switch (result) {
      case Success():
        await _loadTasks(projectId);
      case Failure(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final result = await _service.toggleTaskCompletion(task);
    switch (result) {
      case Success():
        await _loadTasks(task.projectId.toString());
      case Failure(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }
}
