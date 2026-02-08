import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: projectsAsync.when(
          data: (projects) {
            final project = projects.firstWhere((p) => p.id == projectId);
            return Text(project.title);
          },
          loading: () => const Text('Loading...'),
          error: (_, _) => const Text('Error'),
        ),
      ),
      body: tasksAsync.when(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTaskDialog(context, ref, projectIdString),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateTaskDialog(BuildContext context, WidgetRef ref, String projectIdString) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TaskPriority priority = TaskPriority.medium;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaskPriority>(
                  initialValue: priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: TaskPriority.values.map((p) {
                    return DropdownMenuItem(value: p, child: Text(p.label));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => priority = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FButton(
              child: const Text('Create'),
              onPress: () async {
                if (titleController.text.isNotEmpty) {
                  await ref
                      .read(taskProvider(projectIdString).notifier)
                      .createTask(
                        projectId: projectIdString,
                        title: titleController.text,
                        description: descController.text,
                        priority: priority,
                        startDate: DateTime.now(),
                        endDate: DateTime.now().add(const Duration(days: 7)),
                        depth: 0,
                      );
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
