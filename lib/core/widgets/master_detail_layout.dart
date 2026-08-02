import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart' as fu;

import '../constants/layout_breakpoints.dart';

/// Master-detail layout with a resizable master pane on wide screens.
class MasterDetailLayout extends StatelessWidget {
  final Widget master;
  final Widget? detail;
  final Widget emptyDetail;
  final double masterWidth;
  final ValueChanged<double>? onMasterWidthChanged;
  final double minMasterWidth;

  const MasterDetailLayout({
    super.key,
    required this.master,
    this.detail,
    required this.emptyDetail,
    this.masterWidth = 360,
    this.onMasterWidthChanged,
    this.minMasterWidth = 280,
  });

  @override
  Widget build(BuildContext context) {
    final sizeClass = LayoutBreakpoints.getWindowSizeClass(context);

    if (sizeClass == WindowSizeClass.compact) {
      return detail ?? master;
    }

    return fu.FResizable(
      axis: .horizontal,
      control: fu.FResizableControl.managedCascade(
        onResizeEnd: onMasterWidthChanged == null
            ? null
            : (regions) {
                if (regions.isEmpty) return;
                onMasterWidthChanged!(regions.first.extent.current);
              },
      ),
      children: [
        fu.FResizableRegion.fixed(
          extent: masterWidth,
          minExtent: minMasterWidth,
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
