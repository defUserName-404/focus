import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../constants/app_constants.dart';
import '../utils/datetime_formatter.dart';

/// Reusable time picker field that pairs with an [FDateField.calendar].
///
/// Displays a button that opens a [showTimePicker] dialog when a date has
/// been selected. Disabled with a hint when [value] is `null` (no date yet).
class TimeField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const TimeField({super.key, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: fu.FButton(
            style: fu.FButtonStyle.outline(),
            onPress: value == null
                ? null
                : () async {
                    final initial = TimeOfDay.fromDateTime(value!);
                    final selected = await showTimePicker(context: context, initialTime: initial);
                    if (selected == null) return;
                    onChanged(DateTime(value!.year, value!.month, value!.day, selected.hour, selected.minute));
                  },
            child: Text(value == null ? '$label (pick date first)' : '$label: ${value!.toTimeString()}'),
          ),
        ),
        if (value != null) ...[
          SizedBox(width: AppConstants.spacing.small),
          fu.FButton(
            style: fu.FButtonStyle.ghost(),
            onPress: () => onChanged(DateTime(value!.year, value!.month, value!.day)),
            child: const Text('Clear'),
          ),
        ],
      ],
    );
  }
}
