import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_extensions.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/services/sparse_sort_order.dart';
import '../models/task_selection.dart';
import '../providers/task_provider.dart';
import 'task_priority_badge.dart';

/// Kanban board of tasks grouped by [TaskStatus].
class TasksBoardView extends ConsumerStatefulWidget {
  final List<Task> tasks;
  final int? selectedTaskId;
  final ValueChanged<TaskSelection>? onTaskSelected;

  const TasksBoardView({super.key, required this.tasks, this.selectedTaskId, this.onTaskSelected});

  @override
  ConsumerState<TasksBoardView> createState() => _TasksBoardViewState();
}

class _TasksBoardViewState extends ConsumerState<TasksBoardView> {
  late final PageController _pageController;
  int _compactPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Map<TaskStatus, List<Task>> _columns() {
    final map = {for (final status in TaskStatus.values) status: <Task>[]};
    for (final task in widget.tasks) {
      map[task.status]!.add(task);
    }
    for (final list in map.values) {
      list.sort((a, b) {
        final cmp = a.sortOrder.compareTo(b.sortOrder);
        if (cmp != 0) return cmp;
        return (a.id ?? 0).compareTo(b.id ?? 0);
      });
    }
    return map;
  }

  Future<void> _persist(Task updated) async {
    await ref.read(taskProvider(updated.projectId.toString()).notifier).updateTask(updated);
  }

  Future<void> _moveTask({
    required Task task,
    required TaskStatus targetStatus,
    required int insertIndex,
    required List<Task> targetColumn,
  }) async {
    final neighbors = [
      for (final t in targetColumn)
        if (t.id != task.id) t.sortOrder,
    ];

    var order = SparseSortOrder.forInsert(neighborOrders: neighbors, insertIndex: insertIndex);
    if (order == null) {
      final rebalanced = SparseSortOrder.rebalance(neighbors.length + 1);
      // Rewrite neighbours then place moved task at insertIndex.
      final others = [
        for (final t in targetColumn)
          if (t.id != task.id) t,
      ];
      for (var i = 0; i < others.length; i++) {
        final newIndex = i >= insertIndex ? i + 1 : i;
        final nextOrder = rebalanced[newIndex];
        if (others[i].sortOrder != nextOrder || others[i].status != targetStatus) {
          await _persist(others[i].copyWith(status: targetStatus, sortOrder: nextOrder));
        }
      }
      order = rebalanced[insertIndex.clamp(0, rebalanced.length - 1)];
    }

    if (task.status == targetStatus && task.sortOrder == order) return;
    await _persist(task.copyWith(status: targetStatus, sortOrder: order));
  }

  void _openTask(Task task) {
    if (task.id == null) return;
    if (widget.onTaskSelected != null) {
      widget.onTaskSelected!(TaskSelection(taskId: task.id!, projectId: task.projectId));
      return;
    }
    context.push(AppRoutes.taskDetailPath(task.id!), extra: {'projectId': task.projectId});
  }

  void _goToColumn(int index) {
    final clamped = index.clamp(0, TaskStatus.values.length - 1);
    if (clamped == _compactPage) return;
    setState(() => _compactPage = clamped);
    if (_pageController.hasClients) {
      _pageController.animateToPage(clamped, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final columns = _columns();
    if (widget.tasks.isEmpty) {
      return const AppEmptyState(
        icon: fu.FLucideIcons.kanban,
        message: 'No tasks on this board yet',
        detail: 'Create a task to start organizing by status.',
      );
    }
    final board = context.isCompact
        ? Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _compactPage > 0
                        ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          )
                        : null,
                    icon: const Icon(fu.FLucideIcons.chevronLeft),
                  ),
                  Expanded(
                    child: Text(
                      TaskStatus.values[_compactPage].label,
                      textAlign: TextAlign.center,
                      style: context.typography.sm.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    onPressed: _compactPage < TaskStatus.values.length - 1
                        ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          )
                        : null,
                    icon: const Icon(fu.FLucideIcons.chevronRight),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: TaskStatus.values.length,
                  onPageChanged: (index) => setState(() => _compactPage = index),
                  itemBuilder: (context, index) {
                    final status = TaskStatus.values[index];
                    return _BoardColumn(
                      status: status,
                      tasks: columns[status]!,
                      selectedTaskId: widget.selectedTaskId,
                      onOpenTask: _openTask,
                      onDrop: (task, insertIndex) => _moveTask(
                        task: task,
                        targetStatus: status,
                        insertIndex: insertIndex,
                        targetColumn: columns[status]!,
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final status in TaskStatus.values) ...[
                if (status != TaskStatus.values.first) SizedBox(width: AppConstants.spacing.small),
                Expanded(
                  child: _BoardColumn(
                    status: status,
                    tasks: columns[status]!,
                    selectedTaskId: widget.selectedTaskId,
                    onOpenTask: _openTask,
                    onDrop: (task, insertIndex) => _moveTask(
                      task: task,
                      targetStatus: status,
                      insertIndex: insertIndex,
                      targetColumn: columns[status]!,
                    ),
                  ),
                ),
              ],
            ],
          );
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _goToColumn(_compactPage - 1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _goToColumn(_compactPage + 1),
        const SingleActivator(LogicalKeyboardKey.digit1): () => _goToColumn(0),
        const SingleActivator(LogicalKeyboardKey.digit2): () => _goToColumn(1),
        const SingleActivator(LogicalKeyboardKey.digit3): () => _goToColumn(2),
        const SingleActivator(LogicalKeyboardKey.digit4): () => _goToColumn(3),
      },
      child: Focus(autofocus: PlatformUtils.isDesktop, child: board),
    );
  }
}

class _BoardColumn extends StatelessWidget {
  final TaskStatus status;
  final List<Task> tasks;
  final int? selectedTaskId;
  final ValueChanged<Task> onOpenTask;
  final Future<void> Function(Task task, int insertIndex) onDrop;

  const _BoardColumn({
    required this.status,
    required this.tasks,
    required this.selectedTaskId,
    required this.onOpenTask,
    required this.onDrop,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onDrop(details.data, tasks.length),
      builder: (context, candidateData, _) {
        final hovering = candidateData.isNotEmpty;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.muted.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
            border: hovering ? Border.all(color: context.colors.primary, width: 1.5) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(AppConstants.spacing.small),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(status.label, style: context.typography.sm.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    Text(
                      '${tasks.length}',
                      style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    AppConstants.spacing.small,
                    0,
                    AppConstants.spacing.small,
                    AppConstants.spacing.small,
                  ),
                  itemCount: tasks.length + 1,
                  itemBuilder: (context, index) {
                    if (index == tasks.length) {
                      return _ColumnGapDropTarget(height: 28, onAccept: (task) => onDrop(task, tasks.length));
                    }

                    final task = tasks[index];
                    return Column(
                      children: [
                        _ColumnGapDropTarget(height: 12, onAccept: (dropped) => onDrop(dropped, index)),
                        _BoardCard(
                          task: task,
                          isSelected: selectedTaskId != null && selectedTaskId == task.id,
                          onTap: () => onOpenTask(task),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ColumnGapDropTarget extends StatelessWidget {
  final double height;
  final ValueChanged<Task> onAccept;

  const _ColumnGapDropTarget({required this.height, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, _) {
        final hovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: hovering ? height + 8 : height,
          margin: EdgeInsets.symmetric(vertical: hovering ? 2 : 0),
          decoration: BoxDecoration(
            color: hovering ? context.colors.primary.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}

class _BoardCard extends StatelessWidget {
  final Task task;
  final bool isSelected;
  final VoidCallback onTap;

  const _BoardCard({required this.task, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = AppCard(
      onTap: onTap,
      isCompleted: task.isCompleted,
      title: Text(task.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: TaskPriorityBadge(priority: task.priority),
      subtitle: (task.description != null && task.description!.isNotEmpty)
          ? Text(
              task.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
            )
          : null,
    );

    return LongPressDraggable<Task>(
      data: task,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
        child: SizedBox(width: 220, child: Opacity(opacity: 0.9, child: card)),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
          border: Border.all(color: isSelected ? context.colors.primary : Colors.transparent, width: 1.5),
        ),
        child: card,
      ),
    );
  }
}
