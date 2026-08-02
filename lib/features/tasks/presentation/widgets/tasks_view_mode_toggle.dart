import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/tasks_view_mode_provider.dart';

class TasksViewModeToggle extends StatelessWidget {
  final TasksViewMode mode;
  final ValueChanged<TasksViewMode> onChanged;

  const TasksViewModeToggle({super.key, required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final value in TasksViewMode.values) ...[
          if (value != TasksViewMode.values.first) SizedBox(width: AppConstants.spacing.extraSmall),
          fu.FButton(
            size: .sm,
            mainAxisSize: .min,
            variant: mode == value ? .secondary : .outline,
            onPress: () => onChanged(value),
            child: Text(value.label, style: context.typography.xs),
          ),
        ],
      ],
    );
  }
}
