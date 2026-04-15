import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class DesktopToggleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const DesktopToggleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return fu.FCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: AppConstants.spacing.extraSmall),
                Text(subtitle, style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
              ],
            ),
          ),
          fu.FSwitch(value: enabled, onChange: onChanged),
        ],
      ),
    );
  }
}
