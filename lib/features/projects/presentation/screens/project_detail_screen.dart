import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/features/tasks/presentation/widgets/create_task_modal_content.dart';
import 'package:forui/forui.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/layout_constants.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/entities/task_priority.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../providers/project_provider.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final BigInt projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectIdString = projectId.toString();
    final tasksAsync = ref.watch(tasksByProjectProvider(projectIdString));
    final projectsAsync = ref.watch(projectListProvider);

    return FScaffold(
      header: FHeader.nested(
        prefixes: [
          FHeaderAction.back(
            onPress: () {
              Navigator.pop(context);
            },
          ),
        ],
        title: projectsAsync.when(
          data: (projects) {
            final project = projects.firstWhere((p) => p.id == projectId);
            return Text(project.title, style: context.typography.lg);
          },
          loading: () => const Text('Loading...'),
          error: (_, _) => const Text('Error'),
        ),
      ),
      footer: Padding(
        padding: EdgeInsets.all(LayoutConstants.spacing.paddingLarge),
        child: FButton(
          child: const Text('Create New Task'),
          onPress: () async {
            await showFSheet<Task>(
              context: context,
              side: FLayout.btt,
              builder: (context) => CreateTaskModalContent(projectId: projectId),
            );
          },
        ),
      ),
      child: tasksAsync.when(
        data: (tasks) {
          final rootTasks = tasks.where((t) => t.parentTaskId == null).toList();

          if (rootTasks.isEmpty) {
            return const Center(child: Text('No tasks. Create one!'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rootTasks.length,
            itemBuilder: (context, index) {
              final task = rootTasks[index];
              final subtasks = tasks.where((t) => t.parentTaskId == task.id).toList();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    ListTile(
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (_) {
                          ref.read(taskProvider(projectIdString).notifier).toggleTaskCompletion(task);
                        },
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null),
                      ),
                      subtitle: Text(task.priority.label),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => TaskDetailScreen(taskId: task.id, projectId: projectId),
                        //   ),
                        // );
                      },
                    ),
                    if (subtasks.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 32, bottom: 8),
                        child: Column(
                          children: subtasks.map((subtask) {
                            return ListTile(
                              dense: true,
                              leading: Checkbox(
                                value: subtask.isCompleted,
                                onChanged: (_) {
                                  ref.read(taskProvider(projectIdString).notifier).toggleTaskCompletion(subtask);
                                },
                              ),
                              title: Text(
                                subtask.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

}
