import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;
import 'package:intl/intl.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../focus/domain/entities/focus_session.dart';
import '../../../focus/domain/entities/session_state.dart';

/// Displays a list of the most recent focus sessions for a task.
class RecentSessionsSection extends StatelessWidget {
  final List<FocusSession> sessions;

  const RecentSessionsSection({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Sessions',
              style: context.typography.sm.copyWith(fontWeight: FontWeight.w600, color: context.colors.foreground),
            ),
            const Spacer(),
            Text(
              '${sessions.length} total',
              style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
            ),
          ],
        ),
        SizedBox(height: AppConstants.spacing.regular),
        ...sessions.take(5).map((session) => _SessionTile(session: session)),
      ],
    );
  }
}

// ── Session tile ────────────────────────────────────────────────────────────

class _SessionTile extends StatelessWidget {
  final FocusSession session;

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final duration = session.elapsedSeconds ~/ 60;
    final isCompleted = session.state == SessionState.completed;
    final isCancelled = session.state == SessionState.cancelled;

    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.spacing.regular),
      child: fu.FCard(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.spacing.regular,
            vertical: AppConstants.spacing.regular,
          ),
          child: Row(
            children: [
              // Status icon
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? context.colors.primary.withValues(alpha: 0.15)
                      : isCancelled
                      ? context.colors.destructive.withValues(alpha: 0.15)
                      : context.colors.mutedForeground.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
                ),
                child: Icon(
                  isCompleted
                      ? fu.FIcons.check
                      : isCancelled
                      ? fu.FIcons.x
                      : fu.FIcons.clock,
                  size: 14,
                  color: isCompleted
                      ? context.colors.primary
                      : isCancelled
                      ? context.colors.destructive
                      : context.colors.mutedForeground,
                ),
              ),
              SizedBox(width: AppConstants.spacing.regular),

              // Duration and focus/break info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${duration}min focus · ${session.focusDurationMinutes}min planned',
                      style: context.typography.sm.copyWith(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: AppConstants.spacing.extraSmall),
                    Text(
                      _formatRelativeDate(session.startTime),
                      style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                    ),
                  ],
                ),
              ),

              // State badge
              fu.FBadge(
                style: isCompleted ? fu.FBadgeStyle.primary() : fu.FBadgeStyle.outline(),
                child: Text(_stateLabel(session.state), style: context.typography.xs),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _stateLabel(SessionState state) {
    return switch (state) {
      SessionState.completed => 'Completed',
      SessionState.cancelled => 'Cancelled',
      SessionState.running => 'Running',
      SessionState.paused => 'Paused',
      SessionState.onBreak => 'On Break',
      SessionState.idle => 'Idle',
    };
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat.MMMd().format(date);
  }
}
