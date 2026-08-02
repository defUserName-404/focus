import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/constants/app_constants.dart';
import '../providers/focus_progress_provider.dart';
import '../providers/focus_screen_provider.dart';
import '../providers/focus_session_provider.dart';

/// Footer action to end a quick session or complete the linked task.
class FocusEndSessionButton extends ConsumerWidget {
  final VoidCallback onCompleteTask;
  final bool controlsVisible;

  const FocusEndSessionButton({super.key, required this.onCompleteTask, required this.controlsVisible});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(focusProgressProvider);
    final session = ref.watch(focusTimerProvider);
    final isQuickSession = session?.isQuickSession ?? false;

    if (progress == null) return const SizedBox.shrink();

    final showAction = !progress.isIdle && !progress.isCompleted;

    return AnimatedOpacity(
      duration: AppConstants.animation.medium,
      opacity: controlsVisible ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !controlsVisible || !showAction,
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
          child: showAction
              ? Padding(
                  key: const ValueKey('complete-btn'),
                  padding: EdgeInsets.all(AppConstants.spacing.large),
                  child: FButton(
                    variant: .outline,
                    onPress: () {
                      ref.read(focusScreenProvider.notifier).onUserInteraction();
                      if (isQuickSession) {
                        ref.read(focusTimerProvider.notifier).completeSessionEarly();
                      } else {
                        onCompleteTask();
                      }
                    },
                    prefix: Icon(isQuickSession ? FLucideIcons.check : FLucideIcons.checkCheck),
                    child: Text(isQuickSession ? 'End Session' : 'Complete Task'),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('empty-btn')),
        ),
      ),
    );
  }
}
