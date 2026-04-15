import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/widgets/task_priority_badge.dart';
import '../utils/upcoming_calendar_utils.dart';

class OverlayTaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const OverlayTaskTile({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOverdue = UpcomingCalendarUtils.isTaskOverdue(task);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(
            fu.FIcons.clock,
            size: AppConstants.size.icon.extraSmall,
            color: isOverdue ? context.colors.destructive : context.colors.primary,
          ),
          SizedBox(width: AppConstants.spacing.regular),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: context.typography.xs.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.endDate != null)
                  Text(
                    task.endDate!.toRelativeDueString(),
                    style: context.typography.xs.copyWith(
                      color: isOverdue ? context.colors.destructive : context.colors.mutedForeground,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          TaskPriorityBadge(priority: task.priority),
        ],
      ),
    );
  }
}
