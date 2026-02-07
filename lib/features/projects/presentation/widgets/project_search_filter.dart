import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/layout_constants.dart';

typedef OnSearchChanged = void Function(String);
typedef OnFilterChanged = void Function(String?);

class ProjectSearchFilter extends StatelessWidget {
  final TextEditingController controller;
  final OnSearchChanged onSearchChanged;
  final String? selectedFilter;
  final List<String> filters;
  final OnFilterChanged onFilterChanged;

  const ProjectSearchFilter({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    required this.selectedFilter,
    required this.filters,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        fu.FTextField(control: .managed(), hint: 'Search projects'),
        SizedBox(height: LayoutConstants.spacing.paddingSmall),
        Row(
          children: [
            Expanded(
              child: fu.FSelect<String?>(
                // value: selectedFilter,
                hint: 'All status',
                items: {'Stirng': 'Active', 'What': 'The'},
                // itemLabel: (v) => v ?? 'All',
                // onChanged: onFilterChanged,
              ),
            ),
            SizedBox(width: LayoutConstants.spacing.paddingSmall),
            fu.FButton.icon(
              // pr: fu.FIcon.filter_list,
              child: const Text('Filter'),
              onPress: () {
                // Keep behaviour simple: open same select via focus or external handler.
              },
            ),
          ],
        ),
      ],
    );
  }
}
