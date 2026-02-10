import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../../../core/constants/layout_constants.dart';
import '../providers/project_list_filter_state.dart';

/// Widget displaying filter chips for sort criteria selection
class ProjectSortFilterChips extends StatelessWidget {
  final ProjectSortCriteria selectedCriteria;
  final ValueChanged<ProjectSortCriteria> onChanged;

  const ProjectSortFilterChips({super.key, required this.selectedCriteria, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: LayoutConstants.spacing.paddingRegular,
        vertical: LayoutConstants.spacing.paddingSmall,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: LayoutConstants.spacing.paddingSmall,
          children: [
            for (final criteria in ProjectSortCriteria.values)
              FButton(
                style: selectedCriteria == criteria ? FButtonStyle.secondary() : FButtonStyle.outline(),
                onPress: () => onChanged(criteria),
                child: Text(criteria.label),
              ),
          ],
        ),
      ),
    );
  }
}
