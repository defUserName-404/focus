part of 'project_provider.dart';

@Riverpod(keepAlive: true)
Future<ProjectProgress> projectProgress(Ref ref, String projectId) async {
  final tasksAsync = ref.watch(tasksByProjectProvider(projectId));

  return tasksAsync.when(
    data: (tasks) async {
      if (tasks.isEmpty) return ProjectProgress.empty();
      return compute(_calculateProgress, tasks);
    },
    loading: () => ProjectProgress.empty(),
    error: (_, _) => ProjectProgress.empty(),
  );
}

ProjectProgress _calculateProgress(List<Task> tasks) {
  final total = tasks.length;
  final completed = tasks.where((t) => t.isCompleted == true).length;
  final progress = total > 0 ? completed / total : 0.0;
  final percent = (progress * 100).round();
  return ProjectProgress(progress: progress, percent: percent, label: '$completed of $total tasks');
}
