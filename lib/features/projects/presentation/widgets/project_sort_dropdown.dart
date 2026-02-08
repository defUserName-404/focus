import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Sort order enum for projects
enum ProjectSortOrder {
  createdDate('Created Date'),
  deadline('Deadline');

  final String label;
  const ProjectSortOrder(this.label);
}

/// Dropdown widget for sorting projects
class ProjectSortDropdown extends StatelessWidget {
  final ProjectSortOrder selectedSort;
  final ValueChanged<ProjectSortOrder> onChanged;

  const ProjectSortDropdown({
    super.key,
    required this.selectedSort,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FSelect<ProjectSortOrder>(
      items: {
        ProjectSortOrder.createdDate.label: ProjectSortOrder.createdDate,
        ProjectSortOrder.deadline.label: ProjectSortOrder.deadline,
      },
      control: FSelectControl.lifted(
        value: selectedSort,
        onChange: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}
