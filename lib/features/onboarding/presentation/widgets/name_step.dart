import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

/// Step 5 of onboarding: a single name field.
class NameStep extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const NameStep({required this.initialValue, required this.onChanged, super.key});

  @override
  State<NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.extraLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(fu.FLucideIcons.user, size: 56, color: context.colors.primary),
          SizedBox(height: AppConstants.spacing.large),
          Text(
            'What should we call you?',
            textAlign: TextAlign.center,
            style: context.typography.xl.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppConstants.spacing.regular),
          Text(
            'Optional. We will use this to greet you on the dashboard.',
            textAlign: TextAlign.center,
            style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
          ),
          SizedBox(height: AppConstants.spacing.large),
          fu.FTextField(
            control: fu.FTextFieldControl.managed(
              controller: _controller,
              onChange: (value) => widget.onChanged(value.text),
            ),
            label: const Text('Your name'),
            hint: 'e.g. Alex',
            textInputAction: TextInputAction.done,
            autofocus: true,
            maxLength: 40,
          ),
        ],
      ),
    );
  }
}
