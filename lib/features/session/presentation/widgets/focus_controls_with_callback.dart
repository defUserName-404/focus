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

/// Transport controls (stop / play-pause / skip) for an active focus session.
class FocusControlsWithCallback extends ConsumerWidget {
  final bool controlsVisible;

  const FocusControlsWithCallback({super.key, required this.controlsVisible});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(focusProgressProvider);

    if (progress == null) return const SizedBox.shrink();

    final notifier = ref.read(focusTimerProvider.notifier);
    final showTransport = !progress.isIdle && !progress.isCompleted;

    return SizedBox(
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
                    icon: FLucideIcons.square,
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
                    icon: FLucideIcons.skipForward,
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
          AnimatedOpacity(
            duration: AppConstants.animation.medium,
            opacity: (showTransport && controlsVisible) || !showTransport ? 1.0 : 0.0,
            child: FocusCircleIconButton(
              icon: _centerIcon(progress),
              size: 64,
              color: context.colors.primaryForeground,
              backgroundColor: context.colors.primary,
              onTap: () {
                ref.read(focusScreenProvider.notifier).onUserInteraction();
                notifier.togglePlayPause();
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _centerIcon(FocusProgress progress) {
    if (progress.isIdle) return FLucideIcons.play;
    if (progress.isPaused) return FLucideIcons.play;
    return FLucideIcons.pause;
  }

  void _confirmEnd(BuildContext context, WidgetRef ref) {
    showFDialog(
      context: context,
      builder: (ctx, _, _) => FDialog(
        builder: (context, style) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              DefaultTextStyle(style: style.titleTextStyle, child: const Text('End session?')),
              const SizedBox(height: 8),
              DefaultTextStyle(
                style: style.bodyTextStyle,
                child: const Text("This session will be saved but won't count as completed."),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: .end,
                spacing: 8,
                children: [
                  FButton(onPress: () => ctx.pop(), variant: .ghost, child: const Text('Keep going')),
                  FButton(
                    onPress: () {
                      ctx.pop();
                      ref.read(focusTimerProvider.notifier).cancelSession();
                    },
                    variant: .destructive,
                    child: const Text('End session'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
