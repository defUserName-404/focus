import 'package:flutter/material.dart';
import 'package:focus/core/constants/app_constants.dart';
import 'package:forui/forui.dart' as fu;

import '../../../tasks/presentation/providers/task_filter_state.dart';

class TaskSortFilterChips extends StatelessWidget {
  final TaskSortCriteria selectedCriteria;
  final ValueChanged<TaskSortCriteria> onChanged;

  const TaskSortFilterChips({super.key, required this.selectedCriteria, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.regular, vertical: AppConstants.spacing.small),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: AppConstants.spacing.small,
          children: [
            for (final criteria in TaskSortCriteria.values)
              fu.FButton(
                style: selectedCriteria == criteria ? fu.FButtonStyle.secondary() : fu.FButtonStyle.outline(),
                onPress: () => onChanged(criteria),
                child: Text(criteria.label),
              ),
          ],
        ),
      ),
    );
  }
}
