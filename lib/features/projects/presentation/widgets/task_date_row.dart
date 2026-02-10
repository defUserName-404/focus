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
    if (isOverdue && deadline != null) {
      return Row(
        children: [
          Icon(fu.FIcons.triangleAlert, color: context.colors.destructive, size: 13),
          const SizedBox(width: 4),
          Text(
            'Overdue (${_fmt(deadline!)})',
            style: context.typography.xs.copyWith(fontWeight: FontWeight.w500, color: context.colors.destructive),
          ),
        ],
      );
    }

    if (startDate == null && deadline == null) return const SizedBox.shrink();

    final dateText = startDate != null && deadline != null
        ? '${_fmt(startDate!)} – ${_fmt(deadline!)}'
        : deadline != null
        ? _fmt(deadline!)
        : _fmt(startDate!);

    return Row(
      children: [
        Icon(fu.FIcons.calendar, size: 13, color: context.colors.mutedForeground),
        const SizedBox(width: 5),
        Text(dateText, style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
      ],
    );
  }
}
