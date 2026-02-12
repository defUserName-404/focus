import 'package:flutter/material.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/app_constants.dart';
import 'package:focus/features/tasks/domain/entities/global_stats.dart';
import 'package:forui/forui.dart';

class TodaySummaryCard extends StatelessWidget {
  final GlobalStats stats;

  const TodaySummaryCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today',
            style: context.typography.base.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.primary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: AppConstants.spacing.regular),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppConstants.spacing.extraSmall,
                  children: [
                    Text(stats.formattedTodayTime, style: context.typography.xl2.copyWith(fontWeight: FontWeight.w700)),
                    Text('Focus Time', style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
                  ],
                ),
              ),
              FDivider(axis: .vertical),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppConstants.spacing.extraSmall,
                  children: [
                    Text('${stats.todaySessions}', style: context.typography.xl2.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      'Sessions Completed',
                      style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
