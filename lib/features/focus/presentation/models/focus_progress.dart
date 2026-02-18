/// Computed progress data derived from the raw [FocusSession].
///
/// Provides formatted time, phase detection, and progress percentage
/// for the circular timer and other UI elements.
class FocusProgress {
  final double progress;
  final int remainingMinutes;
  final int remainingSeconds;
  final bool isFocusPhase;
  final bool isIdle;
  final bool isPaused;
  final bool isRunning;
  final bool isCompleted;

  const FocusProgress({
    required this.progress,
    required this.remainingMinutes,
    required this.remainingSeconds,
    required this.isFocusPhase,
    required this.isIdle,
    required this.isPaused,
    required this.isRunning,
    required this.isCompleted,
  });

  String get formattedTime =>
      '${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}
