import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/assets.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/focus_session_provider.dart';
import 'circular_progress_painter.dart';

/// Circular progress ring with countdown timer inside.
/// Tap = play/pause toggle.
///
/// Uses implicit animations for smooth transitions between states:
/// - Ring color animates between focus/break
/// - Timer text crossfades on phase changes
/// - "tap to start" hint fades in/out
class CircularTimer extends ConsumerWidget {
  const CircularTimer({super.key});

  static final double _ringSize = AppConstants.spacing.extraLarge * 10;

  static final double _strokeWidth = AppConstants.spacing.small;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(focusProgressProvider);

    if (progress == null) {
      return SizedBox(
        width: _ringSize,
        height: _ringSize,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final progressColor = progress.isFocusPhase
        ? context.colors.primary
        : context.colors.mutedForeground;

    return GestureDetector(
      onTap: () => ref.read(focusTimerProvider.notifier).togglePlayPause(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: progressColor),
            duration: AppConstants.animation.medium,
            builder: (context, color, _) {
              return SizedBox(
                width: _ringSize,
                height: _ringSize,
                child: CustomPaint(
                  painter: CircularProgressPainter(
                    progress: progress.progress,
                    trackColor: context.colors.border,
                    progressColor: color ?? progressColor,
                    strokeWidth: _strokeWidth,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          progress.formattedTime,
                          style: context.typography.xl6
                              .copyWith(fontWeight: FontWeight.w100),
                        ),
                        AnimatedSwitcher(
                          duration: AppConstants.animation.medium,
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                            opacity: animation,
                            child: SizeTransition(
                              sizeFactor: animation,
                              axisAlignment: -1.0,
                              child: child,
                            ),
                          ),
                          child: progress.isIdle
                              ? Padding(
                                  key: const ValueKey('tap-hint'),
                                  padding: EdgeInsets.only(
                                      top: AppConstants.spacing.regular),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    spacing: AppConstants.spacing.small,
                                    children: [
                                      Icon(
                                        FIcons.play,
                                        size:
                                            AppConstants.size.icon.large,
                                        color: context
                                            .colors.mutedForeground,
                                      ),
                                      Text(
                                        'tap to start',
                                        style: context.typography.xs
                                            .copyWith(
                                          color: context
                                              .colors.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(
                                  key: ValueKey('no-hint')),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
