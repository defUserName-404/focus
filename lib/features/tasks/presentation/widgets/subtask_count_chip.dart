import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class SubtaskCountChip extends StatelessWidget {
  final int count;
  final bool expanded;
  final VoidCallback onToggle;

  const SubtaskCountChip({super.key, required this.count, required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return fu.FButton(
      variant: .outline,
      onPress: onToggle,
      suffix: Icon(
        expanded ? fu.FLucideIcons.chevronDown : fu.FLucideIcons.chevronRight,
        size: AppConstants.size.icon.small,
      ),
      child: Text('$count', style: context.typography.xs),
    );
  }
}
