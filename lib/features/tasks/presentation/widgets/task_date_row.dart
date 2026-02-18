import 'package:flutter/material.dart';
import 'package:focus/core/common/utils/datetime_formatter.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/app_constants.dart';
import 'package:forui/forui.dart' as fu;

class TaskDateRow extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? deadline;
  final bool isOverdue;

  const TaskDateRow({
    super.key,
    this.startDate,
    this.deadline,
    this.isOverdue = false,
  });

  @override
  Widget build(BuildContext context) {
    if (startDate == null && deadline == null) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 2,
              ), // Slight lift for optical alignment
              child: Icon(
                fu.FIcons.calendar,
                size: AppConstants.size.icon.small,
                color: context.colors.mutedForeground,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _buildDateText(),
              style: context.typography.xs.copyWith(
                color: context.colors.mutedForeground,
              ),
            ),
          ],
        ),
        if (deadline != null &&
            (isOverdue || deadline!.isOverdue || _isApproaching(deadline!)))
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: AppConstants.spacing.regular),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Icon(
                  _isActuallyOverdue(deadline!)
                      ? fu.FIcons.triangleAlert
                      : fu.FIcons.clock,
                  color: _getStatusColor(context, deadline!),
                  size: AppConstants.size.icon.small,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                deadline!.toRelativeDueString(),
                style: context.typography.xs.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(context, deadline!),
                ),
              ),
            ],
          ),
      ],
    );
  }

  String _buildDateText() {
    if (startDate != null && deadline != null) {
      return '${startDate!.toShortDateString()} – ${deadline!.toShortDateString()}';
    }
    return (deadline ?? startDate)!.toShortDateString();
  }

  bool _isApproaching(DateTime dt) => dt.difference(DateTime.now()).inDays <= 3;

  bool _isActuallyOverdue(DateTime dt) => isOverdue || dt.isOverdue;

  Color _getStatusColor(BuildContext context, DateTime dt) {
    if (_isActuallyOverdue(dt)) return context.colors.destructive;
    return Colors
        .orange; // Should ideally be in context.colors if theme supports it
  }
}
