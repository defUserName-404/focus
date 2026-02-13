import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/assets.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../commands/focus_commands.dart';
import '../providers/focus_session_provider.dart';
import 'circular_progress_painter.dart';

/// Circular progress ring with countdown timer inside.
/// Tap = play/pause toggle. Double-tap (while paused/idle) = edit duration.
class CircularTimer extends ConsumerWidget {
  const CircularTimer({super.key});

  /// Ring size derived from spacing constants (240px)
  static final double _ringSize = AppConstants.spacing.extraLarge * 10;

  static final double _strokeWidth = AppConstants.spacing.small;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(focusProgressProvider);
    final session = ref.watch(focusTimerProvider);

    return progressAsync.when(
      skipLoadingOnReload: true,
      data: (progress) {
        if (progress == null) return const SizedBox.shrink();

        final canEdit = progress.isIdle || progress.isPaused;

        return GestureDetector(
          onTap: () => ref.read(focusTimerProvider.notifier).togglePlayPause(),
          onDoubleTap: canEdit && session != null
              ? () => FocusCommands.editDuration(
                  context,
                  ref,
                  currentFocusMinutes: session.focusDurationMinutes,
                  currentBreakMinutes: session.breakDurationMinutes,
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: _ringSize,
                height: _ringSize,
                child: CustomPaint(
                  painter: CircularProgressPainter(
                    progress: progress.progress,
                    trackColor: context.colors.border,
                    progressColor: progress.isFocusPhase ? context.colors.primary : context.colors.mutedForeground,
                    strokeWidth: _strokeWidth,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          progress.formattedTime,
                          style: context.typography.xl6.copyWith(fontWeight: FontWeight.w100),
                        ),
                        // Hint text
                        if (canEdit)
                          Padding(
                            padding: EdgeInsets.only(top: AppConstants.spacing.regular),
                            child: Row(
                              mainAxisAlignment: .center,
                              spacing: AppConstants.spacing.small,
                              children: [
                                if (progress.isIdle)
                                  Icon(
                                    FIcons.play,
                                    size: AppConstants.size.icon.large,
                                    color: context.colors.mutedForeground,
                                  ),
                                Text(
                                  progress.isIdle ? 'tap to start' : 'double-tap to edit',
                                  style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => SizedBox(
        width: _ringSize,
        height: _ringSize,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
