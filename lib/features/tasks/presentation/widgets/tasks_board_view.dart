import 'dart:async';

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
  Offset? _dragGlobalPosition;
  Timer? _pageEdgeTimer;
  bool _isDragging = false;

  static const _edgePx = 48.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageEdgeTimer?.cancel();
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

  void _onDragStarted() {
    _isDragging = true;
    _pageEdgeTimer?.cancel();
    if (!context.isCompact) return;
    _pageEdgeTimer = Timer.periodic(const Duration(milliseconds: 180), (_) => _maybeScrollPages());
  }

  void _onDragEnded() {
    _isDragging = false;
    _dragGlobalPosition = null;
    _pageEdgeTimer?.cancel();
    _pageEdgeTimer = null;
  }

  void _onDragUpdate(Offset globalPosition) {
    _dragGlobalPosition = globalPosition;
    if (_isDragging && context.isCompact) {
      _maybeScrollPages();
    }
  }

  void _maybeScrollPages() {
    if (!_isDragging || !context.isCompact || !mounted) return;
    final pos = _dragGlobalPosition;
    if (pos == null) return;
    final width = MediaQuery.sizeOf(context).width;
    if (pos.dx < _edgePx) {
      _goToColumn(_compactPage - 1);
    } else if (pos.dx > width - _edgePx) {
      _goToColumn(_compactPage + 1);
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final usePaged = context.isCompact;
        final board = usePaged
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
                          onDragStarted: _onDragStarted,
                          onDragEnded: _onDragEnded,
                          onDragUpdate: _onDragUpdate,
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
            : ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(right: AppConstants.spacing.small),
                itemCount: TaskStatus.values.length,
                separatorBuilder: (_, _) => SizedBox(width: AppConstants.spacing.small),
                itemBuilder: (context, index) {
                  final status = TaskStatus.values[index];
                  final columnWidth = (constraints.maxWidth / TaskStatus.values.length).clamp(200.0, 280.0).toDouble();
                  return SizedBox(
                    width: columnWidth,
                    child: _BoardColumn(
                      status: status,
                      tasks: columns[status]!,
                      selectedTaskId: widget.selectedTaskId,
                      onOpenTask: _openTask,
                      onDragStarted: _onDragStarted,
                      onDragEnded: _onDragEnded,
                      onDragUpdate: _onDragUpdate,
                      onDrop: (task, insertIndex) => _moveTask(
                        task: task,
                        targetStatus: status,
                        insertIndex: insertIndex,
                        targetColumn: columns[status]!,
                      ),
                    ),
                  );
                },
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
      },
    );
  }
}

class _BoardColumn extends StatefulWidget {
  final TaskStatus status;
  final List<Task> tasks;
  final int? selectedTaskId;
  final ValueChanged<Task> onOpenTask;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  final ValueChanged<Offset> onDragUpdate;
  final Future<void> Function(Task task, int insertIndex) onDrop;

  const _BoardColumn({
    required this.status,
    required this.tasks,
    required this.selectedTaskId,
    required this.onOpenTask,
    required this.onDragStarted,
    required this.onDragEnded,
    required this.onDragUpdate,
    required this.onDrop,
  });

  @override
  State<_BoardColumn> createState() => _BoardColumnState();
}

class _BoardColumnState extends State<_BoardColumn> {
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  int? _hoverInsertIndex;
  static const _edgePx = 56.0;
  static const _scrollStep = 28.0;

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startEdgeScroll(double direction) {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!_scrollController.hasClients) return;
      final next = (_scrollController.offset + direction * _scrollStep).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      if (next == _scrollController.offset) return;
      _scrollController.jumpTo(next);
    });
  }

  void _stopEdgeScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _handleDragPosition(Offset globalPosition) {
    widget.onDragUpdate(globalPosition);
    if (!_scrollController.hasClients) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final local = box.globalToLocal(globalPosition);
    if (local.dy < _edgePx) {
      _startEdgeScroll(-1);
    } else if (local.dy > box.size.height - _edgePx) {
      _startEdgeScroll(1);
    } else {
      _stopEdgeScroll();
    }
  }

  int _insertIndexForCard(int cardIndex, Offset globalPosition, RenderBox cardBox) {
    final local = cardBox.globalToLocal(globalPosition);
    final before = local.dy < cardBox.size.height / 2;
    return before ? cardIndex : cardIndex + 1;
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      onWillAcceptWithDetails: (_) => true,
      onMove: (details) => _handleDragPosition(details.offset),
      onLeave: (_) {
        _stopEdgeScroll();
        if (_hoverInsertIndex != null) setState(() => _hoverInsertIndex = null);
      },
      onAcceptWithDetails: (details) {
        _stopEdgeScroll();
        final insertIndex = _hoverInsertIndex ?? widget.tasks.length;
        setState(() => _hoverInsertIndex = null);
        widget.onDrop(details.data, insertIndex);
      },
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
                      child: Text(
                        widget.status.label,
                        style: context.typography.sm.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '${widget.tasks.length}',
                      style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(
                    AppConstants.spacing.small,
                    0,
                    AppConstants.spacing.small,
                    AppConstants.spacing.small,
                  ),
                  itemCount: widget.tasks.length + 1,
                  itemBuilder: (context, index) {
                    if (index == widget.tasks.length) {
                      return _ColumnGapDropTarget(
                        height: 28,
                        showLine: _hoverInsertIndex == widget.tasks.length,
                        onHover: () {
                          if (_hoverInsertIndex != widget.tasks.length) {
                            setState(() => _hoverInsertIndex = widget.tasks.length);
                          }
                        },
                        onAccept: (task) => widget.onDrop(task, widget.tasks.length),
                      );
                    }

                    final task = widget.tasks[index];
                    return Column(
                      children: [
                        _ColumnGapDropTarget(
                          height: 12,
                          showLine: _hoverInsertIndex == index,
                          onHover: () {
                            if (_hoverInsertIndex != index) {
                              setState(() => _hoverInsertIndex = index);
                            }
                          },
                          onAccept: (dropped) => widget.onDrop(dropped, index),
                        ),
                        _BoardCard(
                          task: task,
                          isSelected: widget.selectedTaskId != null && widget.selectedTaskId == task.id,
                          onTap: () => widget.onOpenTask(task),
                          onDragStarted: widget.onDragStarted,
                          onDragEnded: () {
                            widget.onDragEnded();
                            _stopEdgeScroll();
                          },
                          onDragUpdate: _handleDragPosition,
                          onHoverWithDetails: (details, cardBox) {
                            _handleDragPosition(details.offset);
                            final insertIndex = _insertIndexForCard(index, details.offset, cardBox);
                            if (_hoverInsertIndex != insertIndex) {
                              setState(() => _hoverInsertIndex = insertIndex);
                            }
                          },
                          onAcceptWithDetails: (details, cardBox) {
                            _stopEdgeScroll();
                            final insertIndex = _insertIndexForCard(index, details.offset, cardBox);
                            setState(() => _hoverInsertIndex = null);
                            widget.onDrop(details.data, insertIndex);
                          },
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
  final bool showLine;
  final VoidCallback onHover;
  final ValueChanged<Task> onAccept;

  const _ColumnGapDropTarget({
    required this.height,
    required this.showLine,
    required this.onHover,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      onWillAcceptWithDetails: (_) => true,
      onMove: (_) => onHover(),
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, _) {
        final hovering = candidateData.isNotEmpty || showLine;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: hovering ? height + 8 : height,
          margin: EdgeInsets.symmetric(vertical: hovering ? 2 : 0),
          alignment: .center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: hovering ? 3 : 0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: hovering ? context.colors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      },
    );
  }
}

class _BoardCard extends StatefulWidget {
  final Task task;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  final ValueChanged<Offset> onDragUpdate;
  final void Function(DragTargetDetails<Task> details, RenderBox cardBox) onHoverWithDetails;
  final void Function(DragTargetDetails<Task> details, RenderBox cardBox) onAcceptWithDetails;

  const _BoardCard({
    required this.task,
    required this.isSelected,
    required this.onTap,
    required this.onDragStarted,
    required this.onDragEnded,
    required this.onDragUpdate,
    required this.onHoverWithDetails,
    required this.onAcceptWithDetails,
  });

  @override
  State<_BoardCard> createState() => _BoardCardState();
}

class _BoardCardState extends State<_BoardCard> {
  bool _dragging = false;

  Widget _buildDraggable({required Widget child, required Widget feedback}) {
    void started() {
      setState(() => _dragging = true);
      widget.onDragStarted();
    }

    void ended() {
      if (_dragging) setState(() => _dragging = false);
      widget.onDragEnded();
    }

    if (PlatformUtils.isDesktop) {
      return Draggable<Task>(
        data: widget.task,
        feedback: feedback,
        childWhenDragging: Opacity(opacity: 0.35, child: child),
        onDragStarted: started,
        onDragEnd: (_) => ended(),
        onDraggableCanceled: (_, _) => ended(),
        onDragUpdate: (details) => widget.onDragUpdate(details.globalPosition),
        child: child,
      );
    }

    return LongPressDraggable<Task>(
      data: widget.task,
      feedback: feedback,
      childWhenDragging: Opacity(opacity: 0.35, child: child),
      onDragStarted: started,
      onDragEnd: (_) => ended(),
      onDraggableCanceled: (_, _) => ended(),
      onDragUpdate: (details) => widget.onDragUpdate(details.globalPosition),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = AppCard(
      onTap: widget.onTap,
      isCompleted: widget.task.isCompleted,
      dense: true,
      mouseCursor: _dragging ? SystemMouseCursors.grabbing : SystemMouseCursors.grab,
      title: Text(widget.task.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TaskPriorityBadge(priority: widget.task.priority),
          if (widget.task.description != null && widget.task.description!.isNotEmpty) ...[
            SizedBox(height: AppConstants.spacing.extraSmall),
            Text(
              widget.task.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
            ),
          ],
        ],
      ),
    );

    final feedback = Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
      child: SizedBox(width: 220, child: Opacity(opacity: 0.9, child: card)),
    );

    final wrapped = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
        border: Border.all(color: widget.isSelected ? context.colors.primary : Colors.transparent, width: 1.5),
      ),
      child: card,
    );

    return Focus(
      canRequestFocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.space)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: DragTarget<Task>(
        onWillAcceptWithDetails: (details) => details.data.id != widget.task.id,
        onMove: (details) {
          final box = context.findRenderObject() as RenderBox?;
          if (box == null) return;
          widget.onHoverWithDetails(details, box);
        },
        onAcceptWithDetails: (details) {
          final box = context.findRenderObject() as RenderBox?;
          if (box == null) return;
          widget.onAcceptWithDetails(details, box);
        },
        builder: (context, candidateData, _) {
          return _buildDraggable(child: wrapped, feedback: feedback);
        },
      ),
    );
  }
}
