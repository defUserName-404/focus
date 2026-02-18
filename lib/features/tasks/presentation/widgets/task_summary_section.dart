import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/common/utils/datetime_formatter.dart';
import '../../../../core/common/widgets/meta_chip.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../domain/entities/task.dart';
import 'task_priority_badge.dart';

class TaskSummarySection extends StatelessWidget {
  final Task task;
  final String? projectName;
  final BigInt? projectId;

  const TaskSummarySection({
    super.key,
    required this.task,
    this.projectName,
    this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    final description = task.description;
    final start = task.startDate;
    final end = task.endDate;
    final isOverdue = end?.isOverdue ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppConstants.spacing.regular,
      children: [
        Row(
          spacing: AppConstants.spacing.regular,
          crossAxisAlignment: .center,
          children: [
            Text(
              task.title,
              style: context.typography.lg.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: .ellipsis,
            ),
            if (projectName != null) ...[
              SizedBox(width: AppConstants.spacing.regular),
              Padding(
                padding: EdgeInsets.only(top: AppConstants.spacing.small),
                child: fu.FButton(
                  onPress: () {
                    if (projectId != null) {
                      Navigator.pushNamed(
                        context,
                        RouteConstants.projectDetailRoute,
                        arguments: projectId!,
                      );
                    }
                  },
                  style: fu.FButtonStyle.ghost(),
                  child: MetaChip(icon: fu.FIcons.folder, label: projectName!),
                ),
              ),
            ],
          ],
        ),

        Row(
          spacing: AppConstants.spacing.regular,
          children: [
            TaskPriorityBadge(priority: task.priority),
            if (task.isCompleted)
              fu.FBadge(
                style: fu.FBadgeStyle.primary(),
                child: Text('Completed'),
              ),
          ],
        ),

        if (description != null && description.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 100),
            child: SingleChildScrollView(
              child: Text(
                description,
                style: context.typography.sm.copyWith(
                  color: context.colors.mutedForeground,
                  height: 1.5,
                ),
              ),
            ),
          ),

        if (start != null || end != null)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppConstants.spacing.regular,
            children: [
              if (start != null)
                MetaChip(
                  icon: fu.FIcons.calendarDays,
                  label: 'Start: ${start.toDateString()}',
                ),
              if (end != null) ...[
                MetaChip(
                  icon: fu.FIcons.calendarClock,
                  label: 'Due: ${end.toDateString()}',
                  isDestructive: isOverdue && !task.isCompleted,
                ),
                if (isOverdue && !task.isCompleted) ...[
                  Icon(
                    fu.FIcons.triangleAlert,
                    size: AppConstants.size.icon.extraSmall,
                    color: context.colors.destructive,
                  ),
                  Text(
                    end.toRelativeDueString(),
                    style: context.typography.xs.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.destructive,
                    ),
                  ),
                ],
              ],
            ],
          ),

        const fu.FDivider(),
      ],
    );
  }
}
