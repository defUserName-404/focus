import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/result.dart';
import '../../../settings/domain/entities/setting.dart';
import '../../../settings/domain/services/settings_service.dart';

part 'reports_insights_window_provider.g.dart';

enum InsightsWindowMode { weekly, monthly }

extension InsightsWindowModeCodec on InsightsWindowMode {
  String get storageValue => switch (this) {
    InsightsWindowMode.weekly => 'weekly',
    InsightsWindowMode.monthly => 'monthly',
  };

  static InsightsWindowMode fromStorage(String? value) {
    return switch (value) {
      'monthly' => InsightsWindowMode.monthly,
      _ => InsightsWindowMode.weekly,
    };
  }
}

@Riverpod(keepAlive: true)
class ReportsInsightsWindowNotifier extends _$ReportsInsightsWindowNotifier {
  late final SettingsService _settingsService;

  @override
  FutureOr<InsightsWindowMode> build() async {
    _settingsService = getIt<SettingsService>();
    final raw = await _settingsService.getValue(SettingsKeys.reportsInsightsWindowMode);
    return InsightsWindowModeCodec.fromStorage(raw);
  }

  Future<void> setWindow(InsightsWindowMode mode) async {
    state = AsyncValue.data(mode);

    final result = await _settingsService.setValue(SettingsKeys.reportsInsightsWindowMode, mode.storageValue);
    if (result case Failure(:final failure)) {
      state = AsyncValue.error(failure, StackTrace.current);
    }
  }
}
