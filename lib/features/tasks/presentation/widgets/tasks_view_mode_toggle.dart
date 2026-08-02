import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/list_toolbar.dart';
import '../providers/tasks_view_mode_provider.dart';

class TasksViewModeToggle extends StatelessWidget {
  final TasksViewMode mode;
  final ValueChanged<TasksViewMode> onChanged;
  final bool? iconOnly;

  const TasksViewModeToggle({super.key, required this.mode, required this.onChanged, this.iconOnly});

  IconData _iconFor(TasksViewMode value) => switch (value) {
    TasksViewMode.list => fu.FLucideIcons.list,
    TasksViewMode.board => fu.FLucideIcons.layoutGrid,
    TasksViewMode.calendar => fu.FLucideIcons.calendar,
  };

  @override
  Widget build(BuildContext context) {
    final useIcons = iconOnly ?? ListToolbarLayout.iconOnlyOf(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final value in TasksViewMode.values) ...[
          if (value != TasksViewMode.values.first) SizedBox(width: AppConstants.spacing.extraSmall),
          if (useIcons)
            fu.FTooltip(
              tipBuilder: (context, _) => Text(value.label),
              child: fu.FButton.icon(
                size: .sm,
                variant: mode == value ? .secondary : .outline,
                semanticsLabel: value.label,
                onPress: () => onChanged(value),
                child: Icon(_iconFor(value)),
              ),
            )
          else
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
