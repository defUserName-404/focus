import 'package:flutter_test/flutter_test.dart';
import 'package:focus/features/tasks/domain/entities/estimate_accuracy_stat.dart';
import 'package:focus/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:focus/features/tasks/domain/entities/time_breakdown_item.dart';
import 'package:focus/features/tasks/domain/services/report_insights_calculator.dart';

void main() {
  group('ReportInsightsCalculator', () {
    const daily = RecurrenceRule(frequency: RecurrenceFrequency.daily);
    final anchor = DateTime(2026, 8, 1);

    test('buildHabitConsistency computes rate and streak per habit', () {
      final stats = ReportInsightsCalculator.buildHabitConsistency(
        sources: [
          HabitConsistencySource(
            taskId: 1,
            title: 'Meditate',
            rule: daily,
            anchor: anchor,
            completionDates: [DateTime(2026, 8, 1), DateTime(2026, 8, 2), DateTime(2026, 8, 3)],
          ),
        ],
        from: DateTime(2026, 8, 1),
        to: DateTime(2026, 8, 4),
        now: DateTime(2026, 8, 4),
      );
      expect(stats, hasLength(1));
      expect(stats.first.completionRate, 0.75);
      expect(stats.first.currentStreak, 3);
      expect(stats.first.longestStreak, 3);
    });

    test('buildEstimateAccuracy reports typical underestimate bias', () {
      final summary = ReportInsightsCalculator.buildEstimateAccuracy(const [
        EstimateAccuracyStat(taskId: 1, title: 'A', estimatedMinutes: 60, actualMinutes: 90),
        EstimateAccuracyStat(taskId: 2, title: 'B', estimatedMinutes: 40, actualMinutes: 50),
      ]);
      expect(summary.hasData, isTrue);
      // (140 - 100) / 100 = 0.4
      expect(summary.typicalBiasRatio, closeTo(0.4, 0.0001));
    });

    test('buildEstimateAccuracy returns zero bias for empty input', () {
      final summary = ReportInsightsCalculator.buildEstimateAccuracy(const []);
      expect(summary.hasData, isFalse);
      expect(summary.typicalBiasRatio, 0);
    });

    test('buildThroughputBuckets fills daily labels for weekly window', () {
      final buckets = ReportInsightsCalculator.buildThroughputBuckets(
        completedByDate: {'2026-08-03': 2, '2026-08-05': 1},
        from: DateTime(2026, 8, 3),
        to: DateTime(2026, 8, 9),
        weeklyWindow: true,
      );
      expect(buckets, hasLength(7));
      expect(buckets.first.label, 'Mon');
      expect(buckets.first.completedCount, 2);
      expect(buckets[2].completedCount, 1);
    });

    test('buildThroughputBuckets groups into weeks for monthly window', () {
      final buckets = ReportInsightsCalculator.buildThroughputBuckets(
        completedByDate: {'2026-08-01': 1, '2026-08-10': 3, '2026-08-20': 2},
        from: DateTime(2026, 8, 1),
        to: DateTime(2026, 8, 31),
        weeklyWindow: false,
      );
      expect(buckets.length, greaterThanOrEqualTo(4));
      expect(buckets.fold<int>(0, (sum, b) => sum + b.completedCount), 6);
    });

    test('normalizeBreakdown drops zeros and sorts descending', () {
      final items = ReportInsightsCalculator.normalizeBreakdown(const [
        TimeBreakdownItem(id: 1, name: 'Low', focusSeconds: 60),
        TimeBreakdownItem(id: 2, name: 'Zero', focusSeconds: 0),
        TimeBreakdownItem(id: 3, name: 'High', focusSeconds: 600),
      ]);
      expect(items.map((e) => e.name).toList(), ['High', 'Low']);
    });

    test('buildCsvExport escapes commas and includes sections', () {
      final csv = ReportInsightsCalculator.buildCsvExport(
        windowLabel: 'weekly',
        startDate: '2026-08-03',
        endDate: '2026-08-09',
        habits: const [],
        estimates: const EstimateAccuracySummary(tasks: [], typicalBiasRatio: 0.25),
        byProject: const [TimeBreakdownItem(id: 1, name: 'Work, Inc', focusSeconds: 3600)],
        byTag: const [],
        throughput: ReportInsightsCalculator.buildThroughputStats(
          completedByDate: const {},
          from: DateTime(2026, 8, 3),
          to: DateTime(2026, 8, 9),
          weeklyWindow: true,
          averageCycleSeconds: 7200,
          cycleSampleCount: 1,
        ),
      );
      expect(csv, contains('section,key,value,extra'));
      expect(csv, contains('"Work, Inc"'));
      expect(csv, contains('typical_bias_percent'));
      expect(csv, contains('average_cycle_hours'));
    });
  });
}
