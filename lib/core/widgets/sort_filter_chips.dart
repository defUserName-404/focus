import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/platform_utils.dart';
import '../config/theme/app_theme.dart';
import '../sort_criteria.dart';

class SortFilterChips<T extends SortCriteria> extends StatelessWidget {
  final T selectedCriteria;
  final ValueChanged<T> onChanged;
  final List<T> criteriaOptions;

  const SortFilterChips({
    super.key,
    required this.selectedCriteria,
    required this.onChanged,
    required this.criteriaOptions,
  });

  @override
  Widget build(BuildContext context) {
    if (!context.isCompact) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.regular, vertical: AppConstants.spacing.small),
        child: FSelect<T>(
          hint: 'Sort by',
          control: FSelectControl.managed(
            initial: selectedCriteria,
            onChange: (value) {
              if (value != null) onChanged(value);
            },
          ),
          items: {for (final criteria in criteriaOptions) criteria.label: criteria},
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.regular, vertical: AppConstants.spacing.small),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: AppConstants.spacing.small,
          children: [
            for (final criteria in criteriaOptions)
              FButton(
                style: selectedCriteria == criteria ? FButtonStyle.secondary() : FButtonStyle.outline(),
                onPress: () => onChanged(criteria),
                child: Text(criteria.label, style: context.typography.xs),
              ),
          ],
        ),
      ),
    );
  }
}
