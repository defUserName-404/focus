import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';
import 'package:focus/features/tasks/presentation/providers/task_provider.dart';

import 'inline_add_subtask.dart';
import 'subtask_row.dart';
import 'task_date_row.dart';
import 'task_priority_badge.dart';

class TaskCard extends ConsumerStatefulWidget {
  final Task task;
  final List<Task> subtasks;
  final String projectIdString;
  final VoidCallback? onTaskTap;
  final ValueChanged<Task>? onSubtaskTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.subtasks,
    required this.projectIdString,
    this.onTaskTap,
    this.onSubtaskTap,
  });

  @override
  ConsumerState<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard> {
  bool _subtasksExpanded = true;
  bool _addingSubtask = false;

  bool get _isOverdue =>
      widget.task.endDate != null && widget.task.endDate!.isBefore(DateTime.now()) && !widget.task.isCompleted;

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final subtasks = widget.subtasks;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border.all(color: const Color(0xFF232323)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Main task row ──
            _TaskMainRow(
              task: task,
              subtaskCount: subtasks.length,
              subtasksExpanded: _subtasksExpanded,
              isOverdue: _isOverdue,
              onToggle: () => ref.read(taskProvider(widget.projectIdString).notifier).toggleTaskCompletion(task),
              onTap: widget.onTaskTap,
              onAddSubtaskPressed: () => setState(() => _addingSubtask = true),
              onExpandToggle: subtasks.isNotEmpty ? () => setState(() => _subtasksExpanded = !_subtasksExpanded) : null,
            ),

            // ── Subtasks ──
            if (_subtasksExpanded && subtasks.isNotEmpty)
              ColoredBox(
                color: const Color(0xFF0D0D0D),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: subtasks
                      .map(
                        (st) => SubtaskRow(
                          subtask: st,
                          onToggle: () =>
                              ref.read(taskProvider(widget.projectIdString).notifier).toggleTaskCompletion(st),
                          onTap: widget.onSubtaskTap != null ? () => widget.onSubtaskTap!(st) : null,
                        ),
                      )
                      .toList(),
                ),
              ),

            // ── Inline add subtask ──
            if (_addingSubtask)
              ColoredBox(
                color: const Color(0xFF0D0D0D),
                child: InlineAddSubtask(
                  onCancel: () => setState(() => _addingSubtask = false),
                  onSubmit: (title) {
                    // ref
                    //     .read(taskProvider(widget.projectIdString).notifier)
                    //     .createSubtask(task, title);
                    setState(() {
                      _addingSubtask = false;
                      _subtasksExpanded = true;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Private: main task row ───────────────────────────────────────────────────

class _TaskMainRow extends StatelessWidget {
  final Task task;
  final int subtaskCount;
  final bool subtasksExpanded;
  final bool isOverdue;
  final VoidCallback onToggle;
  final VoidCallback? onTap;
  final VoidCallback onAddSubtaskPressed;
  final VoidCallback? onExpandToggle;

  const _TaskMainRow({
    required this.task,
    required this.subtaskCount,
    required this.subtasksExpanded,
    required this.isOverdue,
    required this.onToggle,
    required this.onAddSubtaskPressed,
    this.onTap,
    this.onExpandToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          _TaskCheckbox(checked: task.isCompleted, onToggle: onToggle),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + priority + arrow
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: task.isCompleted ? FontWeight.w400 : FontWeight.w600,
                          color: task.isCompleted ? const Color(0xFF666666) : const Color(0xFFF0F0F0),
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: const Color(0xFF666666),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TaskPriorityBadge(priority: task.priority),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onTap,
                      child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF555555)),
                    ),
                  ],
                ),

                // Description
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(task.description!, style: const TextStyle(fontSize: 13, color: Color(0xFF888888), height: 1.4)),
                ],

                const SizedBox(height: 6),

                // Date row + action chips
                Row(
                  children: [
                    TaskDateRow(startDate: task.startDate, deadline: task.endDate, isOverdue: isOverdue),
                    const Spacer(),
                    _AddSubtaskChip(onPressed: onAddSubtaskPressed),
                    if (subtaskCount > 0) ...[
                      const SizedBox(width: 4),
                      _SubtaskCountChip(count: subtaskCount, expanded: subtasksExpanded, onToggle: onExpandToggle!),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private: task checkbox ───────────────────────────────────────────────────

class _TaskCheckbox extends StatelessWidget {
  final bool checked;
  final VoidCallback onToggle;

  const _TaskCheckbox({required this.checked, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 20,
        height: 20,
        margin: const EdgeInsets.only(top: 1),
        decoration: BoxDecoration(
          color: checked ? Colors.white : Colors.transparent,
          border: checked ? null : Border.all(color: const Color(0xFF555555), width: 1.5),
          borderRadius: BorderRadius.circular(5),
        ),
        child: checked ? const Icon(Icons.check, size: 13, color: Color(0xFF111111)) : null,
      ),
    );
  }
}

// ── Private: "+ subtask" chip ────────────────────────────────────────────────

class _AddSubtaskChip extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddSubtaskChip({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF2A2A2A)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 13, color: Color(0xFF888888)),
            SizedBox(width: 2),
            Text(
              'subtask',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF888888)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private: subtask count + expand chip ────────────────────────────────────

class _SubtaskCountChip extends StatelessWidget {
  final int count;
  final bool expanded;
  final VoidCallback onToggle;

  const _SubtaskCountChip({required this.count, required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF2A2A2A)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF888888)),
            ),
            const SizedBox(width: 2),
            Icon(
              expanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
              size: 14,
              color: const Color(0xFF888888),
            ),
          ],
        ),
      ),
    );
  }
}
