import 'package:flutter/material.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/reports_insights_window_provider.dart';
import '../utils/productivity_insights_utils.dart';
import 'focus_hours_chart.dart';
import 'focus_ratio_chart.dart';

class InsightsContent extends StatelessWidget {
  final InsightsWindowMode window;
  final InsightsData data;

  const InsightsContent({super.key, required this.window, required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 460;

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FocusHoursChart(window: window, bars: data.bars),
              SizedBox(height: AppConstants.spacing.large),
              FocusRatioChart(focusRatio: data.focusRatio, breakRatio: data.breakRatio, ratioLabel: data.ratioLabel),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FocusHoursChart(window: window, bars: data.bars),
            ),
            Container(
              width: 1,
              height: 170,
              margin: EdgeInsets.symmetric(horizontal: AppConstants.spacing.large),
              color: context.colors.border,
            ),
            Expanded(
              child: FocusRatioChart(
                focusRatio: data.focusRatio,
                breakRatio: data.breakRatio,
                ratioLabel: data.ratioLabel,
              ),
            ),
          ],
        );
      },
    );
  }
}
