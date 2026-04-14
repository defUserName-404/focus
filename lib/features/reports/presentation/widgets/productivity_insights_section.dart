import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/date_time_constants.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../../tasks/domain/entities/daily_session_stats.dart';
import '../../../tasks/presentation/providers/task_stats_provider.dart';
import '../providers/reports_insights_window_provider.dart';

class ProductivityInsightsSection extends ConsumerWidget {
  const ProductivityInsightsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final windowAsync = ref.watch(reportsInsightsWindowProvider);
    final window = windowAsync.value ?? InsightsWindowMode.weekly;
    final range = _dateRangeForWindow(window);
    final rangeKey = '${range.start.toShortDateKey()}|${range.end.toShortDateKey()}';
    final statsAsync = ref.watch(dailyStatsForRangeProvider(rangeKey));

    return fu.FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Productivity Insights', style: context.typography.base.copyWith(fontWeight: FontWeight.w700)),
              _InsightsWindowToggle(
                window: window,
                onChanged: (value) {
                  ref.read(reportsInsightsWindowProvider.notifier).setWindow(value);
                },
              ),
            ],
          ),
          SizedBox(height: AppConstants.spacing.regular),
          statsAsync.when(
            loading: () => const SizedBox(height: 160, child: Center(child: fu.FCircularProgress())),
            error: (err, _) => Padding(
              padding: EdgeInsets.symmetric(vertical: AppConstants.spacing.large),
              child: Center(child: Text('Error: $err')),
            ),
            data: (stats) {
              final insights = _buildInsightsData(stats: stats, window: window, range: range);
              return _InsightsContent(window: window, data: insights);
            },
          ),
        ],
      ),
    );
  }

  _DateRange _dateRangeForWindow(InsightsWindowMode window) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (window == InsightsWindowMode.weekly) {
      final weekStart = today.subtract(Duration(days: today.weekday - DateTime.monday));
      return _DateRange(start: weekStart, end: weekStart.add(const Duration(days: 6)));
    }

    final monthStart = DateTime(today.year, today.month, 1);
    final monthEnd = DateTime(today.year, today.month + 1, 0);
    return _DateRange(start: monthStart, end: monthEnd);
  }

  _InsightsData _buildInsightsData({
    required List<DailySessionStats> stats,
    required InsightsWindowMode window,
    required _DateRange range,
  }) {
    final byDate = {for (final stat in stats) stat.date: stat};

    final totalSessions = stats.fold<int>(0, (sum, stat) => sum + stat.totalSessions);
    final completedSessions = stats.fold<int>(0, (sum, stat) => sum + stat.completedSessions);

    final focusRatio = totalSessions == 0 ? 0.0 : completedSessions / totalSessions;
    final breakSessions = math.max(totalSessions - completedSessions, 0);

    final bars = window == InsightsWindowMode.weekly
        ? _weeklyBars(byDate: byDate, start: range.start)
        : _monthlyBars(byDate: byDate, monthStart: range.start);

    return _InsightsData(
      bars: bars,
      focusRatio: focusRatio,
      breakRatio: 1 - focusRatio,
      ratioLabel: _formatRatio(completedSessions, breakSessions),
    );
  }

  List<_BarDatum> _weeklyBars({required Map<String, DailySessionStats> byDate, required DateTime start}) {
    return List.generate(7, (index) {
      final date = start.add(Duration(days: index));
      final dateKey = date.toShortDateKey();
      final focusSeconds = byDate[dateKey]?.focusSeconds ?? 0;
      return _BarDatum(label: DateTimeConstants.shortWeekdayNames[date.weekday - 1], focusHours: focusSeconds / 3600);
    });
  }

  List<_BarDatum> _monthlyBars({required Map<String, DailySessionStats> byDate, required DateTime monthStart}) {
    final daysInMonth = DateTime(monthStart.year, monthStart.month + 1, 0).day;
    final leadingOffset = monthStart.weekday - 1;
    final weekCount = ((leadingOffset + daysInMonth - 1) ~/ 7) + 1;
    final weekHours = List<double>.filled(weekCount, 0);

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(monthStart.year, monthStart.month, day);
      final weekIndex = (leadingOffset + day - 1) ~/ 7;
      final focusSeconds = byDate[date.toShortDateKey()]?.focusSeconds ?? 0;
      weekHours[weekIndex] += focusSeconds / 3600;
    }

    return List.generate(weekCount, (index) {
      return _BarDatum(label: 'W${index + 1}', focusHours: weekHours[index]);
    });
  }

  String _formatRatio(int focusSessions, int breakSessions) {
    if (focusSessions == 0 && breakSessions == 0) return '0:0';
    if (focusSessions > 0 && breakSessions == 0) return '1:0';
    if (focusSessions == 0 && breakSessions > 0) return '0:1';

    final divisor = _gcd(focusSessions, breakSessions);
    return '${focusSessions ~/ divisor}:${breakSessions ~/ divisor}';
  }

  int _gcd(int a, int b) {
    var x = a.abs();
    var y = b.abs();
    while (y != 0) {
      final temp = y;
      y = x % y;
      x = temp;
    }
    return x == 0 ? 1 : x;
  }
}

class _InsightsWindowToggle extends StatelessWidget {
  final InsightsWindowMode window;
  final ValueChanged<InsightsWindowMode> onChanged;

  const _InsightsWindowToggle({required this.window, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        fu.FButton(
          style: window == InsightsWindowMode.weekly ? fu.FButtonStyle.secondary() : fu.FButtonStyle.outline(),
          onPress: () => onChanged(InsightsWindowMode.weekly),
          child: const Text('Weekly'),
        ),
        SizedBox(width: AppConstants.spacing.extraSmall),
        fu.FButton(
          style: window == InsightsWindowMode.monthly ? fu.FButtonStyle.secondary() : fu.FButtonStyle.outline(),
          onPress: () => onChanged(InsightsWindowMode.monthly),
          child: const Text('Monthly'),
        ),
      ],
    );
  }
}

class _InsightsContent extends StatelessWidget {
  final InsightsWindowMode window;
  final _InsightsData data;

  const _InsightsContent({required this.window, required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 460;

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FocusHoursChart(window: window, bars: data.bars),
              SizedBox(height: AppConstants.spacing.large),
              _FocusRatioChart(focusRatio: data.focusRatio, breakRatio: data.breakRatio, ratioLabel: data.ratioLabel),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _FocusHoursChart(window: window, bars: data.bars),
            ),
            Container(
              width: 1,
              height: 170,
              margin: EdgeInsets.symmetric(horizontal: AppConstants.spacing.large),
              color: context.colors.border,
            ),
            Expanded(
              child: _FocusRatioChart(
                focusRatio: data.focusRatio,
                breakRatio: data.breakRatio,
                ratioLabel: data.ratioLabel,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FocusHoursChart extends StatelessWidget {
  final InsightsWindowMode window;
  final List<_BarDatum> bars;

  const _FocusHoursChart({required this.window, required this.bars});

  @override
  Widget build(BuildContext context) {
    final maxHours = bars.fold<double>(0, (maxValue, bar) => math.max(maxValue, bar.focusHours));
    const barHeight = 88.0;
    final title = window == InsightsWindowMode.weekly
        ? 'Focus Hours per Day (Current Week)'
        : 'Focus Hours per Week (Current Month)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: AppConstants.spacing.regular),
        SizedBox(
          height: 142,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final bar in bars)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.extraSmall),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _formatHours(bar.focusHours),
                          style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                        ),
                        SizedBox(height: AppConstants.spacing.extraSmall),
                        Container(
                          height: maxHours <= 0 ? 2 : (bar.focusHours / maxHours * barHeight).clamp(2.0, barHeight),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [context.colors.primary.withValues(alpha: 0.75), context.colors.primary],
                            ),
                            borderRadius: BorderRadius.circular(AppConstants.border.radius.small),
                          ),
                        ),
                        SizedBox(height: AppConstants.spacing.small),
                        Text(bar.label, style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatHours(double value) {
    if (value <= 0) return '0h';
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() < 0.05) {
      return '${rounded.toInt()}h';
    }
    return '${value.toStringAsFixed(1)}h';
  }
}

class _FocusRatioChart extends StatelessWidget {
  final double focusRatio;
  final double breakRatio;
  final String ratioLabel;

  const _FocusRatioChart({required this.focusRatio, required this.breakRatio, required this.ratioLabel});

  @override
  Widget build(BuildContext context) {
    final focusPercent = (focusRatio * 100).round().clamp(0, 100);
    final breakPercent = 100 - focusPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Focus Ratio', style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: AppConstants.spacing.regular),
        Center(
          child: SizedBox(
            width: 96,
            height: 96,
            child: CustomPaint(
              painter: _RatioRingPainter(
                focusRatio: focusRatio,
                focusColor: context.colors.primary,
                breakColor: context.colors.mutedForeground.withValues(alpha: 0.25),
              ),
              child: Center(
                child: Text(ratioLabel, style: context.typography.sm.copyWith(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
        SizedBox(height: AppConstants.spacing.regular),
        Text(
          '$focusPercent% Focus',
          style: context.typography.sm.copyWith(color: context.colors.primary, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: AppConstants.spacing.extraSmall),
        Text('$breakPercent% Break', style: context.typography.sm.copyWith(color: context.colors.mutedForeground)),
      ],
    );
  }
}

class _RatioRingPainter extends CustomPainter {
  final double focusRatio;
  final Color focusColor;
  final Color breakColor;

  const _RatioRingPainter({required this.focusRatio, required this.focusColor, required this.breakColor});

  @override
  void paint(Canvas canvas, Size size) {
    final clampedRatio = focusRatio.clamp(0.0, 1.0);
    const strokeWidth = 10.0;
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final basePaint = Paint()
      ..color = breakColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final focusPaint = Paint()
      ..color = focusColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint);

    if (clampedRatio > 0) {
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * clampedRatio, false, focusPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RatioRingPainter oldDelegate) {
    return oldDelegate.focusRatio != focusRatio ||
        oldDelegate.focusColor != focusColor ||
        oldDelegate.breakColor != breakColor;
  }
}

class _DateRange {
  final DateTime start;
  final DateTime end;

  const _DateRange({required this.start, required this.end});
}

class _InsightsData {
  final List<_BarDatum> bars;
  final double focusRatio;
  final double breakRatio;
  final String ratioLabel;

  const _InsightsData({
    required this.bars,
    required this.focusRatio,
    required this.breakRatio,
    required this.ratioLabel,
  });
}

class _BarDatum {
  final String label;
  final double focusHours;

  const _BarDatum({required this.label, required this.focusHours});
}
