import 'package:flutter/material.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class TimerStepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const TimerStepButton({super.key, required this.icon, this.onTap});

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
