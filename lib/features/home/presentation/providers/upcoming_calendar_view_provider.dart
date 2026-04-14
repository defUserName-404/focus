import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/result.dart';
import '../../../settings/domain/entities/setting.dart';
import '../../../settings/domain/services/settings_service.dart';

part 'upcoming_calendar_view_provider.g.dart';

enum CalendarViewMode { month, week }

extension CalendarViewModeCodec on CalendarViewMode {
  String get storageValue => switch (this) {
    CalendarViewMode.month => 'month',
    CalendarViewMode.week => 'week',
  };

  static CalendarViewMode fromStorage(String? value) {
    return switch (value) {
      'week' => CalendarViewMode.week,
      _ => CalendarViewMode.month,
    };
  }
}

@Riverpod(keepAlive: true)
class UpcomingCalendarViewModeNotifier extends _$UpcomingCalendarViewModeNotifier {
  late final SettingsService _settingsService;

  @override
  FutureOr<CalendarViewMode> build() async {
    _settingsService = getIt<SettingsService>();
    final raw = await _settingsService.getValue(SettingsKeys.homeCalendarViewMode);
    return CalendarViewModeCodec.fromStorage(raw);
  }

  Future<void> setMode(CalendarViewMode mode) async {
    state = AsyncValue.data(mode);

    final result = await _settingsService.setValue(SettingsKeys.homeCalendarViewMode, mode.storageValue);
    if (result case Failure(:final failure)) {
      state = AsyncValue.error(failure, StackTrace.current);
    }
  }
}
