import 'package:flutter/material.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:forui/forui.dart' as fu;
import 'package:intl/intl.dart';

class TaskDateRow extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? deadline;
  final bool isOverdue;

  const TaskDateRow({super.key, this.startDate, this.deadline, this.isOverdue = false});

  String _fmt(DateTime dt) => DateFormat('MMM d').format(dt);

  @override
  Widget build(BuildContext context) {
    if (startDate == null && deadline == null) return const SizedBox.shrink();

    final children = <Widget>[];

    // Date text
    final dateText = startDate != null && deadline != null
        ? '${_fmt(startDate!)} – ${_fmt(deadline!)}'
        : deadline != null
            ? _fmt(deadline!)
            : _fmt(startDate!);

    children.addAll([
      Padding(
        padding: const EdgeInsets.only(bottom: 2), // Vertical lift
        child: Icon(
          fu.FIcons.calendar,
          size: 12,
          color: context.colors.mutedForeground,
        ),
      ),
      const SizedBox(width: 4),
      Text(dateText, style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
    ]);

    // Overdue / approaching label
    if (deadline != null) {
      final now = DateTime.now();
      final days = deadline!.difference(now).inDays;

      if (isOverdue || days < 0) {
        children.addAll([
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Icon(
              fu.FIcons.triangleAlert,
              color: context.colors.destructive,
              size: 12,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            'Overdue ${days.abs()}d',
            style: context.typography.xs.copyWith(fontWeight: FontWeight.w600, color: context.colors.destructive),
          ),
        ]);
      } else if (days <= 3) {
        children.addAll([
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Icon(fu.FIcons.clock, color: Colors.orange, size: 12),
          ),
          const SizedBox(width: 3),
          Text(
            days == 0
                ? 'Due today'
                : days == 1
                    ? 'Due tomorrow'
                    : 'Due in ${days}d',
            style: context.typography.xs.copyWith(fontWeight: FontWeight.w600, color: Colors.orange),
          ),
        ]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // Vertical alignment fix
      children: children,
    );
  }
}
