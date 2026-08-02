import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/utils/datetime_formatter.dart';
import '../../../../core/widgets/filter_select.dart';
import '../../../../core/widgets/meta_chip.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_status.dart';
import 'task_priority_badge.dart';

class TaskSummarySection extends StatelessWidget {
  final Task task;
  final String? projectName;
  final int? projectId;
  final ValueChanged<TaskStatus>? onStatusChanged;

  const TaskSummarySection({super.key, required this.task, this.projectName, this.projectId, this.onStatusChanged});

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                task.title,
                style: context.typography.lg.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (projectName != null)
              fu.FButton(
                onPress: () {
                  if (projectId != null) {
                    context.push(AppRoutes.projectDetailPath(projectId!));
                  }
                },
                variant: .ghost,
                mainAxisSize: .min,
                child: MetaChip(icon: fu.FLucideIcons.folder, label: projectName!),
              ),
          ],
        ),

        Wrap(
          spacing: AppConstants.spacing.regular,
          runSpacing: AppConstants.spacing.small,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TaskPriorityBadge(priority: task.priority),
            if (onStatusChanged != null)
              SizedBox(
                width: 160,
                child: FilterSelect<TaskStatus>(
                  selected: task.status,
                  onChanged: onStatusChanged!,
                  options: TaskStatus.values,
                  hint: 'Status',
                  labelBuilder: (status) => status.label,
                ),
              )
            else if (task.isCompleted)
              fu.FBadge(variant: .primary, child: const Text('Completed')),
          ],
        ),

        if (description != null && description.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 100),
            child: SingleChildScrollView(
              child: Text(
                description,
                style: context.typography.sm.copyWith(color: context.colors.mutedForeground, height: 1.5),
              ),
            ),
          ),

        if (start != null || end != null)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppConstants.spacing.regular,
            children: [
              if (start != null)
                MetaChip(icon: fu.FLucideIcons.calendarDays, label: 'Start: ${start.toDateTimeString()}'),
              if (end != null) ...[
                MetaChip(
                  icon: fu.FLucideIcons.calendarClock,
                  label: 'Due: ${end.toDateTimeString()}',
                  isDestructive: isOverdue && !task.isCompleted,
                ),
                if (isOverdue && !task.isCompleted) ...[
                  Icon(
                    fu.FLucideIcons.triangleAlert,
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
