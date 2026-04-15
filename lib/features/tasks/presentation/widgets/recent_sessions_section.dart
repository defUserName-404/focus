import 'package:flutter/material.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../session/domain/entities/focus_session.dart';
import 'recent_session_tile.dart';

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
        ...sessions.take(5).map((session) => RecentSessionTile(session: session)),
      ],
    );
  }
}
