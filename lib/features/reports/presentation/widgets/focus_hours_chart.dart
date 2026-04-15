import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/reports_insights_window_provider.dart';
import '../utils/productivity_insights_utils.dart';

class FocusHoursChart extends StatelessWidget {
  final InsightsWindowMode window;
  final List<InsightsBarDatum> bars;

  const FocusHoursChart({super.key, required this.window, required this.bars});

  @override
  Widget build(BuildContext context) {
    final maxHours = bars.fold<double>(0, (maxValue, bar) => math.max(maxValue, bar.focusHours));
    const barHeight = 88.0;
    final title = window == InsightsWindowMode.weekly
        ? 'Focus Hours per Day (Current Week)'
        : 'Focus Hours per Week (Current Month)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: AppConstants.spacing.regular),
        SizedBox(
          height: 142,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final bar in bars)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.extraSmall),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _formatHours(bar.focusHours),
                          style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                        ),
                        SizedBox(height: AppConstants.spacing.extraSmall),
                        Container(
                          height: maxHours <= 0 ? 2 : (bar.focusHours / maxHours * barHeight).clamp(2.0, barHeight),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [context.colors.primary.withValues(alpha: 0.75), context.colors.primary],
                            ),
                            borderRadius: BorderRadius.circular(AppConstants.border.radius.small),
                          ),
                        ),
                        SizedBox(height: AppConstants.spacing.small),
                        Text(bar.label, style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatHours(double value) {
    if (value <= 0) return '0h';
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() < 0.05) {
      return '${rounded.toInt()}h';
    }
    return '${value.toStringAsFixed(1)}h';
  }
}
