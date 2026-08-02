import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/recurrence_rule.dart';

enum RecurrencePreset { none, daily, weekdays, weekly }

extension RecurrencePresetLabel on RecurrencePreset {
  String get label => switch (this) {
    RecurrencePreset.none => 'None',
    RecurrencePreset.daily => 'Daily',
    RecurrencePreset.weekdays => 'Weekdays',
    RecurrencePreset.weekly => 'Weekly',
  };
}

/// Habit toggle + simple recurrence presets for create/edit task forms.
class TaskRecurrenceFields extends StatelessWidget {
  final bool isHabit;
  final RecurrencePreset preset;
  final ValueChanged<bool> onHabitChanged;
  final ValueChanged<RecurrencePreset> onPresetChanged;

  const TaskRecurrenceFields({
    super.key,
    required this.isHabit,
    required this.preset,
    required this.onHabitChanged,
    required this.onPresetChanged,
  });

  static RecurrencePreset presetFromRule(RecurrenceRule? rule) {
    if (rule == null) return RecurrencePreset.none;
    if (rule.frequency == RecurrenceFrequency.daily && rule.effectiveInterval == 1) {
      return RecurrencePreset.daily;
    }
    if (rule.frequency == RecurrenceFrequency.weekly &&
        rule.byWeekday != null &&
        rule.byWeekday!.length == 5 &&
        const {1, 2, 3, 4, 5}.difference(rule.byWeekday!.toSet()).isEmpty) {
      return RecurrencePreset.weekdays;
    }
    if (rule.frequency == RecurrenceFrequency.weekly) {
      return RecurrencePreset.weekly;
    }
    return RecurrencePreset.daily;
  }

  static RecurrenceRule? ruleForPreset(RecurrencePreset preset, {DateTime? anchor}) {
    final weekday = (anchor ?? DateTime.now()).weekday;
    return switch (preset) {
      RecurrencePreset.none => null,
      RecurrencePreset.daily => const RecurrenceRule(frequency: RecurrenceFrequency.daily),
      RecurrencePreset.weekdays => const RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        byWeekday: [1, 2, 3, 4, 5],
      ),
      RecurrencePreset.weekly => RecurrenceRule(frequency: RecurrenceFrequency.weekly, byWeekday: [weekday]),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      spacing: AppConstants.spacing.small,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Habit', style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
            ),
            FSwitch(value: isHabit, onChange: onHabitChanged),
          ],
        ),
        Align(
          alignment: .centerLeft,
          child: Text('Repeat', style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
        ),
        Wrap(
          spacing: AppConstants.spacing.small,
          runSpacing: AppConstants.spacing.small,
          children: [
            for (final option in RecurrencePreset.values)
              FButton(
                size: .sm,
                mainAxisSize: .min,
                variant: preset == option ? .secondary : .outline,
                onPress: () => onPresetChanged(option),
                child: Text(option.label),
              ),
          ],
        ),
      ],
    );
  }
}
