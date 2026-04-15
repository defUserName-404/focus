import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/focus_progress.dart';
import '../providers/focus_progress_provider.dart';
import '../providers/focus_screen_provider.dart';
import '../providers/focus_session_provider.dart';
import 'focus_circle_icon_button.dart';

class FocusControlsWithCallback extends ConsumerWidget {
  final VoidCallback onCompleteTask;
  final bool controlsVisible;

  const FocusControlsWithCallback({
    super.key,
    required this.onCompleteTask,
    required this.controlsVisible,
  });

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
        SizedBox(
          width: 240,
          height: 72,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              AnimatedPositioned(
                duration: AppConstants.animation.medium,
                curve: Curves.easeInOut,
                left: showTransport ? 0 : 98,
                top: -8,
                child: AnimatedOpacity(
                  duration: AppConstants.animation.medium,
                  opacity: (showTransport && controlsVisible) ? 1.0 : 0.0,
                  child: AnimatedScale(
                    duration: AppConstants.animation.medium,
                    scale: showTransport ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: !showTransport || !controlsVisible,
                      child: FocusCircleIconButton(
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
                top: -8,
                child: AnimatedOpacity(
                  duration: AppConstants.animation.medium,
                  opacity: (showTransport && controlsVisible) ? 1.0 : 0.0,
                  child: AnimatedScale(
                    duration: AppConstants.animation.medium,
                    scale: showTransport ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: !showTransport || !controlsVisible,
                      child: FocusCircleIconButton(
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
              FocusCircleIconButton(
                icon: _centerIcon(progress),
                size: 64,
                color: context.colors.primaryForeground,
                backgroundColor: context.colors.primary,
                onTap: () {
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
          FButton(onPress: () => ctx.pop(), style: FButtonStyle.ghost(), child: const Text('Keep going')),
          FButton(
            onPress: () {
              ctx.pop();
              ref.read(focusTimerProvider.notifier).cancelSession();
            },
            style: FButtonStyle.destructive(),
            child: const Text('End session'),
          ),
        ],
      ),
    );
  }
}
