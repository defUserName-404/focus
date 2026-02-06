import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/features/projects/presentation/screens/project_detail_screen.dart';
import 'package:forui/forui.dart';

import '../providers/project_provider.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return const Center(child: Text('No projects. Create one!'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(project.title),
                  subtitle: Text(project.description),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProjectDetailScreen(projectId: project.id)),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateProjectDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime deadline = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Project'),
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
                maxLines: 3,
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
                    .read(projectProvider.notifier)
                    .createProject(
                      title: titleController.text,
                      description: descController.text,
                      startDate: startDate,
                      deadline: deadline,
                    );
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
