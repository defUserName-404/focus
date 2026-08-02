import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/project_detail_tab.dart';

class ProjectDetailTabBar extends StatelessWidget {
  final ProjectDetailTab selected;
  final ValueChanged<ProjectDetailTab> onChanged;

  const ProjectDetailTabBar({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final tab in ProjectDetailTab.values) ...[
            if (tab != ProjectDetailTab.values.first) SizedBox(width: AppConstants.spacing.extraSmall),
            fu.FButton(
              size: .sm,
              mainAxisSize: .min,
              variant: selected == tab ? .secondary : .outline,
              onPress: () => onChanged(tab),
              child: Text(tab.label, style: context.typography.xs),
            ),
          ],
        ],
      ),
    );
  }
}
