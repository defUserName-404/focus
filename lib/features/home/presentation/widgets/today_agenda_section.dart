import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/app_constants.dart';
import '../providers/today_agenda_provider.dart';
import 'agenda_task_tile.dart';
import 'empty_section.dart';
import 'section_header.dart';

class TodayAgendaSection extends ConsumerWidget {
  const TodayAgendaSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agendaAsync = ref.watch(todayAgendaProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppConstants.spacing.small,
      children: [
        const SectionHeader(title: "Today's Agenda"),
        agendaAsync.when(
          loading: () => const Center(child: fu.FCircularProgress()),
          error: (err, _) => Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.extraLarge2),
            child: Text('Error: $err'),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const EmptySection(icon: fu.FLucideIcons.listTodo, message: 'Nothing on your agenda today');
            }
            return Column(
              spacing: AppConstants.spacing.small,
              children: [for (final item in items) AgendaTaskTile(item: item)],
            );
          },
        ),
      ],
    );
  }
}
