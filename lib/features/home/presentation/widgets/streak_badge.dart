import 'package:flutter/material.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/animation_assets.dart';
import 'package:focus/core/constants/app_constants.dart';
import 'package:forui/forui.dart';
import 'package:lottie/lottie.dart';

class StreakBadge extends StatelessWidget {
  final int streak;

  const StreakBadge({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return FBadge(
      style: FBadgeStyle.secondary(),
      child: Row(
        mainAxisSize: .min,
        spacing: AppConstants.spacing.small,
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        children: [
          Lottie.asset(
            AnimationAssets.fire,
            width: AppConstants.size.icon.small,
            height: AppConstants.size.icon.small,
            repeat: true,
          ),
          Text('${streak}d', style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
