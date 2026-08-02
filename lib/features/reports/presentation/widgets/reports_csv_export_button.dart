import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../../tasks/domain/entities/estimate_accuracy_stat.dart';
import '../../../tasks/domain/entities/task_throughput_stats.dart';
import '../../../tasks/domain/services/report_insights_calculator.dart';
import '../providers/report_insights_providers.dart';
import '../providers/reports_insights_window_provider.dart';
import '../utils/productivity_insights_utils.dart';

/// Exports a CSV snapshot of the current report window via a save dialog.
class ReportsCsvExportButton extends ConsumerWidget {
  const ReportsCsvExportButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return fu.FTooltip(
      tipBuilder: (context, _) => const Text('Export CSV'),
      child: fu.FHeaderAction(
        icon: Icon(fu.FLucideIcons.download, size: AppConstants.size.icon.regular),
        semanticsLabel: 'Export CSV',
        onPress: () => _export(context, ref),
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final window = ref.read(reportsInsightsWindowProvider).value ?? InsightsWindowMode.weekly;
    final range = ProductivityInsightsUtils.dateRangeForWindow(window);
    final habits = ref.read(habitConsistencyProvider).value ?? const [];
    final estimates =
        ref.read(estimateAccuracyProvider).value ?? const EstimateAccuracySummary(tasks: [], typicalBiasRatio: 0);
    final byProject = ref.read(timeByProjectProvider).value ?? const [];
    final byTag = ref.read(timeByTagProvider).value ?? const [];
    final throughput =
        ref.read(taskThroughputProvider).value ??
        const TaskThroughputStats(buckets: [], averageCycleSeconds: null, cycleSampleCount: 0);
    final csv = ReportInsightsCalculator.buildCsvExport(
      windowLabel: window.storageValue,
      startDate: range.start.toShortDateKey(),
      endDate: range.end.toShortDateKey(),
      habits: habits,
      estimates: estimates,
      byProject: byProject,
      byTag: byTag,
      throughput: throughput,
    );

    final fileName = 'focus_report_${window.storageValue}_${range.start.toShortDateKey()}.csv';
    try {
      final path = await FilePicker.saveFile(
        dialogTitle: 'Export report CSV',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: const ['csv'],
        bytes: utf8.encode(csv),
      );
      if (!context.mounted) return;
      if (path == null) {
        await Clipboard.setData(ClipboardData(text: csv));
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Export cancelled — CSV copied to clipboard')));
        return;
      }
      final file = File(path);
      if (!await file.exists() || await file.length() == 0) {
        await file.writeAsString(csv);
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report CSV saved to $path')));
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: csv));
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not save file — CSV copied to clipboard')));
    }
  }
}
