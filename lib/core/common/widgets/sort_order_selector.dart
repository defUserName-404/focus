import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../sort_order.dart';

class SortOrderSelector<T extends SortOrder> extends StatelessWidget {
  final T selectedOrder;
  final ValueChanged<T> onChanged;
  final List<T> orderOptions;

  const SortOrderSelector({
    super.key,
    required this.selectedOrder,
    required this.onChanged,
    required this.orderOptions,
  });

  @override
  Widget build(BuildContext context) {
    return FSelect<T>(
      hint: 'Order',
      control: FSelectControl.managed(
        initial: selectedOrder,
        onChange: (value) {
          if (value != null) onChanged(value);
        },
      ),
      items: {for (final order in orderOptions) order.label: order},
    );
  }
}