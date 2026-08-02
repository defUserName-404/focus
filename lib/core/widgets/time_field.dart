import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../utils/date_time_utils.dart';

/// Reusable time picker field that pairs with an [fu.FDateField.calendar].
///
/// Uses ForUI's picker-only time field for visual consistency with other
/// form inputs. Clearing time also clears the bound date-time value.
class TimeField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const TimeField({super.key, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final localValue = value == null ? null : DateTimeUtils.toLocalWallClock(value!);
    final selectedTime = localValue == null ? null : fu.FTime.fromDateTime(localValue);

    return fu.FTimeField.picker(
      label: Text(label),
      hint: localValue == null ? 'Pick date first' : 'Select time',
      enabled: localValue != null,
      control: fu.FTimeFieldControl.lifted(
        time: selectedTime,
        onChange: (time) {
          if (time == null || localValue == null) return;
          onChanged(DateTimeUtils.combineLocalDateAndTime(localValue, hour: time.hour, minute: time.minute));
        },
      ),
      suffixBuilder: localValue == null
          ? null
          : (_, style, variants) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(null),
                child: Opacity(
                  opacity: variants.contains(fu.FTextFieldVariant.disabled) ? 0.5 : 1,
                  child: Icon(fu.FLucideIcons.x, size: style.iconStyle.resolve(variants).size ?? 18),
                ),
              ),
            ),
    );
  }
}
