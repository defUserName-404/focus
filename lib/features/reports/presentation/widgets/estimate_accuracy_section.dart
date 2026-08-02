import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../tasks/domain/entities/estimate_accuracy_stat.dart';
import '../providers/report_insights_providers.dart';

class EstimateAccuracySection extends ConsumerWidget {
  const EstimateAccuracySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(estimateAccuracyProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estimate Accuracy', style: context.typography.md.copyWith(fontWeight: FontWeight.w700)),
        SizedBox(height: AppConstants.spacing.regular),
        async.when(
          loading: () => const SizedBox(height: 80, child: Center(child: fu.FCircularProgress())),
          error: (err, _) => Text('Error: $err', style: context.typography.sm),
          data: (summary) {
            if (!summary.hasData) {
              return Text(
                'Add estimates and complete focus sessions to see accuracy',
                style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BiasInsight(biasRatio: summary.typicalBiasRatio),
                SizedBox(height: AppConstants.spacing.regular),
                for (final task in summary.tasks.take(8)) ...[
                  _EstimateRow(stat: task),
                  SizedBox(height: AppConstants.spacing.small),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _BiasInsight extends StatelessWidget {
  final double biasRatio;

  const _BiasInsight({required this.biasRatio});

  @override
  Widget build(BuildContext context) {
    final percent = (biasRatio.abs() * 100).round();
    final message = biasRatio >= 0
        ? 'You typically underestimate by $percent%'
        : 'You typically overestimate by $percent%';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.spacing.regular),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
      ),
      child: Text(message, style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

class _EstimateRow extends StatelessWidget {
  final EstimateAccuracyStat stat;

  const _EstimateRow({required this.stat});

  @override
  Widget build(BuildContext context) {
    final deltaPercent = (stat.deltaRatio * 100).round();
    final deltaLabel = deltaPercent >= 0 ? '+$deltaPercent%' : '$deltaPercent%';
    return Row(
      children: [
        Expanded(
          child: Text(
            stat.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.typography.sm.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          '${stat.estimatedMinutes}m → ${stat.actualMinutes}m',
          style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
        ),
        SizedBox(width: AppConstants.spacing.small),
        Text(
          deltaLabel,
          style: context.typography.xs.copyWith(
            fontWeight: FontWeight.w600,
            color: deltaPercent >= 0 ? context.colors.primary : context.colors.mutedForeground,
          ),
        ),
      ],
    );
  }
}
