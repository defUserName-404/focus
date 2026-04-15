part of 'task_provider.dart';

@Riverpod(keepAlive: true)
Future<Task> taskById(Ref ref, String taskId) async {
  final repository = ref.watch(taskRepositoryProvider);
  final task = await repository.getTaskById(int.parse(taskId));
  if (task == null) throw Exception('Task not found: $taskId');
  return task;
}
