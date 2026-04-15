import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../tasks/domain/entities/task.dart';
import '../models/upcoming_calendar_ui_state.dart';
import '../providers/upcoming_calendar_state_provider.dart';
import '../providers/upcoming_calendar_view_provider.dart';
import '../utils/upcoming_calendar_utils.dart';
import 'calendar_month_grid.dart';
import 'calendar_view_toggle.dart';
import 'calendar_week_strip.dart';
import 'task_popup_content.dart';

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

  Map<DateTime, List<Task>> get _tasksByDate {
    return UpcomingCalendarUtils.groupTasksByDate(widget.tasks);
  }

  void _switchView({
    required CalendarViewMode currentView,
    required CalendarViewMode nextView,
    required UpcomingCalendarUiState uiState,
    required DateTime? selectedDay,
  }) {
    if (currentView == nextView) return;

    final anchor = UpcomingCalendarUtils.resolveViewAnchor(selectedDay: selectedDay, uiSelectedDay: uiState.selectedDay);
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
    final normalized = UpcomingCalendarUtils.normalizeDate(date);
    final tasks = _tasksByDate[normalized];
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
    final viewModeAsync = ref.watch(upcomingCalendarViewModeProvider);
    final viewMode = viewModeAsync.value ?? CalendarViewMode.month;
    final uiState = ref.watch(upcomingCalendarUiStateProvider);
    final tasksByDate = _tasksByDate;
    final effectiveSelectedDay = UpcomingCalendarUtils.effectiveSelectedDay(
      viewMode: viewMode,
      uiState: uiState,
      tasksByDate: tasksByDate,
      today: now,
    );
    final displayMonth = uiState.displayMonth;
    final displayWeekStart = uiState.displayWeekStart;
    final daysInMonth = UpcomingCalendarUtils.daysInMonth(displayMonth);
    final firstWeekday = UpcomingCalendarUtils.firstWeekday(displayMonth);

    return CompositedTransformTarget(
      link: _calendarLayerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('This', style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
              CalendarViewToggle(
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
                UpcomingCalendarUtils.periodLabel(
                  viewMode: viewMode,
                  displayMonth: displayMonth,
                  displayWeekStart: displayWeekStart,
                ),
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
            CalendarMonthGrid(
              displayMonth: displayMonth,
              daysInMonth: daysInMonth,
              firstWeekday: firstWeekday,
              tasksByDate: tasksByDate,
              now: now,
              selectedDay: effectiveSelectedDay,
              onDateTap: _onDateTapped,
            ),
          ] else
            CalendarWeekStrip(
              weekStart: displayWeekStart,
              tasksByDate: tasksByDate,
              now: now,
              selectedDay: effectiveSelectedDay,
              onDateTap: _onDateTapped,
            ),
        ],
      ),
    );
  }
}
