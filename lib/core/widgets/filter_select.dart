import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class FilterSelect<T> extends StatelessWidget {
  final T selected;
  final ValueChanged<T> onChanged;
  final List<T> options;
  final String hint;
  final String? allLabel; // Label for the "All" option, null to disable
  final String Function(T option)? labelBuilder;

  const FilterSelect({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.options,
    required this.hint,
    this.allLabel,
    this.labelBuilder,
  });

  String _labelFor(T option) {
    if (labelBuilder != null) return labelBuilder!(option);
    final dynamic dynamicOption = option;
    final label = dynamicOption.label;
    if (label is String) return label;
    return option.toString();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, T> items = {};
    if (allLabel != null) {
      items[allLabel!] = null as T;
    }

    for (final option in options) {
      if (option != null) {
        items[_labelFor(option)] = option;
      }
    }

    return FSelect<T>(
      items: items,
      hint: hint,
      control: FSelectControl.managed(initial: selected, onChange: (value) => onChanged(value as T)),
    );
  }
}
