import 'package:flutter/material.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/app_constants.dart';
import 'package:focus/features/tasks/domain/entities/global_stats.dart';

class TodaySummaryCard extends StatelessWidget {
  final GlobalStats stats;

  const TodaySummaryCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.spacing.large),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colors.primary.withValues(alpha: 0.10), context.colors.primary.withValues(alpha: 0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.15),
          width: AppConstants.border.width.small,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today',
            style: context.typography.xs.copyWith(
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
                  children: [
                    Text(stats.formattedTodayTime, style: context.typography.xl2.copyWith(fontWeight: FontWeight.w700)),
                    SizedBox(height: AppConstants.spacing.extraSmall),
                    Text('focus time', style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
                  ],
                ),
              ),
              Container(
                width: AppConstants.border.width.small,
                height: AppConstants.size.icon.large * 1.5,
                color: context.colors.mutedForeground.withValues(alpha: 0.15),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: AppConstants.spacing.large),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stats.todaySessions}',
                        style: context.typography.xl2.copyWith(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: AppConstants.spacing.extraSmall),
                      Text(
                        'sessions completed',
                        style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
