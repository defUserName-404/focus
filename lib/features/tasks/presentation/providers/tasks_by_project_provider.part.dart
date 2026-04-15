part of 'task_provider.dart';

@Riverpod(keepAlive: true)
Stream<List<Task>> tasksByProject(Ref ref, String projectId) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchTasksByProjectId(int.parse(projectId));
}
