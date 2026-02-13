import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

/// A card with increment / decrement buttons for setting a duration in minutes.
class TimerSettingsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  const TimerSettingsCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 120,
    this.step = 5,
  });

  @override
  Widget build(BuildContext context) {
    return fu.FCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.typography.sm.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: AppConstants.spacing.extraSmall),
                Text(
                  subtitle,
                  style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                ),
              ],
            ),
          ),
          // Stepper control
          Container(
            decoration: BoxDecoration(
              color: context.colors.muted,
              borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepButton(
                  icon: fu.FIcons.minus,
                  onTap: value > min ? () => onChanged((value - step).clamp(min, max)) : null,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.regular),
                  child: Text(
                    '${value}m',
                    style: context.typography.base.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                _StepButton(
                  icon: fu.FIcons.plus,
                  onTap: value < max ? () => onChanged((value + step).clamp(min, max)) : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.all(AppConstants.spacing.regular),
        child: Icon(
          icon,
          size: AppConstants.size.icon.regular,
          color: enabled ? context.colors.foreground : context.colors.mutedForeground,
        ),
      ),
    );
  }
}
