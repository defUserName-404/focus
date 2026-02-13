import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../commands/focus_commands.dart';
import '../providers/focus_session_provider.dart';

/// Focus session controls:
///
/// - **Center (largest)**: Play / Pause toggle
/// - **Left (smaller, elevated)**: Stop / End cycle
/// - **Right (smaller, elevated)**: Skip to next phase
/// - **Below (full-width)**: Complete Task button (unchanged)
class FocusControls extends ConsumerWidget {
  const FocusControls({super.key});

  static const double _centerSize = 64;
  static const double _sideSize = 44;
  static const double _sideElevation = -8; // negative = higher

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(focusProgressProvider);

    return progressAsync.when(
      skipLoadingOnReload: true,
      data: (progress) {
        if (progress == null) return const SizedBox.shrink();

        final notifier = ref.read(focusTimerProvider.notifier);
        final showTransport = !progress.isIdle && !progress.isCompleted;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Transport controls (stack) ───────────────────────
            SizedBox(
              height: _centerSize + 8,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Left: Stop button (slightly elevated)
                  if (showTransport)
                    Positioned(
                      left: 0,
                      top: _sideElevation,
                      child: _CircleIconButton(
                        icon: FIcons.square,
                        size: _sideSize,
                        color: context.colors.mutedForeground,
                        backgroundColor: context.colors.muted,
                        onTap: () => FocusCommands.confirmEnd(context, ref),
                      ),
                    ),

                  // Right: Skip button (slightly elevated)
                  if (showTransport)
                    Positioned(
                      right: 0,
                      top: _sideElevation,
                      child: _CircleIconButton(
                        icon: FIcons.skipForward,
                        size: _sideSize,
                        color: context.colors.mutedForeground,
                        backgroundColor: context.colors.muted,
                        onTap: () => notifier.skipToNextPhase(),
                      ),
                    ),

                  // Center: Play / Pause (largest)
                  _CircleIconButton(
                    icon: _centerIcon(progress),
                    size: _centerSize,
                    color: context.colors.primaryForeground,
                    backgroundColor: context.colors.primary,
                    onTap: () => notifier.togglePlayPause(),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppConstants.spacing.extraLarge),

            // ── Complete Task (unchanged) ────────────────────────
            if (!progress.isIdle && !progress.isCompleted)
              FButton(
                style: FButtonStyle.outline(),
                onPress: () {
                  notifier.completeTaskAndSession();
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

  IconData _centerIcon(FocusProgress progress) {
    if (progress.isIdle) return FIcons.play;
    if (progress.isPaused) return FIcons.play;
    return FIcons.pause;
  }
}

/// A circular icon button used for the transport controls.
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
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(icon, color: color, size: size * 0.4),
        ),
      ),
    );
  }
}
