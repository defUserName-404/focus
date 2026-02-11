import 'package:flutter/widgets.dart';

extension WidgetListSpacingX on List<Widget> {
  List<Widget> withSpacing(double spacing, {bool vertical = true}) {
    if (isEmpty) return this;
    final result = <Widget>[];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) {
        result.add(vertical ? SizedBox(height: spacing) : SizedBox(width: spacing));
      }
    }
    return result;
  }
}
