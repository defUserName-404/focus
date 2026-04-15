import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class ExpandableSection extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  const ExpandableSection({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return fu.FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(
                  child: Text(title, style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    fu.FIcons.chevronDown,
                    size: AppConstants.size.icon.regular,
                    color: context.colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.only(top: AppConstants.spacing.regular),
              child: child,
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
