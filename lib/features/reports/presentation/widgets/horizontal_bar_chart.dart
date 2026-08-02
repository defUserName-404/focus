import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../tasks/domain/entities/time_breakdown_item.dart';

/// Horizontal bar breakdown for project/tag time reports.
class HorizontalBarChart extends StatelessWidget {
  final List<TimeBreakdownItem> items;
  final String emptyMessage;

  const HorizontalBarChart({super.key, required this.items, this.emptyMessage = 'No focus time in this window'});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppConstants.spacing.regular),
        child: Text(emptyMessage, style: context.typography.sm.copyWith(color: context.colors.mutedForeground)),
      );
    }
    final maxSeconds = items.fold<int>(0, (maxValue, item) => math.max(maxValue, item.focusSeconds));
    return Column(
      children: [
        for (final item in items) ...[
          _BarRow(item: item, maxSeconds: maxSeconds),
          SizedBox(height: AppConstants.spacing.small),
        ],
      ],
    );
  }
}

class _BarRow extends StatelessWidget {
  final TimeBreakdownItem item;
  final int maxSeconds;

  const _BarRow({required this.item, required this.maxSeconds});

  @override
  Widget build(BuildContext context) {
    final fraction = maxSeconds <= 0 ? 0.0 : item.focusSeconds / maxSeconds;
    final barColor = item.color != null ? Color(item.color!) : context.colors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.sm.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              _formatDuration(item.focusSeconds),
              style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
            ),
          ],
        ),
        SizedBox(height: AppConstants.spacing.extraSmall),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.border.radius.small),
          child: LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: context.colors.mutedForeground.withValues(alpha: 0.12),
            color: barColor,
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '${minutes}m';
    final hours = minutes / 60;
    if ((hours - hours.round()).abs() < 0.05) return '${hours.round()}h';
    return '${hours.toStringAsFixed(1)}h';
  }
}
