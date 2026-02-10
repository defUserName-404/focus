import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskDateRow extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? deadline;
  final bool isOverdue;

  const TaskDateRow({
    super.key,
    this.startDate,
    this.deadline,
    this.isOverdue = false,
  });

  String _fmt(DateTime dt) => DateFormat('MMM d').format(dt);

  @override
  Widget build(BuildContext context) {
    if (isOverdue && deadline != null) {
      return Row(
        children: [
          const Icon(Icons.error, color: Color(0xFFB71C1C), size: 13),
          const SizedBox(width: 4),
          Text(
            'Overdue (${_fmt(deadline!)})',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFFB71C1C),
            ),
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
        const Icon(Icons.calendar_today_outlined,
            size: 13, color: Color(0xFF666666)),
        const SizedBox(width: 5),
        Text(
          dateText,
          style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
        ),
      ],
    );
  }
}
