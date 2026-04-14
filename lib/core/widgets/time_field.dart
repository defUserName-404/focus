import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

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
    final selectedTime = value == null ? null : fu.FTime.fromDateTime(value!);

    return fu.FTimeField.picker(
      label: Text(label),
      hint: value == null ? 'Pick date first' : 'Select time',
      enabled: value != null,
      control: fu.FTimeFieldControl.lifted(
        time: selectedTime,
        onChange: (time) {
          if (time == null || value == null) return;
          onChanged(time.withDate(value!));
        },
      ),
      suffixBuilder: value == null
          ? null
          : (_, style, states) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(null),
                child: Opacity(
                  opacity: states.contains(WidgetState.disabled) ? 0.5 : 1,
                  child: Icon(fu.FIcons.x, size: style.iconStyle.size),
                ),
              ),
            ),
    );
  }
}
