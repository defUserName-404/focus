import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../providers/focus_progress_provider.dart';
import '../providers/focus_screen_provider.dart';
import '../providers/focus_session_provider.dart';
import '../widgets/ambience_marquee_row.dart';
import '../widgets/circular_timer.dart';
import '../widgets/completion_overlay.dart';
import '../widgets/focus_task_info.dart';
import '../widgets/focus_controls_with_callback.dart';

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
      context.pop();
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
          context.pop();
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
              header: FHeader.nested(prefixes: [FHeaderAction.back(onPress: () => context.pop())]),
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
                      child: const AmbienceMarqueeRow(),
                    ),
                    const Spacer(flex: 1),
                    const CircularTimer(),
                    SizedBox(height: AppConstants.spacing.extraLarge),
                    FocusControlsWithCallback(
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
