import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../constants/app_constants.dart';

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

    return Row(
      children: [
        Expanded(
          child: fu.FTimeField.picker(
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
          ),
        ),
        if (value != null) ...[
          SizedBox(width: AppConstants.spacing.small),
          fu.FButton.icon(
            style: fu.FButtonStyle.ghost(),
            onPress: () => onChanged(null),
            child: const Icon(fu.FIcons.x),
          ),
        ],
      ],
    );
  }
}
