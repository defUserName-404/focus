import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/common/utils/date_formatter.dart';
import '../../../../core/common/widgets/app_card.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../tasks/presentation/widgets/task_date_row.dart';
import '../../../tasks/presentation/widgets/task_priority_badge.dart';

/// A task card for the global all-tasks list.
///
/// Shows title, priority, dates, and project association.
/// Follows the same design language as [TaskCard] but without
/// subtask expansion (since this is a flat global list).
class AllTaskCard extends ConsumerWidget {
  final Task task;
  final VoidCallback? onTap;

  const AllTaskCard({super.key, required this.task, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue = task.endDate?.isOverdue ?? false;

    return AppCard(
      onTap: onTap,
      isCompleted: task.isCompleted,
      leading: fu.FCheckbox(
        value: task.isCompleted,
        onChange: (_) => ref.read(taskProvider(task.projectId.toString()).notifier).toggleTaskCompletion(task),
      ),
      title: Text(task.title),
      trailing: TaskPriorityBadge(priority: task.priority),
      subtitle: (task.description != null && task.description!.isNotEmpty)
          ? Text(
              task.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.typography.sm.copyWith(color: context.colors.mutedForeground, height: 1.4),
            )
          : null,
      content: TaskDateRow(
        startDate: task.startDate,
        deadline: task.endDate,
        isOverdue: isOverdue && !task.isCompleted,
      ),
    );
  }
}
