import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/constants/app_constants.dart';
import '../providers/focus_session_provider.dart';

/// Focus session controls: Play/Pause and Complete Task.
///
/// "Complete Task" marks both the session as completed and the task as done.
class FocusControls extends ConsumerWidget {
  const FocusControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(focusProgressProvider);

    return progressAsync.when(
      skipLoadingOnReload: true,
      data: (progress) {
        if (progress == null) return const SizedBox.shrink();

        final notifier = ref.read(focusTimerProvider.notifier);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Play / Pause ───────────────────────────────────────────
            if (progress.isPaused)
              FButton(
                onPress: () => notifier.resumeSession(),
                prefix: const Icon(FIcons.play),
                child: const Text('Resume'),
              )
            else if (progress.isRunning)
              FButton(
                onPress: () => notifier.pauseSession(),
                prefix: const Icon(FIcons.pause),
                child: const Text('Pause'),
              )
            else if (progress.isIdle)
              FButton(
                onPress: () => notifier.startTimer(),
                prefix: const Icon(FIcons.play),
                child: const Text('Start'),
              ),
            SizedBox(height: AppConstants.spacing.large),
            // ── Complete Task (completes session + task) ────────────────
            if (!progress.isIdle && !progress.isCompleted)
              FButton(
                style: FButtonStyle.outline(),
                onPress: () {
                  notifier.completeTaskAndSession();
                  Navigator.of(context).pop();
                },
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
}
