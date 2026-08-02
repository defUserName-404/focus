import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/result.dart';
import '../../../settings/domain/entities/setting.dart';
import '../../../settings/domain/services/settings_service.dart';

part 'tasks_view_mode_provider.g.dart';

enum TasksViewMode { list, board, calendar }

extension TasksViewModeCodec on TasksViewMode {
  String get storageValue => switch (this) {
    TasksViewMode.list => 'list',
    TasksViewMode.board => 'board',
    TasksViewMode.calendar => 'calendar',
  };

  String get label => switch (this) {
    TasksViewMode.list => 'List',
    TasksViewMode.board => 'Board',
    TasksViewMode.calendar => 'Calendar',
  };

  static TasksViewMode fromStorage(String? value) {
    return switch (value) {
      'board' => TasksViewMode.board,
      'calendar' => TasksViewMode.calendar,
      _ => TasksViewMode.list,
    };
  }
}

@Riverpod(keepAlive: true)
class TasksViewModeNotifier extends _$TasksViewModeNotifier {
  late final SettingsService _settingsService;

  @override
  FutureOr<TasksViewMode> build() async {
    _settingsService = getIt<SettingsService>();
    final raw = await _settingsService.getValue(SettingsKeys.tasksViewMode);
    return TasksViewModeCodec.fromStorage(raw);
  }

  Future<void> setMode(TasksViewMode mode) async {
    state = AsyncValue.data(mode);

    final result = await _settingsService.setValue(SettingsKeys.tasksViewMode, mode.storageValue);
    if (result case Failure(:final failure)) {
      state = AsyncValue.error(failure, StackTrace.current);
    }
  }
}
