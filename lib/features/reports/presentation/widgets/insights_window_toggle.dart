import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/reports_insights_window_provider.dart';

class InsightsWindowToggle extends StatelessWidget {
  final InsightsWindowMode window;
  final ValueChanged<InsightsWindowMode> onChanged;

  const InsightsWindowToggle({super.key, required this.window, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        fu.FButton(
          style: window == InsightsWindowMode.weekly ? fu.FButtonStyle.secondary() : fu.FButtonStyle.outline(),
          onPress: () => onChanged(InsightsWindowMode.weekly),
          child: Text('Weekly', style: context.typography.xs),
        ),
        SizedBox(width: AppConstants.spacing.extraSmall),
        fu.FButton(
          style: window == InsightsWindowMode.monthly ? fu.FButtonStyle.secondary() : fu.FButtonStyle.outline(),
          onPress: () => onChanged(InsightsWindowMode.monthly),
          child: Text('Monthly', style: context.typography.xs),
        ),
      ],
    );
  }
}
