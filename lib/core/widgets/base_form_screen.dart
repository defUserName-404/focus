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
/// - Expanded: centered 560px card-style form so create/edit flows are not
///   stretched across wide windows.
class BaseFormScreen extends StatelessWidget {
  final String title;
  final List<Widget> fields;
  final VoidCallback onSubmit;
  final String submitButtonText;
  final IconData submitIcon;

  const BaseFormScreen({
    super.key,
    required this.title,
    required this.fields,
    required this.onSubmit,
    required this.submitButtonText,
    this.submitIcon = FLucideIcons.check,
  });

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

    if (context.isCompact) {
      return FScaffold(
        header: FHeader.nested(
          title: Text(title),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
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
                          onPress: () => context.pop(),
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
