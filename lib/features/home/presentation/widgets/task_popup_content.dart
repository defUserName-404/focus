import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../../tasks/domain/entities/task.dart';
import 'overlay_task_tile.dart';

class TaskPopupContent extends StatelessWidget {
  final DateTime selectedDay;
  final List<Task> tasks;
  final ValueChanged<Task> onTaskTap;
  final VoidCallback onClose;

  const TaskPopupContent({
    super.key,
    required this.selectedDay,
    required this.tasks,
    required this.onTaskTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppConstants.spacing.large,
              AppConstants.spacing.regular,
              AppConstants.spacing.regular,
              AppConstants.spacing.regular,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${selectedDay.toShortDateString()} - ${tasks.length} task${tasks.length > 1 ? 's' : ''}',
                    style: context.typography.sm.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Icon(fu.FIcons.x, size: AppConstants.size.icon.small, color: context.colors.mutedForeground),
                ),
              ],
            ),
          ),
          const fu.FDivider(),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.spacing.large,
                vertical: AppConstants.spacing.regular,
              ),
              itemCount: tasks.length,
              separatorBuilder: (_, _) => SizedBox(height: AppConstants.spacing.regular),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return OverlayTaskTile(task: task, onTap: () => onTaskTap(task));
              },
            ),
          ),
        ],
      ),
    );
  }
}
