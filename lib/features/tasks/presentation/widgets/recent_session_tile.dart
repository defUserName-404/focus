import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import 'package:focus/core/utils/datetime_formatter.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../session/domain/entities/focus_session.dart';
import '../../../session/domain/entities/session_state.dart';

class RecentSessionTile extends StatelessWidget {
  final FocusSession session;

  const RecentSessionTile({super.key, required this.session});

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
                      session.startTime.toShortDateString(),
                      style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                    ),
                  ],
                ),
              ),
              fu.FBadge(
                style: isCompleted ? fu.FBadgeStyle.secondary() : fu.FBadgeStyle.outline(),
                child: Text(session.state.label, style: context.typography.sm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
