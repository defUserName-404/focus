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
class BaseFormScreen extends StatefulWidget {
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

  @override
  State<BaseFormScreen> createState() => _BaseFormScreenState();
}

class _BaseFormScreenState extends State<BaseFormScreen> {
  final _formKey = GlobalKey<FormState>();

  void _dismiss(BuildContext context) {
    if (widget.onDismiss != null) {
      widget.onDismiss!();
      return;
    }
    if (context.canPop()) {
      context.pop();
    }
  }

  void _validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formBody = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: .stretch,
        spacing: AppConstants.spacing.small,
        children: [
          ...widget.fields,
          SizedBox(height: AppConstants.spacing.large),
          FButton(prefix: Icon(widget.submitIcon), onPress: _validateAndSubmit, child: Text(widget.submitButtonText)),
        ],
      ),
    );

    if (widget.isEmbedded) {
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
                FButton.icon(
                  variant: .ghost,
                  onPress: () => _dismiss(context),
                  child: const Icon(FLucideIcons.arrowLeft),
                ),
                SizedBox(width: AppConstants.spacing.small),
                Expanded(
                  child: Text(widget.title, style: context.typography.xl.copyWith(fontWeight: FontWeight.w700)),
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
          title: Text(widget.title),
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
                          child: Text(widget.title, style: context.typography.xl.copyWith(fontWeight: FontWeight.w700)),
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
