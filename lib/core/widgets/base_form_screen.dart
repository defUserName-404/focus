import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../config/theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../utils/platform_utils.dart';
import 'constrained_content.dart';

/// Adaptive form layout.
///
/// - Compact: full-screen [FScaffold] with nested header.
/// - Expanded (routed): centered 560px card-style form.
/// - Embedded (side pane): pane header + scrollable fields, no centered card.
class BaseFormScreen extends StatelessWidget {
  final String title;
  final List<Widget> fields;
  final VoidCallback onSubmit;
  final String submitButtonText;
  final IconData submitIcon;
  final bool isEmbedded;
  final VoidCallback? onDismiss;

  const BaseFormScreen({
    super.key,
    required this.title,
    required this.fields,
    required this.onSubmit,
    required this.submitButtonText,
    this.submitIcon = FLucideIcons.check,
    this.isEmbedded = false,
    this.onDismiss,
  });

  void _dismiss(BuildContext context) {
    if (onDismiss != null) {
      onDismiss!();
      return;
    }
    if (context.canPop()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formBody = Column(
      crossAxisAlignment: .stretch,
      spacing: AppConstants.spacing.small,
      children: [
        ...fields,
        SizedBox(height: AppConstants.spacing.large),
        FButton(prefix: Icon(submitIcon), onPress: onSubmit, child: Text(submitButtonText)),
      ],
    );

    if (isEmbedded) {
      return Column(
        crossAxisAlignment: .stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppConstants.spacing.large,
              AppConstants.spacing.large,
              AppConstants.spacing.large,
              AppConstants.spacing.small,
            ),
            child: Row(
              children: [
                FHeaderAction.back(onPress: () => _dismiss(context)),
                SizedBox(width: AppConstants.spacing.small),
                Expanded(
                  child: Text(title, style: context.typography.xl.copyWith(fontWeight: FontWeight.w700)),
                ),
                FButton(
                  variant: .ghost,
                  size: .sm,
                  mainAxisSize: .min,
                  onPress: () => _dismiss(context),
                  child: const Icon(FLucideIcons.x),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppConstants.spacing.large,
                0,
                AppConstants.spacing.large,
                AppConstants.spacing.large,
              ),
              child: formBody,
            ),
          ),
        ],
      );
    }

    if (context.isCompact) {
      return FScaffold(
        header: FHeader.nested(
          title: Text(title),
          prefixes: [FHeaderAction.back(onPress: () => _dismiss(context))],
        ),
        child: SingleChildScrollView(child: formBody),
      );
    }

    return FScaffold(
      child: Center(
        child: ConstrainedContent(
          maxWidth: 560,
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.spacing.large,
            vertical: AppConstants.spacing.extraLarge,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
              border: Border.all(color: context.colors.border),
            ),
            child: Padding(
              padding: EdgeInsets.all(AppConstants.spacing.large),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: .stretch,
                  spacing: AppConstants.spacing.regular,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title, style: context.typography.xl.copyWith(fontWeight: FontWeight.w700)),
                        ),
                        FButton(
                          variant: .ghost,
                          size: .sm,
                          mainAxisSize: .min,
                          onPress: () => _dismiss(context),
                          child: const Icon(FLucideIcons.x),
                        ),
                      ],
                    ),
                    formBody,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
