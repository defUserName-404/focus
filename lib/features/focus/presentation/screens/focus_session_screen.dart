import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/focus_session_provider.dart';
import '../widgets/circular_timer.dart';
import '../widgets/completion_overlay.dart';
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
                  const FocusTaskInfo(),
                  SizedBox(height: AppConstants.spacing.small),
                  // Phase indicator with animated transition
                  progressAsync.when(
                    skipLoadingOnReload: true,
                    data: (progress) {
                      if (progress == null) return const SizedBox.shrink();
                      final label = progress.isFocusPhase ? 'FOCUS' : 'BREAK';
                      return AnimatedSwitcher(
                        duration: AppConstants.animation.medium,
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: FBadge(key: ValueKey(label), style: FBadgeStyle.secondary(), child: Text(label)),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  const Spacer(flex: 1),
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

/// Wraps focus controls and intercepts the "Complete Task" action
/// to show the completion animation first.
///
/// Uses [AnimatedSwitcher] for smooth transitions when session state
/// changes (idle ↔ running ↔ paused ↔ break).
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
                  // Left: Stop button — animated in/out
                  AnimatedPositioned(
                    duration: AppConstants.animation.medium,
                    curve: Curves.easeInOut,
                    left: showTransport ? 0 : 98,
                    // slide toward center when hidden
                    top: -8,
                    child: AnimatedOpacity(
                      duration: AppConstants.animation.medium,
                      opacity: showTransport ? 1.0 : 0.0,
                      child: AnimatedScale(
                        duration: AppConstants.animation.medium,
                        scale: showTransport ? 1.0 : 0.0,
                        child: IgnorePointer(
                          ignoring: !showTransport,
                          child: _CircleIconButton(
                            icon: FIcons.square,
                            size: 44,
                            color: context.colors.mutedForeground,
                            backgroundColor: context.colors.muted,
                            onTap: () => _confirmEnd(context, ref),
                          ),
                        ),
                      ),
                    ),
                  ),

                  AnimatedPositioned(
                    duration: AppConstants.animation.medium,
                    curve: Curves.easeInOut,
                    right: showTransport ? 0 : 98,
                    // slide toward center when hidden
                    top: -8,
                    child: AnimatedOpacity(
                      duration: AppConstants.animation.medium,
                      opacity: showTransport ? 1.0 : 0.0,
                      child: AnimatedScale(
                        duration: AppConstants.animation.medium,
                        scale: showTransport ? 1.0 : 0.0,
                        child: IgnorePointer(
                          ignoring: !showTransport,
                          child: _CircleIconButton(
                            icon: FIcons.skipForward,
                            size: 44,
                            color: context.colors.mutedForeground,
                            backgroundColor: context.colors.muted,
                            onTap: () => notifier.skipToNextPhase(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Center: Play / Pause (largest) — icon crossfades
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

            AnimatedSwitcher(
              duration: AppConstants.animation.medium,
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
                  child: child,
                ),
              ),
              child: showTransport
                  ? FButton(
                      key: const ValueKey('complete-btn'),
                      style: FButtonStyle.outline(),
                      onPress: onCompleteTask,
                      prefix: const Icon(FIcons.checkCheck),
                      child: const Text('Complete Task'),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty-btn')),
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
          FButton(onPress: () => Navigator.pop(ctx), style: FButtonStyle.ghost(), child: const Text('Keep going')),
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

/// A circular icon button with animated icon crossfade.
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
        curve: Curves.easeInOut,
        width: size,
        height: size,
        decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
        child: Center(
          child: AnimatedSwitcher(
            duration: AppConstants.animation.short,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(icon, key: ValueKey(icon), color: color, size: size * 0.4),
          ),
        ),
      ),
    );
  }
}
