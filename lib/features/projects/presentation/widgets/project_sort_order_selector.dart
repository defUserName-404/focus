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

  const ProjectSortOrderSelector({super.key, required this.selectedOrder, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return FSelect(items: {'Abc': "ASBC"});
  }
}
