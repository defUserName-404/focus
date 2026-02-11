import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../constants/app_constants.dart';

class BaseModalForm extends StatelessWidget {
  final String title;
  final List<Widget> fields;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final String submitButtonText;

  const BaseModalForm({
    super.key,
    required this.title,
    required this.fields,
    required this.onCancel,
    required this.onSubmit,
    required this.submitButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).canvasColor,
      child: Padding(
        padding: EdgeInsets.all(AppConstants.spacing.regular),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, textAlign: TextAlign.center),
              SizedBox(height: AppConstants.spacing.large),
              ...fields,
              SizedBox(height: AppConstants.spacing.large),
              Row(
                mainAxisAlignment: .end,
                children: [
                  fu.FButton(onPress: onCancel, style: fu.FButtonStyle.ghost(), child: const Text('Cancel')),
                  fu.FButton(onPress: onSubmit, child: Text(submitButtonText)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
