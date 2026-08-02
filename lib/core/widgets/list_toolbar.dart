import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../config/theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../utils/platform_utils.dart';
import 'app_search_bar.dart';

/// One-line list chrome: search + filter trigger (+ optional create).
///
/// Compact shows filters in a bottom [fu.showFSheet]. Expanded shows them in
/// an [fu.FPopover] anchored to the filter button. Active-filter chips render
/// under the toolbar when [activeFilters] is non-empty.
class ListToolbar extends StatelessWidget {
  final String searchHint;
  final ValueChanged<String> onSearchChanged;
  final Widget filterPanel;
  final int activeFilterCount;
  final List<Widget> activeFilters;
  final VoidCallback? onCreate;
  final String createLabel;

  const ListToolbar({
    super.key,
    required this.searchHint,
    required this.onSearchChanged,
    required this.filterPanel,
    this.activeFilterCount = 0,
    this.activeFilters = const [],
    this.onCreate,
    this.createLabel = 'Create',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: AppSearchBar(hint: searchHint, onChanged: onSearchChanged),
            ),
            SizedBox(width: AppConstants.spacing.small),
            _FilterTrigger(activeFilterCount: activeFilterCount, filterPanel: filterPanel),
            if (onCreate != null) ...[
              SizedBox(width: AppConstants.spacing.small),
              fu.FButton(
                size: .sm,
                mainAxisSize: .min,
                prefix: const Icon(fu.FLucideIcons.plus),
                onPress: onCreate,
                child: Text(createLabel),
              ),
            ],
          ],
        ),
        if (activeFilters.isNotEmpty) ...[
          SizedBox(height: AppConstants.spacing.small),
          Wrap(spacing: AppConstants.spacing.small, runSpacing: AppConstants.spacing.small, children: activeFilters),
        ],
      ],
    );
  }
}

class _FilterTrigger extends StatefulWidget {
  final int activeFilterCount;
  final Widget filterPanel;

  const _FilterTrigger({required this.activeFilterCount, required this.filterPanel});

  @override
  State<_FilterTrigger> createState() => _FilterTriggerState();
}

class _FilterTriggerState extends State<_FilterTrigger> with SingleTickerProviderStateMixin {
  late final fu.FPopoverController _popoverController = fu.FPopoverController(vsync: this);

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
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.spacing.regular),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: [
              Text('Filters', style: context.typography.lg.copyWith(fontWeight: FontWeight.w700)),
              SizedBox(height: AppConstants.spacing.regular),
              widget.filterPanel,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.activeFilterCount > 0 ? 'Filters (${widget.activeFilterCount})' : 'Filters';
    final button = fu.FButton(
      size: .sm,
      mainAxisSize: .min,
      variant: widget.activeFilterCount > 0 ? .secondary : .outline,
      prefix: const Icon(fu.FLucideIcons.listFilter),
      onPress: context.isCompact ? _openSheet : _popoverController.toggle,
      child: Text(label),
    );

    if (context.isCompact) return button;

    return fu.FPopover(
      control: fu.FPopoverControl.managed(controller: _popoverController),
      popoverAnchor: .topRight,
      childAnchor: .bottomRight,
      popoverBuilder: (context, _) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(padding: EdgeInsets.all(AppConstants.spacing.regular), child: widget.filterPanel),
      ),
      child: button,
    );
  }
}
