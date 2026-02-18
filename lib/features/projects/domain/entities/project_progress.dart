class ProjectProgress {
  final double progress;
  final int percent;
  final String label;

  const ProjectProgress({required this.progress, required this.percent, required this.label});

  factory ProjectProgress.empty() => const ProjectProgress(progress: 0.0, percent: 0, label: '0 of 0 tasks');
}
