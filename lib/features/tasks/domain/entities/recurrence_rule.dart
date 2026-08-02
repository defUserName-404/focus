import 'package:dart_mappable/dart_mappable.dart';
import 'package:meta/meta.dart';

part 'recurrence_rule.mapper.dart';

/// How often a recurring task / habit repeats.
@MappableEnum()
enum RecurrenceFrequency { daily, weekly, monthly }

/// Practical recurrence definition stored as JSON on [Task.recurrenceRule].
///
/// Weekdays use Dart's [DateTime.weekday] convention (Mon=1 … Sun=7).
@immutable
@MappableClass()
class RecurrenceRule with RecurrenceRuleMappable {
  /// Base cadence.
  final RecurrenceFrequency frequency;

  /// Repeat every N periods (minimum 1).
  final int interval;

  /// For [RecurrenceFrequency.weekly]: which weekdays fire.
  /// When null/empty, the weekday of the anchor date is used.
  final List<int>? byWeekday;

  /// For [RecurrenceFrequency.monthly]: day of month (1–31).
  /// When null, the day-of-month of the anchor is used. Clamped to month length.
  final int? byMonthDay;

  /// Optional density hint (e.g. "3 times per week"). Expansion still uses
  /// [byWeekday] / interval; this is reserved for UI / future schedulers.
  final int? timesPerPeriod;

  /// Inclusive end of the series (date-level).
  final DateTime? until;

  /// Maximum number of occurrences from the series start (inclusive).
  final int? count;

  const RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.byWeekday,
    this.byMonthDay,
    this.timesPerPeriod,
    this.until,
    this.count,
  });

  /// Normalized interval, always ≥ 1.
  int get effectiveInterval => interval < 1 ? 1 : interval;

  /// Parse from JSON map, or `null` if [json] is null/empty.
  static RecurrenceRule? tryParse(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return null;
    return RecurrenceRuleMapper.fromMap(json);
  }

  /// Parse from a JSON string stored in Drift.
  static RecurrenceRule? tryParseJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    return RecurrenceRuleMapper.fromJson(raw);
  }
}
