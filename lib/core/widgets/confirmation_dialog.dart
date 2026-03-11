import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final dynamic confirmStyle;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.body,
    required this.onConfirm,
    this.confirmLabel = 'Delete',
    this.cancelLabel = 'Cancel',
    this.confirmStyle,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String body,
    required VoidCallback onConfirm,
    String confirmLabel = 'Delete',
    String cancelLabel = 'Cancel',
    dynamic confirmStyle,
  }) {
    return fu.showFDialog(
      context: context,
      builder: (ctx, _, _) => ConfirmationDialog(
        title: title,
        body: body,
        onConfirm: onConfirm,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmStyle: confirmStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return fu.FDialog(
      title: Text(title),
      body: Text(body),
      actions: [
        fu.FButton(onPress: () => Navigator.pop(context), style: fu.FButtonStyle.ghost(), child: Text(cancelLabel)),
        fu.FButton(
          onPress: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: confirmStyle ?? fu.FButtonStyle.destructive(),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
