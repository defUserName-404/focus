import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/focus_session_provider.dart';
import '../widgets/circular_timer.dart';
import '../widgets/completion_overlay.dart';
import '../widgets/focus_controls.dart';
import '../widgets/focus_task_info.dart';

class FocusSessionScreen extends ConsumerStatefulWidget {
  const FocusSessionScreen({super.key});

  @override
  ConsumerState<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends ConsumerState<FocusSessionScreen> {
  bool _showCompletion = false;

  void _onCompleteTask() async {
    await ref.read(focusTimerProvider.notifier).completeTaskAndSession();
    if (mounted) {
      setState(() => _showCompletion = true);
    }
  }

  void _onAnimationDone() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(focusProgressProvider);
    final session = ref.watch(focusTimerProvider);

    if (session == null && !_showCompletion) {
      return const FScaffold(child: Center(child: Text('No active session')));
    }

    return PopScope(
      canPop: true,
      child: Stack(
        children: [
          FScaffold(
            header: FHeader.nested(
              title: const Text('Focus'),
              prefixes: [FHeaderAction.back(onPress: () => Navigator.of(context).pop())],
            ),
            child: Center(
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  const FocusTaskInfo(),
                  SizedBox(height: AppConstants.spacing.small),
                  // Phase indicator
                  progressAsync.when(
                    skipLoadingOnReload: true,
                    data: (progress) {
                      if (progress == null) return const SizedBox.shrink();
                      final label = progress.isFocusPhase ? 'Focus' : 'Break';
                      final color = progress.isFocusPhase ? context.colors.primary : context.colors.mutedForeground;
                      return FBadge(
                        child: Text(label, style: TextStyle(color: color)),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  const Spacer(flex: 2),
                  const CircularTimer(),
                  SizedBox(height: AppConstants.spacing.extraLarge),
                  _FocusControlsWithCallback(onCompleteTask: _onCompleteTask),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),

          // Completion animation overlay
          if (_showCompletion) CompletionOverlay(onDismiss: _onAnimationDone),
        ],
      ),
    );
  }
}

/// Wraps [FocusControls] but intercepts the "Complete Task" action
/// to show the completion animation first.
class _FocusControlsWithCallback extends ConsumerWidget {
  final VoidCallback onCompleteTask;

  const _FocusControlsWithCallback({required this.onCompleteTask});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(focusProgressProvider);

    return progressAsync.when(
      skipLoadingOnReload: true,
      data: (progress) {
        if (progress == null) return const SizedBox.shrink();

        final notifier = ref.read(focusTimerProvider.notifier);
        final showTransport = !progress.isIdle && !progress.isCompleted;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Transport controls (stack) ───────────────────────
            SizedBox(
              width: 240,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (showTransport)
                    Positioned(
                      left: 0,
                      top: -8,
                      child: _CircleIconButton(
                        icon: FIcons.square,
                        size: 44,
                        color: context.colors.mutedForeground,
                        backgroundColor: context.colors.muted,
                        onTap: () {
                          // Import focus commands for confirmEnd
                          _confirmEnd(context, ref);
                        },
                      ),
                    ),
                  if (showTransport)
                    Positioned(
                      right: 0,
                      top: -8,
                      child: _CircleIconButton(
                        icon: FIcons.skipForward,
                        size: 44,
                        color: context.colors.mutedForeground,
                        backgroundColor: context.colors.muted,
                        onTap: () => notifier.skipToNextPhase(),
                      ),
                    ),
                  _CircleIconButton(
                    icon: _centerIcon(progress),
                    size: 64,
                    color: context.colors.primaryForeground,
                    backgroundColor: context.colors.primary,
                    onTap: () => notifier.togglePlayPause(),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppConstants.spacing.extraLarge),

            // ── Complete Task ────────────────────────────────────
            if (!progress.isIdle && !progress.isCompleted)
              FButton(
                style: FButtonStyle.outline(),
                onPress: onCompleteTask,
                prefix: const Icon(FIcons.checkCheck),
                child: const Text('Complete Task'),
              ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  IconData _centerIcon(FocusProgress progress) {
    if (progress.isIdle) return FIcons.play;
    if (progress.isPaused) return FIcons.play;
    return FIcons.pause;
  }

  void _confirmEnd(BuildContext context, WidgetRef ref) {
    showFDialog(
      context: context,
      builder: (ctx, _, _) => FDialog(
        title: const Text('End session?'),
        body: const Text("This session will be saved but won't count as completed."),
        actions: [
          FButton(
            onPress: () => Navigator.pop(ctx),
            style: FButtonStyle.ghost(),
            child: const Text('Keep going'),
          ),
          FButton(
            onPress: () {
              Navigator.pop(ctx);
              ref.read(focusTimerProvider.notifier).cancelSession();
              Navigator.of(context).pop();
            },
            style: FButtonStyle.destructive(),
            child: const Text('End session'),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.size,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animation.medium,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(icon, color: color, size: size * 0.4),
        ),
      ),
    );
  }
}
