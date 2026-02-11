import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:forui/forui.dart' as fu;
import 'package:intl/intl.dart';

import '../../../projects/presentation/providers/project_provider.dart';
import '../../../projects/presentation/screens/project_detail_screen.dart';
import '../../../projects/presentation/screens/project_list_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Focus', style: context.typography.xl2.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat.yMMMMEEEEd().format(DateTime.now()),
                      style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
                    ),
                  ],
                ),
              ),
              fu.FButton(
                style: fu.FButtonStyle.outline(),
                onPress: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectListScreen())),
                child: const Text('All Projects'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Projects list ──
        Expanded(
          child: projectsAsync.when(
            loading: () => const Center(child: fu.FCircularProgress()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (projects) {
              if (projects.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(fu.FIcons.folderOpen, size: 56, color: context.colors.mutedForeground),
                      const SizedBox(height: 16),
                      Text(
                        'No projects yet',
                        style: context.typography.lg.copyWith(color: context.colors.mutedForeground),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first project to get started',
                        style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
                      ),
                      const SizedBox(height: 20),
                      fu.FButton(
                        child: const Text('Go to Projects'),
                        onPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProjectListScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () {
                        if (project.id != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ProjectDetailScreen(projectId: project.id!)),
                          );
                        }
                      },
                      child: fu.FCard(
                        title: Text(project.title),
                        subtitle: project.description != null && project.description!.isNotEmpty
                            ? Text(
                                project.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        child: Row(
                          children: [
                            if (project.deadline != null) ...[
                              Icon(fu.FIcons.calendar, size: 13, color: context.colors.mutedForeground),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat.yMMMd().format(project.deadline!),
                                style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                              ),
                            ],
                            const Spacer(),
                            Icon(fu.FIcons.chevronRight, size: 16, color: context.colors.mutedForeground),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
