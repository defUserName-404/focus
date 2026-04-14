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
import '../providers/upcoming_calendar_state_provider.dart';
import '../providers/upcoming_calendar_view_provider.dart';
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

class _CalendarContent extends ConsumerStatefulWidget {
  final List<Task> tasks;

  const _CalendarContent({required this.tasks});

  @override
  ConsumerState<_CalendarContent> createState() => _CalendarContentState();
}

class _CalendarContentState extends ConsumerState<_CalendarContent> {
  OverlayEntry? _taskOverlay;
  final LayerLink _calendarLayerLink = LayerLink();

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  bool _isDateVisibleInCurrentView({
    required CalendarViewMode viewMode,
    required UpcomingCalendarUiState uiState,
    required DateTime date,
  }) {
    if (viewMode == CalendarViewMode.month) {
      return date.year == uiState.displayMonth.year && date.month == uiState.displayMonth.month;
    }

    final weekEnd = uiState.displayWeekStart.add(const Duration(days: 6));
    return !date.isBefore(uiState.displayWeekStart) && !date.isAfter(weekEnd);
  }

  DateTime? _effectiveSelectedDay({
    required CalendarViewMode viewMode,
    required UpcomingCalendarUiState uiState,
    required Map<DateTime, List<Task>> tasksByDate,
    required DateTime today,
  }) {
    final selected = uiState.selectedDay;

    if (selected != null &&
        tasksByDate.containsKey(selected) &&
        _isDateVisibleInCurrentView(viewMode: viewMode, uiState: uiState, date: selected)) {
      return selected;
    }

    if (selected == null &&
        tasksByDate.containsKey(today) &&
        _isDateVisibleInCurrentView(viewMode: viewMode, uiState: uiState, date: today)) {
      return today;
    }

    return null;
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

  void _switchView({
    required CalendarViewMode currentView,
    required CalendarViewMode nextView,
    required UpcomingCalendarUiState uiState,
    required DateTime? selectedDay,
  }) {
    if (currentView == nextView) return;

    final anchor = selectedDay ?? uiState.selectedDay ?? DateTime.now();
    _removeOverlay();

    ref.read(upcomingCalendarUiStateProvider.notifier).switchView(nextView, anchor: anchor);
    ref.read(upcomingCalendarViewModeProvider.notifier).setMode(nextView);
  }

  void _previousPeriod(CalendarViewMode viewMode) {
    _removeOverlay();
    ref.read(upcomingCalendarUiStateProvider.notifier).previousPeriod(viewMode);
  }

  void _nextPeriod(CalendarViewMode viewMode) {
    _removeOverlay();
    ref.read(upcomingCalendarUiStateProvider.notifier).nextPeriod(viewMode);
  }

  void _onDateTapped(DateTime date) {
    _removeOverlay();
    final normalized = _dateOnly(date);
    final tasks = _tasksByDate[normalized];
    if (tasks == null || tasks.isEmpty) {
      ref.read(upcomingCalendarUiStateProvider.notifier).selectDay(null);
      return;
    }

    ref.read(upcomingCalendarUiStateProvider.notifier).selectDay(normalized);

    // Show overlay popup with tasks
    _showTaskOverlay(selectedDay: normalized, tasks: tasks);
  }

  void _showTaskOverlay({required DateTime selectedDay, required List<Task> tasks}) {
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
                  ref.read(upcomingCalendarUiStateProvider.notifier).selectDay(null);
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
                    selectedDay: selectedDay,
                    tasks: tasks,
                    onTaskTap: (task) {
                      _removeOverlay();
                      ref.read(upcomingCalendarUiStateProvider.notifier).selectDay(null);
                      context.push(AppRoutes.taskDetailPath(task.id!), extra: {'projectId': task.projectId});
                    },
                    onClose: () {
                      _removeOverlay();
                      ref.read(upcomingCalendarUiStateProvider.notifier).selectDay(null);
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
    final viewModeAsync = ref.watch(upcomingCalendarViewModeProvider);
    final viewMode = viewModeAsync.value ?? CalendarViewMode.month;
    final uiState = ref.watch(upcomingCalendarUiStateProvider);
    final tasksByDate = _tasksByDate;
    final effectiveSelectedDay = _effectiveSelectedDay(
      viewMode: viewMode,
      uiState: uiState,
      tasksByDate: tasksByDate,
      today: now,
    );
    final displayMonth = uiState.displayMonth;
    final displayWeekStart = uiState.displayWeekStart;
    final daysInMonth = DateTime(displayMonth.year, displayMonth.month + 1, 0).day;
    final firstWeekday = DateTime(displayMonth.year, displayMonth.month, 1).weekday; // 1=Mon

    return CompositedTransformTarget(
      link: _calendarLayerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('This', style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
              _CalendarViewToggle(
                view: viewMode,
                onChanged: (nextView) {
                  _switchView(
                    currentView: viewMode,
                    nextView: nextView,
                    uiState: uiState,
                    selectedDay: effectiveSelectedDay,
                  );
                },
              ),
            ],
          ),
          SizedBox(height: AppConstants.spacing.regular),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _previousPeriod(viewMode),
                child: Icon(
                  fu.FIcons.chevronLeft,
                  size: AppConstants.size.icon.regular,
                  color: context.colors.mutedForeground,
                ),
              ),
              Text(
                _periodLabel(viewMode: viewMode, displayMonth: displayMonth, displayWeekStart: displayWeekStart),
                style: context.typography.sm.copyWith(fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () => _nextPeriod(viewMode),
                child: Icon(
                  fu.FIcons.chevronRight,
                  size: AppConstants.size.icon.regular,
                  color: context.colors.mutedForeground,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.spacing.regular),

          if (viewMode == CalendarViewMode.month) ...[
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
            ..._buildWeeks(
              context,
              displayMonth: displayMonth,
              daysInMonth: daysInMonth,
              firstWeekday: firstWeekday,
              tasksByDate: tasksByDate,
              now: now,
              selectedDay: effectiveSelectedDay,
            ),
          ] else
            _buildWeekStrip(
              context,
              weekStart: displayWeekStart,
              tasksByDate: tasksByDate,
              now: now,
              selectedDay: effectiveSelectedDay,
            ),
        ],
      ),
    );
  }

  String _periodLabel({
    required CalendarViewMode viewMode,
    required DateTime displayMonth,
    required DateTime displayWeekStart,
  }) {
    if (viewMode == CalendarViewMode.month) {
      final monthName = DateTimeConstants.shortMonthNames[displayMonth.month - 1];
      return '$monthName ${displayMonth.year}';
    }

    final weekEnd = displayWeekStart.add(const Duration(days: 6));
    return '${displayWeekStart.toShortDateString()} - ${weekEnd.toShortDateString()}';
  }

  Widget _buildWeekStrip(
    BuildContext context, {
    required DateTime weekStart,
    required Map<DateTime, List<Task>> tasksByDate,
    required DateTime now,
    required DateTime? selectedDay,
  }) {
    final days = List.generate(7, (index) => weekStart.add(Duration(days: index)));

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
                isSelected: DateUtils.isSameDay(days[index], selectedDay),
              ),
            ),
          ),
          if (index < days.length - 1) SizedBox(width: AppConstants.spacing.extraSmall),
        ],
      ],
    );
  }

  List<Widget> _buildWeeks(
    BuildContext context, {
    required DateTime displayMonth,
    required int daysInMonth,
    required int firstWeekday,
    required Map<DateTime, List<Task>> tasksByDate,
    required DateTime now,
    required DateTime? selectedDay,
  }) {
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
      final date = DateTime(displayMonth.year, displayMonth.month, day);
      final hasTasks = tasksByDate.containsKey(date);
      final isToday = now.year == displayMonth.year && now.month == displayMonth.month && now.day == day;
      final isSelected = DateUtils.isSameDay(selectedDay, date);

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
  final CalendarViewMode view;
  final ValueChanged<CalendarViewMode> onChanged;

  const _CalendarViewToggle({required this.view, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        fu.FButton(
          style: view == CalendarViewMode.week ? fu.FButtonStyle.secondary() : fu.FButtonStyle.outline(),
          onPress: () => onChanged(CalendarViewMode.week),
          child: Text('Week', style: context.typography.xs),
        ),
        SizedBox(width: AppConstants.spacing.extraSmall),
        fu.FButton(
          style: view == CalendarViewMode.month ? fu.FButtonStyle.secondary() : fu.FButtonStyle.outline(),
          onPress: () => onChanged(CalendarViewMode.month),
          child: Text('Month', style: context.typography.xs),
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
