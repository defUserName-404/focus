import 'package:flutter/material.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/keyboard_shortcut.dart';
import 'expandable_section.dart';

class KeyboardShortcutsSection extends StatefulWidget {
  const KeyboardShortcutsSection({super.key});

  @override
  State<KeyboardShortcutsSection> createState() => _KeyboardShortcutsSectionState();
}

class _KeyboardShortcutsSectionState extends State<KeyboardShortcutsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpandableSection(
      title: 'Keyboard Shortcuts',
      subtitle: 'Quick actions for power users',
      isExpanded: _expanded,
      onToggle: () => setState(() => _expanded = !_expanded),
      child: Wrap(
        spacing: AppConstants.spacing.extraLarge,
        runSpacing: AppConstants.spacing.small,
        children: [
          for (final shortcut in KeyboardShortcuts.all) SizedBox(width: 260, child: _ShortcutRow(shortcut: shortcut)),
        ],
      ),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  final KeyboardShortcut shortcut;

  const _ShortcutRow({required this.shortcut});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _KeyCap(keys: shortcut.displayKeys),
        SizedBox(width: AppConstants.spacing.regular),
        Expanded(
          child: Text(
            shortcut.description,
            style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
          ),
        ),
      ],
    );
  }
}

class _KeyCap extends StatelessWidget {
  final List<String> keys;

  const _KeyCap({required this.keys});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < keys.length; i++) ...[
          if (i > 0) ...[
            SizedBox(width: AppConstants.spacing.extraSmall),
            Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                '+',
                style: context.typography.xs.copyWith(
                  color: context.colors.mutedForeground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: AppConstants.spacing.extraSmall),
          ],
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.spacing.regular,
              vertical: AppConstants.spacing.small,
            ),
            decoration: BoxDecoration(
              color: context.colors.muted,
              borderRadius: BorderRadius.circular(AppConstants.spacing.extraSmall),
              border: Border.all(color: context.colors.border),
            ),
            child: Text(
              keys[i],
              style: context.typography.sm.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.w600, height: 1.0),
            ),
          ),
        ],
      ],
    );
  }
}
