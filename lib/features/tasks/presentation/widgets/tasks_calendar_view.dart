import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/date_time_constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/calendar/calendar_agenda_view.dart';
import '../../../../core/widgets/calendar/calendar_day_info.dart';
import '../../../../core/widgets/calendar/calendar_month_grid.dart';
import '../../../../core/widgets/calendar/calendar_week_strip.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_extensions.dart';
import '../../domain/services/calendar_event_grouping.dart';
import '../models/task_selection.dart';
import '../providers/task_provider.dart';
import '../providers/task_stats_provider.dart';
import 'task_priority_badge.dart';

enum _TasksCalendarScope { month, week, day }

class TasksCalendarView extends ConsumerStatefulWidget {
  final List<Task> tasks;
  final int? selectedTaskId;
  final ValueChanged<TaskSelection>? onTaskSelected;

  const TasksCalendarView({super.key, required this.tasks, this.selectedTaskId, this.onTaskSelected});

  @override
  ConsumerState<TasksCalendarView> createState() => _TasksCalendarViewState();
}

class _TasksCalendarViewState extends ConsumerState<TasksCalendarView> {
  late DateTime _anchor;
  late DateTime _selectedDay;
  _TasksCalendarScope _scope = _TasksCalendarScope.month;

  @override
  void initState() {
    super.initState();
    final today = DateTimeUtils.dateOnly(DateTimeUtils.now());
    _anchor = DateTime(today.year, today.month);
    _selectedDay = today;
  }

  DateTime get _weekStart {
    final weekday = _selectedDay.weekday; // Mon=1
    return DateTimeUtils.addDays(_selectedDay, 1 - weekday);
  }

  (DateTime, DateTime) get _window {
    return switch (_scope) {
      _TasksCalendarScope.month => (
        DateTime(_anchor.year, _anchor.month, 1),
        DateTime(_anchor.year, _anchor.month + 1, 0),
      ),
      _TasksCalendarScope.week => (_weekStart, DateTimeUtils.addDays(_weekStart, 6)),
      _TasksCalendarScope.day => (_selectedDay, _selectedDay),
    };
  }

  String get _periodLabel {
    return switch (_scope) {
      _TasksCalendarScope.month => '${DateTimeConstants.shortMonthNames[_anchor.month - 1]} ${_anchor.year}',
      _TasksCalendarScope.week =>
        '${_weekStart.toShortDateString()} - ${DateTimeUtils.addDays(_weekStart, 6).toShortDateString()}',
      _TasksCalendarScope.day =>
        '${DateTimeConstants.shortWeekdayNames[_selectedDay.weekday - 1]}, '
            '${DateTimeConstants.shortMonthNames[_selectedDay.month - 1]} ${_selectedDay.day}',
    };
  }

  void _previous() {
    setState(() {
      switch (_scope) {
        case _TasksCalendarScope.month:
          _anchor = DateTime(_anchor.year, _anchor.month - 1);
          _selectedDay = DateTime(_anchor.year, _anchor.month, 1);
        case _TasksCalendarScope.week:
          _selectedDay = DateTimeUtils.addDays(_selectedDay, -7);
          _anchor = DateTime(_selectedDay.year, _selectedDay.month);
        case _TasksCalendarScope.day:
          _selectedDay = DateTimeUtils.addDays(_selectedDay, -1);
          _anchor = DateTime(_selectedDay.year, _selectedDay.month);
      }
    });
  }

  void _next() {
    setState(() {
      switch (_scope) {
        case _TasksCalendarScope.month:
          _anchor = DateTime(_anchor.year, _anchor.month + 1);
          _selectedDay = DateTime(_anchor.year, _anchor.month, 1);
        case _TasksCalendarScope.week:
          _selectedDay = DateTimeUtils.addDays(_selectedDay, 7);
          _anchor = DateTime(_selectedDay.year, _selectedDay.month);
        case _TasksCalendarScope.day:
          _selectedDay = DateTimeUtils.addDays(_selectedDay, 1);
          _anchor = DateTime(_selectedDay.year, _selectedDay.month);
      }
    });
  }

  Future<void> _reschedule(Task task, DateTime date) async {
    if (task.recurrenceRule != null) return;
    final previous = task.endDate;
    final next = previous == null
        ? DateTime(date.year, date.month, date.day, 9)
        : DateTime(date.year, date.month, date.day, previous.hour, previous.minute, previous.second);
    if (previous != null && DateUtils.isSameDay(previous, next)) return;
    await ref.read(taskProvider(task.projectId.toString()).notifier).updateTask(task.copyWith(endDate: next));
  }

  void _openTask(Task task) {
    if (task.id == null) return;
    if (widget.onTaskSelected != null) {
      widget.onTaskSelected!(TaskSelection(taskId: task.id!, projectId: task.projectId));
      return;
    }
    context.push(AppRoutes.taskDetailPath(task.id!), extra: {'projectId': task.projectId});
  }

  Map<DateTime, CalendarDayInfo> _dayInfo({
    required Map<DateTime, List<Task>> tasksByDate,
    required Map<DateTime, int> sessionsByDate,
  }) {
    final keys = {...tasksByDate.keys, ...sessionsByDate.keys};
    return {
      for (final key in keys)
        key: CalendarDayInfo(taskCount: tasksByDate[key]?.length ?? 0, sessionCount: sessionsByDate[key] ?? 0),
    };
  }

  void _goToday() {
    final today = DateTimeUtils.dateOnly(DateTimeUtils.now());
    setState(() {
      _selectedDay = today;
      _anchor = DateTime(today.year, today.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTimeUtils.dateOnly(DateTimeUtils.now());
    final window = _window;
    // Expand session look-up slightly beyond visible month for week edges.
    final statsFrom = DateTimeUtils.addDays(window.$1, -7);
    final statsTo = DateTimeUtils.addDays(window.$2, 7);
    final rangeKey = '${statsFrom.toIso8601String().substring(0, 10)}|${statsTo.toIso8601String().substring(0, 10)}';
    final statsAsync = ref.watch(dailyStatsForRangeProvider(rangeKey));

    final tasksByDate = CalendarEventGrouping.groupTasksByDate(tasks: widget.tasks, from: window.$1, to: window.$2);
    final sessionsByDate = CalendarEventGrouping.sessionCountsByDate(statsAsync.value ?? const []);
    final dayInfo = _dayInfo(tasksByDate: tasksByDate, sessionsByDate: sessionsByDate);
    final selectedTasks = tasksByDate[_selectedDay] ?? const <Task>[];
    final selectedInfo = dayInfo[_selectedDay] ?? const CalendarDayInfo();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final iconOnly = constraints.maxWidth < 520;
            return Row(
              children: [
                for (final scope in _TasksCalendarScope.values) ...[
                  if (scope != _TasksCalendarScope.values.first) SizedBox(width: AppConstants.spacing.extraSmall),
                  if (iconOnly)
                    fu.FTooltip(
                      tipBuilder: (context, _) => Text(switch (scope) {
                        _TasksCalendarScope.month => 'Month',
                        _TasksCalendarScope.week => 'Week',
                        _TasksCalendarScope.day => 'Day',
                      }),
                      child: fu.FButton.icon(
                        size: .sm,
                        variant: _scope == scope ? .secondary : .outline,
                        semanticsLabel: switch (scope) {
                          _TasksCalendarScope.month => 'Month',
                          _TasksCalendarScope.week => 'Week',
                          _TasksCalendarScope.day => 'Day',
                        },
                        onPress: () => setState(() => _scope = scope),
                        child: Icon(switch (scope) {
                          _TasksCalendarScope.month => fu.FLucideIcons.calendarRange,
                          _TasksCalendarScope.week => fu.FLucideIcons.calendarDays,
                          _TasksCalendarScope.day => fu.FLucideIcons.calendar,
                        }, size: AppConstants.size.icon.small),
                      ),
                    )
                  else
                    fu.FButton(
                      size: .sm,
                      mainAxisSize: .min,
                      variant: _scope == scope ? .secondary : .outline,
                      onPress: () => setState(() => _scope = scope),
                      child: Text(switch (scope) {
                        _TasksCalendarScope.month => 'Month',
                        _TasksCalendarScope.week => 'Week',
                        _TasksCalendarScope.day => 'Day',
                      }, style: context.typography.xs),
                    ),
                ],
                const Spacer(),
                GestureDetector(
                  onTap: _previous,
                  child: Icon(fu.FLucideIcons.chevronLeft, size: AppConstants.size.icon.regular),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.small),
                  child: Text(
                    _periodLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.sm.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                GestureDetector(
                  onTap: _next,
                  child: Icon(fu.FLucideIcons.chevronRight, size: AppConstants.size.icon.regular),
                ),
              ],
            );
          },
        ),
        SizedBox(height: AppConstants.spacing.regular),
        if (_scope == _TasksCalendarScope.month) ...[
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
          CalendarMonthGrid<Task>(
            displayMonth: _anchor,
            daysInMonth: DateTime(_anchor.year, _anchor.month + 1, 0).day,
            firstWeekday: DateTime(_anchor.year, _anchor.month, 1).weekday,
            dayInfo: dayInfo,
            now: now,
            selectedDay: _selectedDay,
            onDateTap: (date) => setState(() {
              _selectedDay = date;
              _scope = _TasksCalendarScope.day;
            }),
            onAcceptDrop: (date, task) => _reschedule(task, date),
          ),
          SizedBox(height: AppConstants.spacing.regular),
        ] else if (_scope == _TasksCalendarScope.week) ...[
          CalendarWeekStrip<Task>(
            weekStart: _weekStart,
            dayInfo: dayInfo,
            now: now,
            selectedDay: _selectedDay,
            onDateTap: (date) => setState(() {
              _selectedDay = date;
              _scope = _TasksCalendarScope.day;
            }),
            onAcceptDrop: (date, task) => _reschedule(task, date),
          ),
          SizedBox(height: AppConstants.spacing.regular),
        ],
        Expanded(
          child: ListView(
            children: [
              CalendarAgendaView<Task>(
                selectedDay: _selectedDay,
                dayInfo: selectedInfo,
                onAcceptDrop: (task) => _reschedule(task, _selectedDay),
                emptyTasks: const AppEmptyState(
                  icon: fu.FLucideIcons.calendar,
                  message: 'Nothing scheduled this day',
                  detail: 'Drop a task here or open day view after picking a date.',
                ),
                taskTiles: [
                  for (final task in selectedTasks)
                    Padding(
                      padding: EdgeInsets.only(bottom: AppConstants.spacing.small),
                      child: LongPressDraggable<Task>(
                        data: task,
                        feedback: Material(
                          elevation: 4,
                          child: SizedBox(
                            width: 260,
                            child: _AgendaTaskTile(
                              task: task,
                              isSelected: widget.selectedTaskId == task.id,
                              onTap: () {},
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.4,
                          child: _AgendaTaskTile(
                            task: task,
                            isSelected: widget.selectedTaskId == task.id,
                            onTap: () => _openTask(task),
                          ),
                        ),
                        child: _AgendaTaskTile(
                          task: task,
                          isSelected: widget.selectedTaskId == task.id,
                          onTap: () => _openTask(task),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): _previous,
        const SingleActivator(LogicalKeyboardKey.arrowRight): _next,
        const SingleActivator(LogicalKeyboardKey.keyT): _goToday,
        const SingleActivator(LogicalKeyboardKey.digit1): () => setState(() => _scope = _TasksCalendarScope.month),
        const SingleActivator(LogicalKeyboardKey.digit2): () => setState(() => _scope = _TasksCalendarScope.week),
        const SingleActivator(LogicalKeyboardKey.digit3): () => setState(() => _scope = _TasksCalendarScope.day),
      },
      child: Focus(autofocus: PlatformUtils.isDesktop, child: content),
    );
  }
}

class _AgendaTaskTile extends StatelessWidget {
  final Task task;
  final bool isSelected;
  final VoidCallback onTap;

  const _AgendaTaskTile({required this.task, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final overdue = (task.endDate?.isOverdue ?? false) && !task.isCompleted;
    return Material(
      color: isSelected ? context.colors.primary.withValues(alpha: 0.08) : context.colors.muted.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
        child: Padding(
          padding: EdgeInsets.all(AppConstants.spacing.small),
          child: Row(
            children: [
              Icon(
                fu.FLucideIcons.clock,
                size: AppConstants.size.icon.extraSmall,
                color: overdue ? context.colors.destructive : context.colors.primary,
              ),
              SizedBox(width: AppConstants.spacing.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (task.endDate != null)
                      Text(
                        task.endDate!.toRelativeDueString(),
                        style: context.typography.xs.copyWith(
                          color: overdue ? context.colors.destructive : context.colors.mutedForeground,
                        ),
                      ),
                  ],
                ),
              ),
              TaskPriorityBadge(priority: task.priority),
            ],
          ),
        ),
      ),
    );
  }
}
