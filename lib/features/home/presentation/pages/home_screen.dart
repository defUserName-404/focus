import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../projects/presentation/providers/project_provider.dart';
import '../../../projects/presentation/screens/project_list_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No projects yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 24),
                  FButton(
                    child: const Text('Create Your First Project'),
                    onPress: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProjectListScreen()));
                    },
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Your Projects', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              ...projects.map(
                (project) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(project.title),
                    subtitle: Text(project.description),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProjectListScreen()));
                    },
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProjectListScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
    );
  }
}
