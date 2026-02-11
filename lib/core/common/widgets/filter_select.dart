import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

abstract interface class FilterSelectable {
  String get label;
}

class FilterSelect<T extends FilterSelectable?> extends StatelessWidget {
  final T selected;
  final ValueChanged<T> onChanged;
  final List<T> options;
  final String hint;
  final String allLabel; // Label for the "All" option

  const FilterSelect({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.options,
    required this.hint,
    this.allLabel = 'All',
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, T> items = {allLabel: null as T};
    for (final option in options) {
      if (option != null) {
        // Ensure null is not added as a key, but only as the 'All' value.
        items[option.label] = option;
      }
    }

    return FSelect<T>(
      items: items,
      hint: hint,
      control: FSelectControl.managed(initial: selected, onChange: (value) => onChanged(value as T)),
    );
  }
}
