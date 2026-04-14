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
/// Supports month and week views, highlighting days with upcoming deadlines.
/// Tapping a day shows an overlay popup with that day's tasks.
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

enum _CalendarView { month, week }

class _CalendarContent extends StatefulWidget {
  final List<Task> tasks;

  const _CalendarContent({required this.tasks});

  @override
  State<_CalendarContent> createState() => _CalendarContentState();
}

class _CalendarContentState extends State<_CalendarContent> {
  late DateTime _displayMonth;
  late DateTime _displayWeekStart;
  _CalendarView _view = _CalendarView.month;
  DateTime? _selectedDay;
  OverlayEntry? _taskOverlay;
  final LayerLink _calendarLayerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month);
    _displayWeekStart = _startOfWeek(now);
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

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  DateTime _startOfWeek(DateTime date) {
    final normalized = _dateOnly(date);
    return normalized.subtract(Duration(days: normalized.weekday - DateTime.monday));
  }

  bool _isDateVisibleInCurrentView(DateTime date) {
    if (_view == _CalendarView.month) {
      return date.year == _displayMonth.year && date.month == _displayMonth.month;
    }

    final weekEnd = _displayWeekStart.add(const Duration(days: 6));
    return !date.isBefore(_displayWeekStart) && !date.isAfter(weekEnd);
  }

  void _autoSelectToday() {
    final today = _dateOnly(DateTime.now());
    if (_isDateVisibleInCurrentView(today) && _tasksByDate.containsKey(today)) {
      _selectedDay = today;
    } else {
      _selectedDay = null;
    }
  }

  /// Maps a calendar date to tasks with deadlines on that day.
  Map<DateTime, List<Task>> get _tasksByDate {
    final map = <DateTime, List<Task>>{};
    for (final task in widget.tasks) {
      final end = task.endDate;
      if (end != null) {
        final key = _dateOnly(end);
        map.putIfAbsent(key, () => []).add(task);
      }
    }

    for (final tasks in map.values) {
      tasks.sort((a, b) {
        final aEnd = a.endDate;
        final bEnd = b.endDate;
        if (aEnd == null && bEnd == null) return 0;
        if (aEnd == null) return -1;
        if (bEnd == null) return 1;
        return aEnd.compareTo(bEnd);
      });
    }

    return map;
  }

  void _switchView(_CalendarView view) {
    if (_view == view) return;

    final anchor = _selectedDay ?? DateTime.now();
    _removeOverlay();
    setState(() {
      _view = view;
      _selectedDay = null;
      if (view == _CalendarView.week) {
        _displayWeekStart = _startOfWeek(anchor);
      } else {
        _displayMonth = DateTime(anchor.year, anchor.month);
      }
      _autoSelectToday();
    });
  }

  void _previousPeriod() {
    _removeOverlay();
    setState(() {
      if (_view == _CalendarView.month) {
        _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
      } else {
        _displayWeekStart = _displayWeekStart.subtract(const Duration(days: 7));
      }
      _selectedDay = null;
    });
  }

  void _nextPeriod() {
    _removeOverlay();
    setState(() {
      if (_view == _CalendarView.month) {
        _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
      } else {
        _displayWeekStart = _displayWeekStart.add(const Duration(days: 7));
      }
      _selectedDay = null;
    });
  }

  void _onDateTapped(DateTime date) {
    _removeOverlay();
    final normalized = _dateOnly(date);
    final tasks = _tasksByDate[normalized];
    if (tasks == null || tasks.isEmpty) {
      setState(() => _selectedDay = null);
      return;
    }

    setState(() {
      _selectedDay = normalized;
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
    final now = _dateOnly(DateTime.now());
    final tasksByDate = _tasksByDate;
    final daysInMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_displayMonth.year, _displayMonth.month, 1).weekday; // 1=Mon

    return CompositedTransformTarget(
      link: _calendarLayerLink,
      child: fu.FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _view == _CalendarView.month ? 'Focus Month' : 'Focus Week',
                  style: context.typography.sm.copyWith(fontWeight: FontWeight.w600),
                ),
                _CalendarViewToggle(view: _view, onChanged: _switchView),
              ],
            ),
            SizedBox(height: AppConstants.spacing.regular),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _previousPeriod,
                  child: Icon(
                    fu.FIcons.chevronLeft,
                    size: AppConstants.size.icon.regular,
                    color: context.colors.mutedForeground,
                  ),
                ),
                Text(_periodLabel, style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
                GestureDetector(
                  onTap: _nextPeriod,
                  child: Icon(
                    fu.FIcons.chevronRight,
                    size: AppConstants.size.icon.regular,
                    color: context.colors.mutedForeground,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.spacing.regular),

            if (_view == _CalendarView.month) ...[
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
              ..._buildWeeks(context, daysInMonth, firstWeekday, tasksByDate, now),
            ] else
              _buildWeekStrip(context, tasksByDate, now),
          ],
        ),
      ),
    );
  }

  String get _periodLabel {
    if (_view == _CalendarView.month) {
      final monthName = DateTimeConstants.shortMonthNames[_displayMonth.month - 1];
      return '$monthName ${_displayMonth.year}';
    }

    final weekEnd = _displayWeekStart.add(const Duration(days: 6));
    return '${_displayWeekStart.toShortDateString()} - ${weekEnd.toShortDateString()}';
  }

  Widget _buildWeekStrip(BuildContext context, Map<DateTime, List<Task>> tasksByDate, DateTime now) {
    final days = List.generate(7, (index) => _displayWeekStart.add(Duration(days: index)));

    return Row(
      children: [
        for (var index = 0; index < days.length; index++) ...[
          Expanded(
            child: GestureDetector(
              onTap: tasksByDate.containsKey(days[index]) ? () => _onDateTapped(days[index]) : null,
              child: _WeekDayCell(
                date: days[index],
                taskCount: tasksByDate[days[index]]?.length ?? 0,
                isToday: DateUtils.isSameDay(days[index], now),
                isSelected: DateUtils.isSameDay(days[index], _selectedDay),
              ),
            ),
          ),
          if (index < days.length - 1) SizedBox(width: AppConstants.spacing.extraSmall),
        ],
      ],
    );
  }

  List<Widget> _buildWeeks(
    BuildContext context,
    int daysInMonth,
    int firstWeekday,
    Map<DateTime, List<Task>> tasksByDate,
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
      final date = DateTime(_displayMonth.year, _displayMonth.month, day);
      final hasTasks = tasksByDate.containsKey(date);
      final isToday = now.year == _displayMonth.year && now.month == _displayMonth.month && now.day == day;
      final isSelected = DateUtils.isSameDay(_selectedDay, date);

      currentWeekCells.add(
        Expanded(
          child: GestureDetector(
            onTap: hasTasks ? () => _onDateTapped(date) : null,
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

class _CalendarViewToggle extends StatelessWidget {
  final _CalendarView view;
  final ValueChanged<_CalendarView> onChanged;

  const _CalendarViewToggle({required this.view, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        fu.FButton(
          style: view == _CalendarView.week ? fu.FButtonStyle.secondary() : fu.FButtonStyle.outline(),
          onPress: () => onChanged(_CalendarView.week),
          child: const Text('Week'),
        ),
        SizedBox(width: AppConstants.spacing.extraSmall),
        fu.FButton(
          style: view == _CalendarView.month ? fu.FButtonStyle.secondary() : fu.FButtonStyle.outline(),
          onPress: () => onChanged(_CalendarView.month),
          child: const Text('Month'),
        ),
      ],
    );
  }
}

class _WeekDayCell extends StatelessWidget {
  final DateTime date;
  final int taskCount;
  final bool isToday;
  final bool isSelected;

  const _WeekDayCell({required this.date, required this.taskCount, required this.isToday, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final dayLabel = DateTimeConstants.shortWeekdayNames[date.weekday - 1];
    final indicatorCount = taskCount.clamp(0, 3);

    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.small, vertical: AppConstants.spacing.small),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colors.primary
            : isToday
            ? context.colors.primary.withValues(alpha: 0.1)
            : context.colors.muted.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayLabel,
            style: context.typography.xs.copyWith(
              color: isSelected ? context.colors.primaryForeground : context.colors.mutedForeground,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppConstants.spacing.extraSmall),
          Text(
            '${date.day}',
            style: context.typography.sm.copyWith(
              color: isSelected ? context.colors.primaryForeground : context.colors.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppConstants.spacing.extraSmall),
          if (indicatorCount > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < indicatorCount; i++) ...[
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.primaryForeground.withValues(alpha: 0.85)
                          : context.colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (i < indicatorCount - 1) SizedBox(width: AppConstants.spacing.extraSmall),
                ],
              ],
            )
          else
            const SizedBox(height: 4),
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
