import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Provides a shared [groupId] so nested [FSelect] dropdowns stay inside an
/// outer [FPopover] tap region (ForUI nested-popover contract).
class FilterSelectGroup extends InheritedWidget {
  final Object groupId;

  const FilterSelectGroup({super.key, required this.groupId, required super.child});

  static Object? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FilterSelectGroup>()?.groupId;
  }

  @override
  bool updateShouldNotify(FilterSelectGroup oldWidget) => groupId != oldWidget.groupId;
}

class FilterSelect<T> extends StatelessWidget {
  final T selected;
  final ValueChanged<T> onChanged;
  final List<T> options;
  final String hint;
  final String? allLabel; // Label for the "All" option, null to disable
  final String Function(T option)? labelBuilder;
  final Object? groupId;

  const FilterSelect({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.options,
    required this.hint,
    this.allLabel,
    this.labelBuilder,
    this.groupId,
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

    final resolvedGroupId = groupId ?? FilterSelectGroup.maybeOf(context);

    return FSelect<T>(
      items: items,
      hint: hint,
      contentGroupId: resolvedGroupId,
      control: FSelectControl.managed(initial: selected, onChange: (value) => onChanged(value as T)),
    );
  }
}
