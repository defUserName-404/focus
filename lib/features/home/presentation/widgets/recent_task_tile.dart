import 'package:flutter/material.dart';
import 'package:focus/core/common/utils/datetime_formatter.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/app_constants.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';
import 'package:focus/features/tasks/presentation/widgets/task_priority_badge.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/route_constants.dart';

class RecentTaskTile extends StatelessWidget {
  final Task task;

  const RecentTaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        RouteConstants.taskDetailRoute,
        arguments: {'taskId': task.id!, 'projectId': task.projectId},
      ),
      child: fu.FCard(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.spacing.regular),
          child: Row(
            children: [
              // Status icon
              Container(
                width: AppConstants.size.icon.large + AppConstants.spacing.small,
                height: AppConstants.size.icon.large + AppConstants.spacing.small,
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? context.colors.primary.withValues(alpha: 0.15)
                      : context.colors.mutedForeground.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
                ),
                child: Icon(
                  task.isCompleted ? fu.FIcons.check : fu.FIcons.circle,
                  size: AppConstants.size.icon.extraSmall,
                  color: task.isCompleted ? context.colors.primary : context.colors.mutedForeground,
                ),
              ),
              SizedBox(width: AppConstants.spacing.regular),
              // Title + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: context.typography.sm.copyWith(
                        fontWeight: FontWeight.w500,
                        color: task.isCompleted ? context.colors.mutedForeground : context.colors.foreground,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppConstants.spacing.extraSmall),
                    Text(
                      task.updatedAt.toRelativeDueString().replaceFirst('Due ', ''),
                      style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                    ),
                  ],
                ),
              ),
              TaskPriorityBadge(priority: task.priority),
              SizedBox(width: AppConstants.spacing.small),
              Icon(
                fu.FIcons.chevronRight,
                size: AppConstants.size.icon.extraSmall,
                color: context.colors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
