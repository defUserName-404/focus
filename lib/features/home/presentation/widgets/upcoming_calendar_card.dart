import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/date_time_constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/widgets/task_priority_badge.dart';
import '../providers/upcoming_tasks_provider.dart';

/// A calendar-style view that shows upcoming task deadlines on the home screen.
///
/// Displays a compact month grid for the current month, highlighting days
/// that have upcoming deadlines. Tapping a day shows an overlay popup with
/// that day's tasks.
class UpcomingCalendarCard extends ConsumerWidget {
  const UpcomingCalendarCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingTasksProvider);

    return upcomingAsync.when(
      loading: () => const Center(child: fu.FCircularProgress()),
      error: (err, _) => Padding(
        padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.extraLarge2),
        child: Text('Error loading calendar: $err'),
      ),
      data: (tasks) => _CalendarContent(tasks: tasks),
    );
  }
}

class _CalendarContent extends StatefulWidget {
  final List<Task> tasks;

  const _CalendarContent({required this.tasks});

  @override
  State<_CalendarContent> createState() => _CalendarContentState();
}

class _CalendarContentState extends State<_CalendarContent> {
  late DateTime _displayMonth;
  DateTime? _selectedDay;
  OverlayEntry? _taskOverlay;
  final LayerLink _calendarLayerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _displayMonth = DateTime(DateTime.now().year, DateTime.now().month);
    // Auto-select today if it has tasks
    _autoSelectToday();
  }

  @override
  void didUpdateWidget(covariant _CalendarContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-check auto-select when tasks change
    if (oldWidget.tasks != widget.tasks && _selectedDay == null) {
      _autoSelectToday();
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _autoSelectToday() {
    final now = DateTime.now();
    if (_displayMonth.year == now.year && _displayMonth.month == now.month) {
      final tasksByDay = _tasksByDay;
      if (tasksByDay.containsKey(now.day)) {
        _selectedDay = DateTime(now.year, now.month, now.day);
      }
    }
  }

  /// Maps day-of-month to list of tasks with deadlines on that day.
  Map<int, List<Task>> get _tasksByDay {
    final map = <int, List<Task>>{};
    for (final task in widget.tasks) {
      final end = task.endDate;
      if (end != null && end.year == _displayMonth.year && end.month == _displayMonth.month) {
        map.putIfAbsent(end.day, () => []).add(task);
      }
    }
    return map;
  }

  void _previousMonth() {
    _removeOverlay();
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
      _selectedDay = null;
    });
  }

  void _nextMonth() {
    _removeOverlay();
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
      _selectedDay = null;
    });
  }

  void _onDayTapped(int day, Map<int, List<Task>> tasksByDay) {
    _removeOverlay();
    final tasks = tasksByDay[day];
    if (tasks == null || tasks.isEmpty) {
      setState(() => _selectedDay = null);
      return;
    }

    setState(() {
      _selectedDay = DateTime(_displayMonth.year, _displayMonth.month, day);
    });

    // Show overlay popup with tasks
    _showTaskOverlay(tasks);
  }

  void _showTaskOverlay(List<Task> tasks) {
    _removeOverlay();

    final overlay = Overlay.of(context);
    _taskOverlay = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            // Dismiss on tap outside
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _removeOverlay();
                  setState(() => _selectedDay = null);
                },
              ),
            ),
            // Popup card anchored below the calendar
            CompositedTransformFollower(
              link: _calendarLayerLink,
              targetAnchor: Alignment.bottomCenter,
              followerAnchor: Alignment.topCenter,
              offset: const Offset(0, 8),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320, maxHeight: 280),
                  child: _TaskPopupContent(
                    selectedDay: _selectedDay!,
                    tasks: tasks,
                    onTaskTap: (task) {
                      _removeOverlay();
                      setState(() => _selectedDay = null);
                      context.push(AppRoutes.taskDetailPath(task.id!), extra: {'projectId': task.projectId});
                    },
                    onClose: () {
                      _removeOverlay();
                      setState(() => _selectedDay = null);
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    overlay.insert(_taskOverlay!);
  }

  void _removeOverlay() {
    _taskOverlay?.remove();
    _taskOverlay?.dispose();
    _taskOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_displayMonth.year, _displayMonth.month, 1).weekday; // 1=Mon
    final tasksByDay = _tasksByDay;

    final monthName = DateTimeConstants.shortMonthNames[_displayMonth.month - 1];

    return CompositedTransformTarget(
      link: _calendarLayerLink,
      child: fu.FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month navigation header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _previousMonth,
                  child: Icon(
                    fu.FIcons.chevronLeft,
                    size: AppConstants.size.icon.regular,
                    color: context.colors.mutedForeground,
                  ),
                ),
                Text(
                  '$monthName ${_displayMonth.year}',
                  style: context.typography.sm.copyWith(fontWeight: FontWeight.w600),
                ),
                GestureDetector(
                  onTap: _nextMonth,
                  child: Icon(
                    fu.FIcons.chevronRight,
                    size: AppConstants.size.icon.regular,
                    color: context.colors.mutedForeground,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.spacing.regular),

            // Day-of-week header
            Row(
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: context.typography.xs.copyWith(
                            color: context.colors.mutedForeground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: AppConstants.spacing.small),

            // Calendar grid
            ..._buildWeeks(context, daysInMonth, firstWeekday, tasksByDay, now),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWeeks(
    BuildContext context,
    int daysInMonth,
    int firstWeekday,
    Map<int, List<Task>> tasksByDay,
    DateTime now,
  ) {
    final weeks = <Widget>[];
    var dayCounter = 1;
    // firstWeekday: 1=Mon. We need (firstWeekday-1) empty cells before day 1.
    final leadingEmpty = firstWeekday - 1;

    // Build rows of 7 cells each.
    var cellIndex = 0;
    var currentWeekCells = <Widget>[];

    // Leading empty cells
    for (var i = 0; i < leadingEmpty; i++) {
      currentWeekCells.add(const Expanded(child: SizedBox.shrink()));
      cellIndex++;
    }

    while (dayCounter <= daysInMonth) {
      final day = dayCounter;
      final hasTasks = tasksByDay.containsKey(day);
      final isToday = now.year == _displayMonth.year && now.month == _displayMonth.month && now.day == day;
      final isSelected = _selectedDay != null && _selectedDay!.day == day;

      currentWeekCells.add(
        Expanded(
          child: GestureDetector(
            onTap: hasTasks ? () => _onDayTapped(day, tasksByDay) : null,
            child: _DayCell(day: day, hasTasks: hasTasks, isToday: isToday, isSelected: isSelected),
          ),
        ),
      );

      cellIndex++;
      dayCounter++;

      if (cellIndex % 7 == 0) {
        weeks.add(Row(children: currentWeekCells));
        currentWeekCells = [];
      }
    }

    // Trailing empty cells for the last week
    if (currentWeekCells.isNotEmpty) {
      while (currentWeekCells.length < 7) {
        currentWeekCells.add(const Expanded(child: SizedBox.shrink()));
      }
      weeks.add(Row(children: currentWeekCells));
    }

    return weeks;
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool hasTasks;
  final bool isToday;
  final bool isSelected;

  const _DayCell({required this.day, required this.hasTasks, required this.isToday, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colors.primary
            : isToday
            ? context.colors.primary.withValues(alpha: 0.1)
            : null,
        borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$day',
            style: context.typography.xs.copyWith(
              fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected
                  ? context.colors.primaryForeground
                  : isToday
                  ? context.colors.primary
                  : context.colors.foreground,
            ),
          ),
          if (hasTasks && !isSelected)
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(color: context.colors.primary, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}

/// Overlay popup content showing tasks for a selected day.
class _TaskPopupContent extends StatelessWidget {
  final DateTime selectedDay;
  final List<Task> tasks;
  final ValueChanged<Task> onTaskTap;
  final VoidCallback onClose;

  const _TaskPopupContent({
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
          // Header
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
          // Task list
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
                return _OverlayTaskTile(task: task, onTap: () => onTaskTap(task));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayTaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const _OverlayTaskTile({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(
            fu.FIcons.clock,
            size: AppConstants.size.icon.extraSmall,
            color: task.endDate != null && task.endDate!.isBefore(DateTime.now())
                ? context.colors.destructive
                : context.colors.primary,
          ),
          SizedBox(width: AppConstants.spacing.regular),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: context.typography.xs.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.endDate != null)
                  Text(
                    task.endDate!.toRelativeDueString(),
                    style: context.typography.xs.copyWith(
                      color: task.endDate!.isBefore(DateTime.now())
                          ? context.colors.destructive
                          : context.colors.mutedForeground,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          TaskPriorityBadge(priority: task.priority),
        ],
      ),
    );
  }
}
