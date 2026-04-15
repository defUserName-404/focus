import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/app_constants.dart';
import 'package:focus/features/home/presentation/providers/activity_graph_providers.dart';
import 'package:focus/features/home/presentation/widgets/activity_graph_legend.dart';
import 'package:focus/features/home/presentation/widgets/year_grid_painter.dart';
import 'package:focus/features/tasks/presentation/providers/task_stats_provider.dart';

import '../../../../core/utils/datetime_formatter.dart';
import '../utils/activity_graph_constants.dart';
import '../utils/activity_graph_utils.dart';

class YearActivityGraph extends ConsumerStatefulWidget {
  const YearActivityGraph({super.key});

  @override
  ConsumerState<YearActivityGraph> createState() => _YearActivityGraphState();
}

class _YearActivityGraphState extends ConsumerState<YearActivityGraph> {
  late final ScrollController _scrollController;
  OverlayEntry? _tooltip;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
  }

  @override
  void dispose() {
    _removeTooltip();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToToday() {
    if (!_scrollController.hasClients) return;
    final selectedYear = ref.read(selectedYearProvider);
    final currentYear = ActivityGraphUtils.today().year;
    if (selectedYear != currentYear) return;

    final weekIndex = ActivityGraphUtils.weekIndexForToday(selectedYear);
    final offset = weekIndex * ActivityGraphConstants.cellStep;
    _scrollController.jumpTo(offset.clamp(0.0, _scrollController.position.maxScrollExtent));
  }

  void _showTooltip(BuildContext context, Offset globalPos, String dateKey, int sessions) {
    _removeTooltip();
    ref.read(tappedDateProvider.notifier).setDate(dateKey);

    final overlay = Overlay.of(context);
    _tooltip = OverlayEntry(
      builder: (ctx) {
        final dx = (globalPos.dx - ActivityGraphConstants.tooltipWidth / 2).clamp(
          ActivityGraphConstants.tooltipHorizontalPadding,
          MediaQuery.of(ctx).size.width -
              ActivityGraphConstants.tooltipWidth -
              ActivityGraphConstants.tooltipHorizontalPadding,
        );
        final dy = globalPos.dy - ActivityGraphConstants.tooltipHeight - ActivityGraphConstants.tooltipBottomMargin;

        return Positioned(
          left: dx,
          top: dy,
          child: Container(
            width: ActivityGraphConstants.tooltipWidth,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: context.colors.foreground,
              borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
            ),
            child: Text(
              '$sessions session${sessions == 1 ? '' : 's'} on ${DateTimeExtensions.shortDateString(dateKey)}',
              textAlign: TextAlign.center,
              style: context.typography.xs.copyWith(color: context.colors.background, fontWeight: FontWeight.w500),
            ),
          ),
        );
      },
    );
    overlay.insert(_tooltip!);

    Future.delayed(ActivityGraphConstants.tooltipDuration, _removeTooltip);
  }

  void _removeTooltip() {
    _tooltip?.remove();
    _tooltip?.dispose();
    _tooltip = null;
    if (mounted && ref.read(tappedDateProvider) != null) {
      ref.read(tappedDateProvider.notifier).setDate(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedYear = ref.watch(selectedYearProvider);
    final tappedDateKey = ref.watch(tappedDateProvider);
    final currentYear = ActivityGraphUtils.today().year;
    final years = ActivityGraphUtils.selectableYears(startYear: ActivityGraphConstants.startYear);

    final startDate = '$selectedYear-01-01';
    final endDate = '$selectedYear-12-31';
    final rangeKey = '$startDate|$endDate';
    final asyncData = ref.watch(dailyStatsForRangeProvider(rangeKey));

    final jan1 = DateTime(selectedYear, 1, 1);
    final dec31 = DateTime(selectedYear, 12, 31);
    final totalWeeks = DateTimeExtensions.weekIndex(dec31, jan1) + 1;
    final gridWidth = ActivityGraphConstants.dayLabelWidth + totalWeeks * ActivityGraphConstants.cellStep;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Text(
              'Activity',
              style: context.typography.sm.copyWith(fontWeight: FontWeight.w600, color: context.colors.foreground),
            ),
            const Spacer(),
            const ActivityGraphLegend(),
          ],
        ),
        SizedBox(height: AppConstants.spacing.regular),
        SizedBox(
          width: ActivityGraphConstants.yearDropdownWidth,
          child: FSelect<int>(
            items: {for (var y in years) '$y': y},
            hint: selectedYear.toString(),
            control: FSelectControl.managed(
              initial: selectedYear,
              onChange: (y) {
                if (y != null && y != selectedYear) {
                  _removeTooltip();
                  ref.read(selectedYearProvider.notifier).setYear(y);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (y == currentYear) {
                      _scrollToToday();
                    } else {
                      _scrollController.jumpTo(0);
                    }
                  });
                }
              },
            ),
          ),
        ),
        SizedBox(height: AppConstants.spacing.regular),
        SizedBox(
          height: ActivityGraphConstants.monthLabelHeight + ActivityGraphConstants.graphHeight,
          child: asyncData.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (stats) {
              final lookup = <String, int>{for (final s in stats) s.date: s.completedSessions};
              return SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: GestureDetector(
                  onTapUp: (details) => _onCellTap(context, details.localPosition, details.globalPosition, lookup),
                  child: CustomPaint(
                    size: Size(gridWidth, ActivityGraphConstants.monthLabelHeight + ActivityGraphConstants.graphHeight),
                    painter: YearGridPainter(
                      year: selectedYear,
                      lookup: lookup,
                      cellColor: context.colors.primary,
                      emptyColor: context.colors.mutedForeground.withValues(alpha: 0.12),
                      textColor: context.colors.mutedForeground,
                      textStyle: context.typography.xs,
                      highlightDateKey: tappedDateKey,
                      highlightColor: context.colors.foreground,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _onCellTap(BuildContext context, Offset localPos, Offset globalPos, Map<String, int> lookup) {
    final x = localPos.dx - ActivityGraphConstants.dayLabelWidth;
    final y = localPos.dy - ActivityGraphConstants.monthLabelHeight;
    if (x < 0 || y < 0) return;

    final weekCol = (x / ActivityGraphConstants.cellStep).floor();
    final dayRow = (y / ActivityGraphConstants.cellStep).floor();
    if (dayRow < 0 || dayRow > 6) return;

    final selectedYear = ref.read(selectedYearProvider);
    final date = ActivityGraphUtils.dateFromGridCell(year: selectedYear, weekCol: weekCol, dayRow: dayRow);

    if (date.year != selectedYear) return;
    if (ActivityGraphUtils.isFutureDate(date)) return;

    final dateKey = ActivityGraphUtils.dateKey(date);
    final sessions = lookup[dateKey] ?? 0;
    _showTooltip(context, globalPos, dateKey, sessions);
  }
}
