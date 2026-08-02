import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/report_insights_providers.dart';
import 'horizontal_bar_chart.dart';

class TimeBreakdownSection extends ConsumerWidget {
  const TimeBreakdownSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byProject = ref.watch(timeByProjectProvider);
    final byTag = ref.watch(timeByTagProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Time by Project', style: context.typography.md.copyWith(fontWeight: FontWeight.w700)),
        SizedBox(height: AppConstants.spacing.regular),
        byProject.when(
          loading: () => const SizedBox(height: 64, child: Center(child: fu.FCircularProgress())),
          error: (err, _) => Text('Error: $err', style: context.typography.sm),
          data: (items) => HorizontalBarChart(items: items, emptyMessage: 'No project focus time in this window'),
        ),
        SizedBox(height: AppConstants.spacing.large),
        Text('Time by Tag', style: context.typography.md.copyWith(fontWeight: FontWeight.w700)),
        SizedBox(height: AppConstants.spacing.regular),
        byTag.when(
          loading: () => const SizedBox(height: 64, child: Center(child: fu.FCircularProgress())),
          error: (err, _) => Text('Error: $err', style: context.typography.sm),
          data: (items) => HorizontalBarChart(items: items, emptyMessage: 'No tagged focus time in this window'),
        ),
      ],
    );
  }
}
