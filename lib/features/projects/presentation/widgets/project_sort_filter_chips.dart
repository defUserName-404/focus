import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../../../core/constants/layout_constants.dart';

/// Sort criteria enum for project filtering
enum SortCriteria {
  createdDate('Created Date'),
  recentlyModified('Recently Modified'),
  startDate('Start Date'),
  deadline('Deadline'),
  title('Title');

  final String label;
  const SortCriteria(this.label);
}

/// Widget displaying filter chips for sort criteria selection
class ProjectSortFilterChips extends StatelessWidget {
  final SortCriteria selectedCriteria;
  final ValueChanged<SortCriteria> onChanged;

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
            for (final criteria in SortCriteria.values)
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
