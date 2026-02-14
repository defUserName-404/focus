import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/navigator_key.dart';
import '../providers/focus_session_provider.dart';
import '../../domain/entities/session_state.dart';

/// A compact "mini-player" bar that appears above the bottom navigation
/// when a focus session is active but the user is on another screen.
///
/// Tapping the bar navigates to the full [FocusSessionScreen].
/// The play/pause button allows quick control without leaving the current screen.
class MiniPlayerOverlay extends ConsumerWidget {
  const MiniPlayerOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(focusTimerProvider);

    // Only show when there's an active (non-terminal) session.
    if (session == null) return const SizedBox.shrink();
    if (session.state == SessionState.completed ||
        session.state == SessionState.cancelled ||
        session.state == SessionState.incomplete) {
      return const SizedBox.shrink();
    }

    final progress = ref.watch(focusProgressProvider);

    if (progress == null) return const SizedBox.shrink();

    final notifier = ref.read(focusTimerProvider.notifier);
    final phaseLabel = progress.isFocusPhase ? 'Focus' : 'Break';
    final statusLabel = progress.isIdle
        ? 'Ready'
        : progress.isPaused
            ? 'Paused'
            : phaseLabel;

    return GestureDetector(
      onTap: () => navigateToFocusSession(context: context),
          child: Container(
            decoration: BoxDecoration(
              color: context.colors.background,
              border: Border(
                top: BorderSide(color: context.colors.border, width: 0.5),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.spacing.regular,
              vertical: AppConstants.spacing.small,
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Row(
                children: [
                  // Phase indicator dot
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: progress.isRunning
                          ? context.colors.primary
                          : context.colors.mutedForeground,
                    ),
                  ),
                  SizedBox(width: AppConstants.spacing.regular),

                  // Status & time
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusLabel,
                          style: context.typography.sm.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          progress.formattedTime,
                          style: context.typography.xs.copyWith(
                            color: context.colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress ring (tiny)
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      value: progress.progress,
                      strokeWidth: 2.5,
                      backgroundColor: context.colors.border,
                      valueColor: AlwaysStoppedAnimation(
                        progress.isFocusPhase
                            ? context.colors.primary
                            : context.colors.mutedForeground,
                      ),
                    ),
                  ),
                  SizedBox(width: AppConstants.spacing.regular),

                  // Play/Pause button
                  _MiniControlButton(
                    icon: progress.isIdle || progress.isPaused
                        ? FIcons.play
                        : FIcons.pause,
                    onTap: () => notifier.togglePlayPause(),
                    color: context.colors.primary,
                  ),
                ],
              ),
            ),
          ),
        );
  }
}

class _MiniControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _MiniControlButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: Icon(
          icon,
          size: 16,
          color: context.colors.primaryForeground,
        ),
      ),
    );
  }
}
