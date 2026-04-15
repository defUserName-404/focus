import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/upcoming_calendar_view_provider.dart';

class CalendarViewToggle extends StatelessWidget {
  final CalendarViewMode view;
  final ValueChanged<CalendarViewMode> onChanged;

  const CalendarViewToggle({super.key, required this.view, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        fu.FButton(
          style: view == CalendarViewMode.week ? fu.FButtonStyle.secondary() : fu.FButtonStyle.outline(),
          onPress: () => onChanged(CalendarViewMode.week),
          child: Text('Week', style: context.typography.xs),
        ),
        SizedBox(width: AppConstants.spacing.extraSmall),
        fu.FButton(
          style: view == CalendarViewMode.month ? fu.FButtonStyle.secondary() : fu.FButtonStyle.outline(),
          onPress: () => onChanged(CalendarViewMode.month),
          child: Text('Month', style: context.typography.xs),
        ),
      ],
    );
  }
}
