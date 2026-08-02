import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../config/theme/app_theme.dart';
import '../constants/app_constants.dart';
import 'app_search_bar.dart';
import 'filter_select.dart';

/// One-line list chrome: search + optional view switcher + filter (+ create).
///
/// Narrow panes (< 400) show filters in a bottom [fu.showFSheet]. Wider panes
/// show them in an [fu.FPopover] anchored to the filter button. Active-filter
/// chips render under the toolbar when [activeFilters] is non-empty.
///
/// Pass [viewModeControl] to slot a segmented List/Board/Calendar (or similar)
/// control into the same toolbar row instead of stacking another filter row.
class ListToolbar extends StatelessWidget {
  final String searchHint;
  final ValueChanged<String> onSearchChanged;
  final Widget filterPanel;
  final int activeFilterCount;
  final List<Widget> activeFilters;
  final VoidCallback? onCreate;
  final String createLabel;
  final Widget? viewModeControl;
  final FocusNode? searchFocusNode;
  final VoidCallback? onReset;

  const ListToolbar({
    super.key,
    required this.searchHint,
    required this.onSearchChanged,
    required this.filterPanel,
    this.activeFilterCount = 0,
    this.activeFilters = const [],
    this.onCreate,
    this.createLabel = 'Create',
    this.viewModeControl,
    this.searchFocusNode,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // Icon-only Filters/Create below 520 so master-detail panes and phones
            // keep a usable search field instead of crushing labels.
            final iconOnly = constraints.maxWidth < 520;
            return ListToolbarLayout(
              iconOnly: iconOnly,
              child: FocusTraversalGroup(
                child: Row(
                  children: [
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 140),
                        child: AppSearchBar(hint: searchHint, onChanged: onSearchChanged, focusNode: searchFocusNode),
                      ),
                    ),
                    if (viewModeControl != null) ...[SizedBox(width: AppConstants.spacing.small), viewModeControl!],
                    SizedBox(width: AppConstants.spacing.small),
                    _FilterTrigger(
                      activeFilterCount: activeFilterCount,
                      filterPanel: filterPanel,
                      iconOnly: iconOnly,
                      onReset: onReset,
                    ),
                    if (onCreate != null) ...[
                      SizedBox(width: AppConstants.spacing.small),
                      if (iconOnly)
                        fu.FTooltip(
                          tipBuilder: (context, _) => Text(createLabel),
                          child: fu.FButton.icon(
                            size: .sm,
                            variant: .primary,
                            semanticsLabel: createLabel,
                            onPress: onCreate,
                            child: const Icon(fu.FLucideIcons.plus),
                          ),
                        )
                      else
                        fu.FButton(
                          size: .sm,
                          variant: .primary,
                          mainAxisSize: .min,
                          prefix: const Icon(fu.FLucideIcons.plus),
                          onPress: onCreate,
                          child: Text(createLabel),
                        ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        if (activeFilters.isNotEmpty) ...[
          SizedBox(height: AppConstants.spacing.small),
          Wrap(spacing: AppConstants.spacing.small, runSpacing: AppConstants.spacing.small, children: activeFilters),
        ],
      ],
    );
  }
}

/// Density signal for toolbar children (e.g. [TasksViewModeToggle]).
class ListToolbarLayout extends InheritedWidget {
  final bool iconOnly;

  const ListToolbarLayout({super.key, required this.iconOnly, required super.child});

  static bool iconOnlyOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ListToolbarLayout>()?.iconOnly ?? false;
  }

  @override
  bool updateShouldNotify(ListToolbarLayout oldWidget) => iconOnly != oldWidget.iconOnly;
}

class _FilterTrigger extends StatefulWidget {
  final int activeFilterCount;
  final Widget filterPanel;
  final bool iconOnly;
  final VoidCallback? onReset;

  const _FilterTrigger({
    required this.activeFilterCount,
    required this.filterPanel,
    required this.iconOnly,
    this.onReset,
  });

  @override
  State<_FilterTrigger> createState() => _FilterTriggerState();
}

class _FilterTriggerState extends State<_FilterTrigger> with SingleTickerProviderStateMixin {
  late final fu.FPopoverController _popoverController = fu.FPopoverController(vsync: this);
  final Object _groupId = Object();

  @override
  void dispose() {
    _popoverController.dispose();
    super.dispose();
  }

  Future<void> _openSheet() {
    return fu.showFSheet(
      context: context,
      side: .btt,
      mainAxisMaxRatio: 0.7,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppConstants.spacing.regular,
            AppConstants.spacing.small,
            AppConstants.spacing.regular,
            AppConstants.spacing.regular,
          ),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: sheetContext.colors.mutedForeground.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              SizedBox(height: AppConstants.spacing.regular),
              Text('Filters', style: sheetContext.typography.lg.copyWith(fontWeight: FontWeight.w700)),
              SizedBox(height: AppConstants.spacing.regular),
              FilterSelectGroup(groupId: _groupId, child: widget.filterPanel),
              SizedBox(height: AppConstants.spacing.regular),
              Row(
                children: [
                  if (widget.onReset != null)
                    Expanded(
                      child: fu.FButton(
                        variant: .outline,
                        onPress: () {
                          widget.onReset!();
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                  if (widget.onReset != null) SizedBox(width: AppConstants.spacing.small),
                  Expanded(
                    child: fu.FButton(onPress: () => Navigator.of(sheetContext).pop(), child: const Text('Done')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paneWidth = MediaQuery.sizeOf(context).width;
    final useSheet = paneWidth < 400;
    final popoverMaxWidth = math.min(360.0, paneWidth - 32);
    final label = widget.activeFilterCount > 0 ? 'Filters (${widget.activeFilterCount})' : 'Filters';
    final onPress = useSheet ? _openSheet : _popoverController.toggle;

    final Widget button;
    if (widget.iconOnly) {
      button = fu.FTooltip(
        tipBuilder: (context, _) => Text(label),
        child: fu.FButton.icon(
          size: .sm,
          variant: widget.activeFilterCount > 0 ? .secondary : .outline,
          semanticsLabel: label,
          onPress: onPress,
          child: const Icon(fu.FLucideIcons.listFilter),
        ),
      );
    } else {
      button = fu.FButton(
        size: .sm,
        mainAxisSize: .min,
        variant: widget.activeFilterCount > 0 ? .secondary : .outline,
        prefix: const Icon(fu.FLucideIcons.listFilter),
        onPress: onPress,
        child: Text(label),
      );
    }

    if (useSheet) return button;

    return fu.FPopover(
      control: fu.FPopoverControl.managed(controller: _popoverController),
      groupId: _groupId,
      hideRegion: fu.FPopoverHideRegion.excludeChild,
      popoverAnchor: .topRight,
      childAnchor: .bottomRight,
      popoverBuilder: (context, _) => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: popoverMaxWidth),
        child: Padding(
          padding: EdgeInsets.all(AppConstants.spacing.regular),
          child: FilterSelectGroup(groupId: _groupId, child: widget.filterPanel),
        ),
      ),
      child: button,
    );
  }
}
