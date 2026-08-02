import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart' as fu;

import '../constants/layout_breakpoints.dart';

/// Master-detail layout with a resizable master pane on wide screens.
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

    return fu.FResizable(
      axis: .horizontal,
      children: [
        fu.FResizableRegion.fixed(
          extent: masterWidth,
          minExtent: 280,
          builder: (context, _, child) => child!,
          child: master,
        ),
        fu.FResizableRegion.flex(
          flex: 1,
          minFlex: 1,
          builder: (context, _, child) => child!,
          child: detail ?? emptyDetail,
        ),
      ],
    );
  }
}
