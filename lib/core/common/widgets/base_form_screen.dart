import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../constants/app_constants.dart';

/// A full-screen form layout with a nested header (back button + title)
/// and a scrollable body of form fields with a submit button.
///
/// Replaces [BaseModalForm] for use as a routed screen rather than a
/// bottom sheet.
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
    this.submitIcon = FIcons.check,
  });

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: Text(title),
        prefixes: [FHeaderAction.back(onPress: () => Navigator.of(context).pop())],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.spacing.regular),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppConstants.spacing.small,
          children: [
            ...fields,
            SizedBox(height: AppConstants.spacing.large),
            FButton(prefix: Icon(submitIcon), onPress: onSubmit, child: Text(submitButtonText)),
          ],
        ),
      ),
    );
  }
}
