import 'package:flutter/material.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/platform_utils.dart';
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
    final modifier = PlatformUtils.isMacOS ? '\u2318' : 'Ctrl';

    return ExpandableSection(
      title: 'Keyboard Shortcuts',
      isExpanded: _expanded,
      onToggle: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ShortcutRow(keys: [modifier, 'N'], description: 'Create new task'),
          SizedBox(height: AppConstants.spacing.small),
          _ShortcutRow(keys: [modifier, 'P'], description: 'Create new project'),
          SizedBox(height: AppConstants.spacing.small),
          _ShortcutRow(keys: const ['Esc'], description: 'Go back / close'),
        ],
      ),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  final List<String> keys;
  final String description;

  const _ShortcutRow({required this.keys, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _KeyCap(keys: keys),
        SizedBox(width: AppConstants.spacing.regular),
        Expanded(
          child: Text(description, style: context.typography.sm.copyWith(color: context.colors.mutedForeground)),
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
