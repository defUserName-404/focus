import 'package:flutter/material.dart';

import '../constants/layout_breakpoints.dart';

class MasterDetailLayout extends StatelessWidget {
  final Widget master;
  final Widget? detail;
  final Widget emptyDetail;
  final double masterWidth;

  const MasterDetailLayout({
    super.key,
    required this.master,
    this.detail,
    required this.emptyDetail,
    this.masterWidth = 360,
  });

  @override
  Widget build(BuildContext context) {
    final sizeClass = LayoutBreakpoints.getWindowSizeClass(context);

    if (sizeClass == WindowSizeClass.compact) {
      return detail ?? master;
    }

    return Row(
      children: [
        SizedBox(width: masterWidth, child: master),
        const VerticalDivider(width: 1),
        Expanded(child: detail ?? emptyDetail),
      ],
    );
  }
}
