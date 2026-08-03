import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final fu.FButtonVariant? confirmVariant;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.body,
    required this.onConfirm,
    this.confirmLabel = 'Delete',
    this.cancelLabel = 'Cancel',
    this.confirmVariant,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String body,
    required VoidCallback onConfirm,
    String confirmLabel = 'Delete',
    String cancelLabel = 'Cancel',
    fu.FButtonVariant? confirmVariant,
  }) {
    return fu.showFDialog(
      context: context,
      builder: (ctx, _, _) => ConfirmationDialog(
        title: title,
        body: body,
        onConfirm: onConfirm,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmVariant: confirmVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return fu.FDialog(
      builder: (context, style) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            DefaultTextStyle(style: style.titleTextStyle, child: Text(title)),
            const SizedBox(height: 8),
            DefaultTextStyle(style: style.bodyTextStyle, child: Text(body)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: .end,
              spacing: 8,
              children: [
                fu.FButton(
                  size: .sm,
                  mainAxisSize: .min,
                  onPress: () => Navigator.pop(context),
                  variant: .ghost,
                  child: Text(cancelLabel),
                ),
                fu.FButton(
                  size: .sm,
                  mainAxisSize: .min,
                  onPress: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  variant: confirmVariant ?? .destructive,
                  child: Text(confirmLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
