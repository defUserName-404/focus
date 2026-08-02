import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/result.dart';
import '../../../settings/domain/entities/setting.dart';
import '../../../settings/domain/services/settings_service.dart';

part 'tasks_master_pane_width_provider.g.dart';

const double kDefaultTasksMasterPaneWidth = 560;
const double kMinMasterPaneWidth = 280;

@Riverpod(keepAlive: true)
class TasksMasterPaneWidth extends _$TasksMasterPaneWidth {
  late final SettingsService _settingsService;

  @override
  FutureOr<double> build() async {
    _settingsService = getIt<SettingsService>();
    final raw = await _settingsService.getValue(SettingsKeys.tasksMasterPaneWidth);
    final parsed = double.tryParse(raw ?? '');
    if (parsed == null) return kDefaultTasksMasterPaneWidth;
    return parsed.clamp(kMinMasterPaneWidth, 900).toDouble();
  }

  Future<void> setWidth(double width) async {
    final clamped = width.clamp(kMinMasterPaneWidth, 900).toDouble();
    state = AsyncValue.data(clamped);
    final result = await _settingsService.setValue(SettingsKeys.tasksMasterPaneWidth, clamped.toStringAsFixed(1));
    if (result case Failure(:final failure)) {
      state = AsyncValue.error(failure, StackTrace.current);
    }
  }
}
