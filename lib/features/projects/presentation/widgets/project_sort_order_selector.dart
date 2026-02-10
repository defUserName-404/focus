import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../providers/project_list_filter_state.dart';

/// Widget for selecting sort order (ascending, descending, none)
class ProjectSortOrderSelector extends StatelessWidget {
  final ProjectSortOrder selectedOrder;
  final ValueChanged<ProjectSortOrder> onChanged;

  static final Map<String, ProjectSortOrder> _sortOrderItems = {
    for (final sortOrder in ProjectSortOrder.values) sortOrder.label: sortOrder,
  };

  const ProjectSortOrderSelector({super.key, required this.selectedOrder, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return FSelect<ProjectSortOrder>(
      onSaved: (value) {
        if (value != null) onChanged(value);
      },
      items: _sortOrderItems,
    );
  }
}
