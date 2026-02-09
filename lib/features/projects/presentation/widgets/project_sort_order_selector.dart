import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Sort order enum
enum SortOrder {
  none('None'),
  ascending('Ascending'),
  descending('Descending');

  final String label;
  const SortOrder(this.label);
}

/// Widget for selecting sort order (ascending, descending, none)
class ProjectSortOrderSelector extends StatelessWidget {
  final SortOrder selectedOrder;
  final ValueChanged<SortOrder> onChanged;

  static final Map<String, SortOrder> _sortOrderItems = {
    for (final sortOrder in SortOrder.values) sortOrder.label: sortOrder,
  };

  const ProjectSortOrderSelector({super.key, required this.selectedOrder, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return FSelect<SortOrder>(items: _sortOrderItems);
  }
}

