import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/constants/app_constants.dart';
import '../commands/focus_commands.dart';
import '../providers/focus_session_provider.dart';

/// Pause/Resume + End session buttons.
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

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            SizedBox(width: AppConstants.spacing.large),
            FButton(
              style: FButtonStyle.destructive(),
              onPress: () => FocusCommands.confirmEnd(context, ref),
              prefix: const Icon(FIcons.square),
              child: const Text('End'),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
