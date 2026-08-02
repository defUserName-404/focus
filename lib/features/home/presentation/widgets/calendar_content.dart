import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/calendar/calendar_day_info.dart';
import '../../../../core/widgets/calendar/calendar_week_strip.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/services/calendar_event_grouping.dart';
import '../providers/upcoming_calendar_state_provider.dart';
import '../providers/upcoming_calendar_view_provider.dart';
import '../utils/upcoming_calendar_utils.dart';
import 'task_popup_content.dart';

/// Compact "Next 7 Days" week strip for the home dashboard.
///
/// Month grid lives on the Tasks calendar tab.
class CalendarContent extends ConsumerStatefulWidget {
  final List<Task> tasks;

  const CalendarContent({super.key, required this.tasks});

  @override
  ConsumerState<CalendarContent> createState() => _CalendarContentState();
}

class _CalendarContentState extends ConsumerState<CalendarContent> {
  OverlayEntry? _taskOverlay;
  final LayerLink _calendarLayerLink = LayerLink();

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  Map<DateTime, List<Task>> _tasksByDateForWeek(DateTime weekStart) {
    final weekEnd = DateTimeUtils.addDays(weekStart, 6);
    return CalendarEventGrouping.groupTasksByDate(tasks: widget.tasks, from: weekStart, to: weekEnd);
  }

  Map<DateTime, CalendarDayInfo> _dayInfo(Map<DateTime, List<Task>> tasksByDate) {
    return {for (final entry in tasksByDate.entries) entry.key: CalendarDayInfo(taskCount: entry.value.length)};
  }

  void _previousWeek() {
    _removeOverlay();
    ref.read(upcomingCalendarUiStateProvider.notifier).previousPeriod(CalendarViewMode.week);
  }

  void _nextWeek() {
    _removeOverlay();
    ref.read(upcomingCalendarUiStateProvider.notifier).nextPeriod(CalendarViewMode.week);
  }

  void _onDateTapped(DateTime date, Map<DateTime, List<Task>> tasksByDate) {
    _removeOverlay();
    final normalized = UpcomingCalendarUtils.normalizeDate(date);
    final tasks = tasksByDate[normalized];
    if (tasks == null || tasks.isEmpty) {
      ref.read(upcomingCalendarUiStateProvider.notifier).selectDay(null);
      return;
    }

    ref.read(upcomingCalendarUiStateProvider.notifier).selectDay(normalized);
    _showTaskOverlay(selectedDay: normalized, tasks: tasks);
  }

  void _showTaskOverlay({required DateTime selectedDay, required List<Task> tasks}) {
    _removeOverlay();

    final overlay = Overlay.of(context);
    _taskOverlay = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _removeOverlay();
                  ref.read(upcomingCalendarUiStateProvider.notifier).selectDay(null);
                },
              ),
            ),
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
                  child: TaskPopupContent(
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
    final now = UpcomingCalendarUtils.today();
    final uiState = ref.watch(upcomingCalendarUiStateProvider);
    final displayWeekStart = uiState.displayWeekStart;
    final tasksByDate = _tasksByDateForWeek(displayWeekStart);
    final dayInfo = _dayInfo(tasksByDate);
    final effectiveSelectedDay = UpcomingCalendarUtils.effectiveSelectedDay(
      viewMode: CalendarViewMode.week,
      uiState: uiState,
      tasksByDate: tasksByDate,
      today: now,
    );

    return CompositedTransformTarget(
      link: _calendarLayerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _previousWeek,
                child: Icon(
                  fu.FLucideIcons.chevronLeft,
                  size: AppConstants.size.icon.regular,
                  color: context.colors.mutedForeground,
                ),
              ),
              Text(
                UpcomingCalendarUtils.periodLabel(
                  viewMode: CalendarViewMode.week,
                  displayMonth: uiState.displayMonth,
                  displayWeekStart: displayWeekStart,
                ),
                style: context.typography.sm.copyWith(fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: _nextWeek,
                child: Icon(
                  fu.FLucideIcons.chevronRight,
                  size: AppConstants.size.icon.regular,
                  color: context.colors.mutedForeground,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.spacing.regular),
          CalendarWeekStrip<Task>(
            weekStart: displayWeekStart,
            dayInfo: dayInfo,
            now: now,
            selectedDay: effectiveSelectedDay,
            onDateTap: (date) => _onDateTapped(date, tasksByDate),
          ),
        ],
      ),
    );
  }
}
