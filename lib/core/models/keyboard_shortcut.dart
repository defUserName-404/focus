import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../routing/routes.dart';
import '../utils/platform_utils.dart';
import '../../features/projects/presentation/commands/project_commands.dart';
import '../../features/tasks/presentation/commands/task_commands.dart';

/// Describes a single keyboard shortcut for both the live binding and the
/// settings display. Add a new entry to [KeyboardShortcuts.all] and it
/// appears in both places automatically.
class KeyboardShortcut {
  final LogicalKeyboardKey key;
  final String displayLabel;
  final String description;
  final bool useModifier;
  final bool shift;
  final void Function(BuildContext context)? actionBuilder;

  const KeyboardShortcut({
    required this.key,
    required this.displayLabel,
    required this.description,
    this.useModifier = true,
    this.shift = false,
    this.actionBuilder,
  });

  /// Display key labels for the settings UI, e.g. ['⌘', '⇧', 'F'] or ['Ctrl', 'Shift', 'F'].
  List<String> get displayKeys {
    if (!useModifier) return [displayLabel];
    final modifier = PlatformUtils.isMacOS ? '\u2318' : 'Ctrl';
    if (shift) return [modifier, PlatformUtils.isMacOS ? '\u21E7' : 'Shift', displayLabel];
    return [modifier, displayLabel];
  }

  /// The [SingleActivator] for use in [CallbackShortcuts].
  SingleActivator get activator {
    final meta = PlatformUtils.isDesktop;
    return SingleActivator(key, control: !meta, meta: meta, shift: shift);
  }
}

/// Central registry of all keyboard shortcuts.
///
/// To add a shortcut: append to [all]. The live binding in
/// `AppKeyboardShortcuts` and the settings display in
/// `KeyboardShortcutsSection` both read from here.
abstract final class KeyboardShortcuts {
  static const all = [
    // --- Create ---
    KeyboardShortcut(
      key: LogicalKeyboardKey.keyN,
      displayLabel: 'N',
      description: 'Create new task',
      actionBuilder: TaskCommands.createWithProject,
    ),
    KeyboardShortcut(
      key: LogicalKeyboardKey.keyP,
      displayLabel: 'P',
      description: 'Create new project',
      actionBuilder: ProjectCommands.create,
    ),

    // --- Navigate ---
    KeyboardShortcut(
      key: LogicalKeyboardKey.digit1,
      displayLabel: '1',
      description: 'Go to Home',
      actionBuilder: _goHome,
    ),
    KeyboardShortcut(
      key: LogicalKeyboardKey.digit2,
      displayLabel: '2',
      description: 'Go to Tasks',
      actionBuilder: _goTasks,
    ),
    KeyboardShortcut(
      key: LogicalKeyboardKey.digit3,
      displayLabel: '3',
      description: 'Go to Projects',
      actionBuilder: _goProjects,
    ),
    KeyboardShortcut(
      key: LogicalKeyboardKey.digit4,
      displayLabel: '4',
      description: 'Go to Reports',
      actionBuilder: _goReports,
    ),
    KeyboardShortcut(
      key: LogicalKeyboardKey.digit5,
      displayLabel: '5',
      description: 'Go to Notifications',
      actionBuilder: _goNotifications,
    ),

    // --- Actions ---
    KeyboardShortcut(
      key: LogicalKeyboardKey.keyF,
      displayLabel: 'F',
      description: 'Toggle filter',
      shift: true,
      actionBuilder: _toggleFilter,
    ),
    KeyboardShortcut(
      key: LogicalKeyboardKey.period,
      displayLabel: '.',
      description: 'Start focus session',
      actionBuilder: _startSession,
    ),

    // --- Navigation ---
    KeyboardShortcut(
      key: LogicalKeyboardKey.escape,
      displayLabel: 'Esc',
      description: 'Go back / close',
      useModifier: false,
      actionBuilder: _goBack,
    ),
  ];
}

// ---------------------------------------------------------------------------
// Action builders
// ---------------------------------------------------------------------------

void _goHome(BuildContext context) => context.go(AppRoutes.home.path);
void _goTasks(BuildContext context) => context.go(AppRoutes.tasks.path);
void _goProjects(BuildContext context) => context.go(AppRoutes.projects.path);
void _goReports(BuildContext context) => context.go(AppRoutes.reports.path);
void _goNotifications(BuildContext context) => context.go(AppRoutes.notifications.path);
void _startSession(BuildContext context) => context.push(AppRoutes.focusSession.path);
void _toggleFilter(BuildContext context) => context.go(AppRoutes.tasks.path);
void _goBack(BuildContext context) {
  if (context.canPop()) context.pop();
}
