import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class NotificationItemCard extends StatelessWidget {
  final String title;
  final String primaryText;
  final String? secondaryText;
  final VoidCallback? onTap;

  const NotificationItemCard({
    super.key,
    required this.title,
    required this.primaryText,
    this.secondaryText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: AppConstants.spacing.extraSmall),
        Text(primaryText, style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
        if ((secondaryText ?? '').isNotEmpty) ...[
          SizedBox(height: AppConstants.spacing.extraSmall),
          Text(secondaryText!, style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
        ],
      ],
    );

    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.spacing.small),
      child: fu.FCard(
        child: onTap == null ? content : InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: content),
      ),
    );
  }
}
