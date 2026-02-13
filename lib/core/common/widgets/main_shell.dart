import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../features/all_tasks/presentation/screens/all_tasks_screen.dart';
import '../../../features/home/presentation/pages/home_screen.dart';
import '../../../features/projects/presentation/screens/project_list_screen.dart';
import '../../../features/settings/presentation/screens/settings_screen.dart';

/// Root shell with bottom navigation.
///
/// Hosts the four primary tabs: Home, Tasks, Projects, Settings.
/// Uses ForUI's [FBottomNavigationBar] to stay consistent with the
/// app's design language.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static final List<Widget> _screens = [
    const HomeScreen(),
    const AllTasksScreen(),
    const ProjectListScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return fu.FScaffold(
      childPad: false,
      footer: fu.FBottomNavigationBar(
        index: _currentIndex,
        onChange: (index) => setState(() => _currentIndex = index),
        children: [
          fu.FBottomNavigationBarItem(icon: const Icon(fu.FIcons.house), label: const Text('Home')),
          fu.FBottomNavigationBarItem(icon: const Icon(fu.FIcons.squareCheck), label: const Text('Tasks')),
          fu.FBottomNavigationBarItem(icon: const Icon(fu.FIcons.folderOpen), label: const Text('Projects')),
          fu.FBottomNavigationBarItem(icon: const Icon(fu.FIcons.settings), label: const Text('Settings')),
        ],
      ),
      child: IndexedStack(index: _currentIndex, children: _screens),
    );
  }
}
