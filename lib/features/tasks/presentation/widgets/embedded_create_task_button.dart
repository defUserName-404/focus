import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';

class EmbeddedCreateTaskButton extends StatelessWidget {
  const EmbeddedCreateTaskButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.spacing.small),
      child: Align(
        alignment: Alignment.centerRight,
        child: fu.FButton(
          prefix: Icon(fu.FIcons.plus),
          onPress: () => context.push(AppRoutes.createTaskWithProject.path),
          child: const Text('Create Task'),
        ),
      ),
    );
  }
}
