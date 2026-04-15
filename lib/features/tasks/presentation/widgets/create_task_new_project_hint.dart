import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class CreateTaskNewProjectHint extends StatelessWidget {
  final ValueNotifier<bool> isNewProject;
  final FAutocompleteController controller;

  const CreateTaskNewProjectHint({super.key, required this.isNewProject, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([isNewProject, controller]),
      builder: (context, _) {
        final isNew = isNewProject.value;
        final projectName = controller.text.trim();
        if (!isNew || projectName.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(top: AppConstants.spacing.small),
          child: Row(
            children: [
              Icon(FIcons.info, size: 12, color: context.colors.mutedForeground),
              SizedBox(width: AppConstants.spacing.small),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: AppConstants.spacing.small),
                  child: Text(
                    'A new project "$projectName" will be created.',
                    style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
