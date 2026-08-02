import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/app_constants.dart';
import '../providers/habits_strip_provider.dart';
import 'empty_section.dart';
import 'habit_ring.dart';
import 'section_header.dart';

class HabitsStripSection extends ConsumerWidget {
  const HabitsStripSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsStripProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppConstants.spacing.small,
      children: [
        const SectionHeader(title: 'Habits'),
        habitsAsync.when(
          loading: () => const Center(child: fu.FCircularProgress()),
          error: (err, _) => Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.extraLarge2),
            child: Text('Error: $err'),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const EmptySection(icon: fu.FLucideIcons.flame, message: 'No habits yet');
            }
            return SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, _) => SizedBox(width: AppConstants.spacing.regular),
                itemBuilder: (context, index) => HabitRing(item: items[index]),
              ),
            );
          },
        ),
      ],
    );
  }
}
