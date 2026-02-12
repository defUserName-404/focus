import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/focus_session_provider.dart';
import '../widgets/circular_timer.dart';
import '../widgets/focus_controls.dart';
import '../widgets/focus_task_info.dart';

/// The main orchestrator screen for the focus session.
/// Strictly composes extracted widgets and handles high-level layout.
class FocusSessionScreen extends ConsumerWidget {
  const FocusSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(focusProgressProvider);
    final session = ref.watch(focusTimerProvider);

    if (session == null) {
      return const FScaffold(child: Center(child: Text('No active session')));
    }

    return PopScope(
      canPop: true,
      child: FScaffold(
        header: FHeader.nested(
          title: const Text('Focus'),
          prefixes: [FHeaderAction.back(onPress: () => Navigator.of(context).pop())],
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppConstants.spacing.large),
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
                const FocusControls(),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
