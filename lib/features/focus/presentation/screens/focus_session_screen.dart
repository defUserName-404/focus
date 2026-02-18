import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/common/widgets/marquee_text.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/focus_progress.dart';
import '../providers/ambience_mute_provider.dart';
import '../providers/focus_progress_provider.dart';
import '../providers/focus_screen_provider.dart';
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
  void _onCompleteTask() async {
    await ref.read(focusTimerProvider.notifier).completeTaskAndSession();
    if (mounted) {
      ref.read(focusScreenProvider.notifier).showCompletion();
    }
  }

  void _onAnimationDone() {
    final state = ref.read(focusScreenProvider);
    if (mounted && !state.hasPopped) {
      ref.read(focusScreenProvider.notifier).markAsPopped();
      ref.read(focusTimerProvider.notifier).clearCompletedSession();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(focusProgressProvider);
    final session = ref.watch(focusTimerProvider);
    final screenState = ref.watch(focusScreenProvider);

    // Auto-pop when the session is cleared (e.g. completeSessionEarly,
    // cancelSession). Skip if the completion animation is playing.
    // Guard with hasPopped to prevent multiple pops (which would pop the
    // underlying shell route and cause a black screen).
    if (session == null && !screenState.showCompletion && !screenState.hasPopped) {
      // Mark as popped immediately to prevent re-entry
      // We can't update state during build easily, but we can schedule it or just rely on the local check for this frame?
      // Actually, updating the provider here might trigger a rebuild which is bad during build.
      // But we are popping, so the widget will unmount.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(focusScreenProvider.notifier).markAsPopped();
          Navigator.of(context).pop();
        }
      });
      return const FScaffold(child: Center(child: CircularProgressIndicator()));
    }

    return PopScope(
      canPop: true,
      child: GestureDetector(
        onTap: () => ref.read(focusScreenProvider.notifier).onUserInteraction(),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            FScaffold(
              header: FHeader.nested(prefixes: [FHeaderAction.back(onPress: () => Navigator.of(context).pop())]),
              child: Center(
                child: Column(
                  children: [
                    AnimatedOpacity(
                      duration: AppConstants.animation.medium,
                      opacity: screenState.isControlsVisible ? 1.0 : 0.0,
                      child: const FocusTaskInfo(),
                    ),
                    SizedBox(height: AppConstants.spacing.small),
                    // Phase indicator with animated transition
                    if (progress != null) ...[
                      (() {
                        final label = progress.isFocusPhase ? 'FOCUS' : 'BREAK';
                        return AnimatedOpacity(
                          duration: AppConstants.animation.medium,
                          opacity: screenState.isControlsVisible ? 1.0 : 0.0,
                          child: AnimatedSwitcher(
                            duration: AppConstants.animation.medium,
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            child: FBadge(key: ValueKey(label), style: FBadgeStyle.secondary(), child: Text(label)),
                          ),
                        );
                      })(),
                    ],
                    SizedBox(height: AppConstants.spacing.regular),
                    // Ambience sound marquee + mute button
                    AnimatedOpacity(
                      duration: AppConstants.animation.medium,
                      opacity: screenState.isControlsVisible ? 1.0 : 0.0,
                      child: const _AmbienceMarqueeRow(),
                    ),
                    const Spacer(flex: 1),
                    const CircularTimer(),
                    SizedBox(height: AppConstants.spacing.extraLarge),
                    _FocusControlsWithCallback(
                      onCompleteTask: _onCompleteTask,
                      controlsVisible: screenState.isControlsVisible,
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),

            // Completion animation overlay
            if (screenState.showCompletion) CompletionOverlay(onDismiss: _onAnimationDone),
          ],
        ),
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
  final bool controlsVisible;

  const _FocusControlsWithCallback({required this.onCompleteTask, required this.controlsVisible});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(focusProgressProvider);
    final session = ref.watch(focusTimerProvider);
    final isQuickSession = session?.isQuickSession ?? false;

    if (progress == null) return const SizedBox.shrink();

    final notifier = ref.read(focusTimerProvider.notifier);
    final showTransport = !progress.isIdle && !progress.isCompleted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //  Transport controls (stack)
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
                  opacity: (showTransport && controlsVisible) ? 1.0 : 0.0,
                  child: AnimatedScale(
                    duration: AppConstants.animation.medium,
                    scale: showTransport ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: !showTransport || !controlsVisible,
                      child: _CircleIconButton(
                        icon: FIcons.square,
                        size: 44,
                        color: context.colors.mutedForeground,
                        backgroundColor: context.colors.muted,
                        onTap: () {
                          ref.read(focusScreenProvider.notifier).onUserInteraction();
                          _confirmEnd(context, ref);
                        },
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
                  opacity: (showTransport && controlsVisible) ? 1.0 : 0.0,
                  child: AnimatedScale(
                    duration: AppConstants.animation.medium,
                    scale: showTransport ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: !showTransport || !controlsVisible,
                      child: _CircleIconButton(
                        icon: FIcons.skipForward,
                        size: 44,
                        color: context.colors.mutedForeground,
                        backgroundColor: context.colors.muted,
                        onTap: () {
                          ref.read(focusScreenProvider.notifier).onUserInteraction();
                          notifier.skipToNextPhase();
                        },
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
                onTap: () {
                  // Always register interaction so controls wake up
                  ref.read(focusScreenProvider.notifier).onUserInteraction();
                  notifier.togglePlayPause();
                },
              ),
            ],
          ),
        ),

        SizedBox(height: AppConstants.spacing.extraLarge),

        AnimatedOpacity(
          duration: AppConstants.animation.medium,
          opacity: controlsVisible ? 1.0 : 0.0,
          child: AnimatedSwitcher(
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
                    onPress: () {
                      ref.read(focusScreenProvider.notifier).onUserInteraction();
                      if (isQuickSession) {
                        ref.read(focusTimerProvider.notifier).completeSessionEarly();
                      } else {
                        onCompleteTask();
                      }
                    },
                    prefix: Icon(isQuickSession ? FIcons.check : FIcons.checkCheck),
                    child: Text(isQuickSession ? 'End Session' : 'Complete Task'),
                  )
                : const SizedBox.shrink(key: ValueKey('empty-btn')),
          ),
        ),
      ],
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
              // No explicit pop — auto-pop in build() handles it
              // when cancelSession sets state to null.
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

/// Row showing a scrolling ambience sound name and a mute/unmute button.
///
/// All logic lives in [ambienceMarqueeProvider]; this widget only renders.
class _AmbienceMarqueeRow extends ConsumerWidget {
  const _AmbienceMarqueeRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ambienceMarqueeProvider);

    if (state.isHidden) return const SizedBox.shrink();

    final dimmedColor = context.colors.mutedForeground;
    final activeColor = context.colors.foreground;
    final color = state.isDimmed ? dimmedColor : activeColor;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.large),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FIcons.music2, size: 14, color: color),
          SizedBox(width: AppConstants.spacing.small),
          Flexible(
            child: SizedBox(
              height: 20,
              child: MarqueeText(
                text: state.soundLabel!,
                isAnimating: state.isScrolling,
                style: context.typography.sm.copyWith(color: color),
              ),
            ),
          ),
          SizedBox(width: AppConstants.spacing.regular),
          GestureDetector(
            onTap: () => ref.read(ambienceMuteProvider.notifier).toggle(),
            child: AnimatedSwitcher(
              duration: AppConstants.animation.short,
              child: Icon(
                state.isMuted ? FIcons.volumeOff : FIcons.volume2,
                key: ValueKey(state.isMuted),
                size: 20,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
