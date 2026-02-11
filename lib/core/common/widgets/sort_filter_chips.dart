import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../../core/constants/app_constants.dart';
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
                child: Text(criteria.label),
              ),
          ],
        ),
      ),
    );
  }
}
