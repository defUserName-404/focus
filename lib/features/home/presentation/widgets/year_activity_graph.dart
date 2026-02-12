import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../tasks/presentation/providers/task_stats_provider.dart';

// ── Layout constants ────────────────────────────────────────────────────────

const double _kCellSize = 12;
const double _kCellGap = 3;
const double _kCellStep = _kCellSize + _kCellGap;
const double _kDayLabelWidth = 24;
const double _kMonthLabelHeight = 16;
const double _kGraphHeight = 7 * _kCellStep - _kCellGap;

/// Continuous GitHub-style activity graph for a selected year.
///
/// All 12 months flow together in a single horizontally-scrollable grid.
/// Each column is a calendar week; each row is a weekday (Mon–Sun).
/// Tapping a day cell shows a tooltip with that day's completed sessions.
class YearActivityGraph extends ConsumerStatefulWidget {
  const YearActivityGraph({super.key});

  @override
  ConsumerState<YearActivityGraph> createState() => _YearActivityGraphState();
}

class _YearActivityGraphState extends ConsumerState<YearActivityGraph> {
  late int _selectedYear;
  late final ScrollController _scrollController;
  OverlayEntry? _tooltip;
  String? _tappedDateKey;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
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
    final now = DateTime.now();
    if (_selectedYear != now.year) return;
    final jan1 = DateTime(_selectedYear, 1, 1);
    final dayOfYear = now.difference(jan1).inDays;
    final weekIndex = (dayOfYear + (jan1.weekday - 1)) ~/ 7;
    final offset = weekIndex * _kCellStep;
    _scrollController.jumpTo(offset.clamp(0.0, _scrollController.position.maxScrollExtent));
  }

  // ── Tooltip handling ──────────────────────────────────────────────────────

  void _showTooltip(BuildContext context, Offset globalPos, String dateKey, int sessions) {
    _removeTooltip();
    setState(() => _tappedDateKey = dateKey);

    final overlay = Overlay.of(context);
    _tooltip = OverlayEntry(
      builder: (ctx) {
        const tooltipW = 140.0;
        const tooltipH = 40.0;
        final dx = (globalPos.dx - tooltipW / 2).clamp(8.0, MediaQuery.of(ctx).size.width - tooltipW - 8);
        final dy = globalPos.dy - tooltipH - 12;

        return Positioned(
          left: dx,
          top: dy,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: tooltipW,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.colors.foreground,
                borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
              ),
              child: Text(
                '$sessions session${sessions == 1 ? '' : 's'} on $dateKey',
                textAlign: TextAlign.center,
                style: context.typography.xs.copyWith(color: context.colors.background, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(_tooltip!);

    Future.delayed(const Duration(seconds: 2), _removeTooltip);
  }

  void _removeTooltip() {
    _tooltip?.remove();
    _tooltip?.dispose();
    _tooltip = null;
    if (_tappedDateKey != null && mounted) {
      setState(() => _tappedDateKey = null);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final years = List.generate(now.year - 2019, (i) => now.year - i);

    // Full year in one query.
    final startDate = '$_selectedYear-01-01';
    final endDate = '$_selectedYear-12-31';
    final rangeKey = '$startDate|$endDate';
    final asyncData = ref.watch(dailyStatsForRangeProvider(rangeKey));

    // Total weeks to compute grid width.
    final jan1 = DateTime(_selectedYear, 1, 1);
    final dec31 = DateTime(_selectedYear, 12, 31);
    final totalWeeks = _weekIndex(dec31, jan1) + 1;
    final gridWidth = _kDayLabelWidth + totalWeeks * _kCellStep;

    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Activity',
                style: context.typography.sm.copyWith(fontWeight: FontWeight.w600, color: context.colors.foreground),
              ),
              const Spacer(),
              _buildLegend(context),
            ],
          ),
          SizedBox(height: AppConstants.spacing.regular),
          // Year dropdown
          SizedBox(
            height: 30,
            child: DropdownButton<int>(
              value: _selectedYear,
              underline: const SizedBox.shrink(),
              isDense: true,
              style: context.typography.xs.copyWith(fontWeight: FontWeight.w600, color: context.colors.foreground),
              icon: Icon(Icons.keyboard_arrow_down, size: 16, color: context.colors.mutedForeground),
              items: years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
              onChanged: (y) {
                if (y != null && y != _selectedYear) {
                  _removeTooltip();
                  setState(() => _selectedYear = y);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (y == now.year) {
                      _scrollToToday();
                    } else {
                      _scrollController.jumpTo(0);
                    }
                  });
                }
              },
            ),
          ),
          SizedBox(height: AppConstants.spacing.regular),
          // Continuous graph
          SizedBox(
            height: _kMonthLabelHeight + _kGraphHeight,
            child: asyncData.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (stats) {
                final lookup = <String, int>{};
                for (final s in stats) {
                  lookup[s.date] = s.completedSessions;
                }

                return SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: GestureDetector(
                    onTapUp: (details) =>
                        _onCellTap(context, details.localPosition, details.globalPosition, lookup, jan1),
                    child: CustomPaint(
                      size: Size(gridWidth, _kMonthLabelHeight + _kGraphHeight),
                      painter: _YearGridPainter(
                        year: _selectedYear,
                        lookup: lookup,
                        cellColor: context.colors.primary,
                        emptyColor: context.colors.mutedForeground.withValues(alpha: 0.12),
                        textColor: context.colors.mutedForeground,
                        textStyle: context.typography.xs,
                        highlightDateKey: _tappedDateKey,
                        highlightColor: context.colors.foreground,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onCellTap(BuildContext context, Offset localPos, Offset globalPos, Map<String, int> lookup, DateTime jan1) {
    final x = localPos.dx - _kDayLabelWidth;
    final y = localPos.dy - _kMonthLabelHeight;
    if (x < 0 || y < 0) return;

    final weekCol = (x / _kCellStep).floor();
    final dayRow = (y / _kCellStep).floor();
    if (dayRow < 0 || dayRow > 6) return;

    final firstMonday = jan1.subtract(Duration(days: (jan1.weekday - 1) % 7));
    final date = firstMonday.add(Duration(days: weekCol * 7 + dayRow));

    if (date.year != _selectedYear) return;
    final now = DateTime.now();
    if (date.isAfter(DateTime(now.year, now.month, now.day))) return;

    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final sessions = lookup[dateKey] ?? 0;
    _showTooltip(context, globalPos, dateKey, sessions);
  }

  Widget _buildLegend(BuildContext context) {
    final emptyColor = context.colors.mutedForeground.withValues(alpha: 0.12);
    final cellColor = context.colors.primary;
    final levels = [
      emptyColor,
      cellColor.withValues(alpha: 0.25),
      cellColor.withValues(alpha: 0.50),
      cellColor.withValues(alpha: 0.75),
      cellColor,
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Less', style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
        SizedBox(width: AppConstants.spacing.small),
        ...levels.map(
          (color) => Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
        ),
        SizedBox(width: AppConstants.spacing.small),
        Text('More', style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
      ],
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────

int _weekIndex(DateTime date, DateTime jan1) {
  final firstMonday = jan1.subtract(Duration(days: (jan1.weekday - 1) % 7));
  return date.difference(firstMonday).inDays ~/ 7;
}

// ── Painter ─────────────────────────────────────────────────────────────────

class _YearGridPainter extends CustomPainter {
  final int year;
  final Map<String, int> lookup;
  final Color cellColor;
  final Color emptyColor;
  final Color textColor;
  final TextStyle textStyle;
  final String? highlightDateKey;
  final Color highlightColor;

  _YearGridPainter({
    required this.year,
    required this.lookup,
    required this.cellColor,
    required this.emptyColor,
    required this.textColor,
    required this.textStyle,
    this.highlightDateKey,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final jan1 = DateTime(year, 1, 1);
    final dec31 = DateTime(year, 12, 31);
    final totalWeeks = _weekIndex(dec31, jan1) + 1;

    // ── Month labels along the top ──
    int lastLabelWeek = -3;
    for (int m = 1; m <= 12; m++) {
      final firstOfMonth = DateTime(year, m, 1);
      final week = _weekIndex(firstOfMonth, jan1);
      if (week - lastLabelWeek < 2) continue;
      lastLabelWeek = week;
      final tp = TextPainter(
        text: TextSpan(
          text: _shortMonth(m),
          style: textStyle.copyWith(color: textColor, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(_kDayLabelWidth + week * _kCellStep, 0));
    }

    // ── Day-of-week labels (M, W, F) ──
    const dayLabels = {1: 'M', 3: 'W', 5: 'F'};
    for (final entry in dayLabels.entries) {
      final tp = TextPainter(
        text: TextSpan(
          text: entry.value,
          style: textStyle.copyWith(color: textColor, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final y = _kMonthLabelHeight + entry.key * _kCellStep + (_kCellSize - tp.height) / 2;
      tp.paint(canvas, Offset(0, y));
    }

    // ── Cells ──
    final highlightPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final firstMonday = jan1.subtract(Duration(days: (jan1.weekday - 1) % 7));

    for (int week = 0; week < totalWeeks; week++) {
      for (int dayRow = 0; dayRow < 7; dayRow++) {
        final date = firstMonday.add(Duration(days: week * 7 + dayRow));

        if (date.year != year) continue;
        if (date.isAfter(today)) continue;

        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final sessions = lookup[dateKey] ?? 0;

        final x = _kDayLabelWidth + week * _kCellStep;
        final y = _kMonthLabelHeight + dayRow * _kCellStep;

        final rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, _kCellSize, _kCellSize), const Radius.circular(2));

        final color = sessions == 0 ? emptyColor : cellColor.withValues(alpha: _intensity(sessions));
        canvas.drawRRect(rect, Paint()..color = color);

        if (dateKey == highlightDateKey) {
          canvas.drawRRect(rect, highlightPaint);
        }
      }
    }
  }

  double _intensity(int sessions) {
    if (sessions <= 0) return 0;
    if (sessions == 1) return 0.25;
    if (sessions == 2) return 0.50;
    if (sessions <= 4) return 0.75;
    return 1.0;
  }

  static String _shortMonth(int m) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[m - 1];
  }

  @override
  bool shouldRepaint(covariant _YearGridPainter old) =>
      lookup != old.lookup || year != old.year || highlightDateKey != old.highlightDateKey;
}
