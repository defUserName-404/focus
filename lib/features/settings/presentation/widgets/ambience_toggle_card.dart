import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

/// A card with a toggle switch, a title, and a description.
class AmbienceToggleCard extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const AmbienceToggleCard({super.key, required this.enabled, required this.onChanged});

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
                Text('Ambient Sound', style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: AppConstants.spacing.extraSmall),
                Text(
                  'Play background noise during focus sessions',
                  style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                ),
              ],
            ),
          ),
          fu.FSwitch(value: enabled, onChange: onChanged),
        ],
      ),
    );
  }
}
