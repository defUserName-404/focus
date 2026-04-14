// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_insights_window_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReportsInsightsWindowNotifier)
final reportsInsightsWindowProvider = ReportsInsightsWindowNotifierProvider._();

final class ReportsInsightsWindowNotifierProvider
    extends
        $AsyncNotifierProvider<
          ReportsInsightsWindowNotifier,
          InsightsWindowMode
        > {
  ReportsInsightsWindowNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportsInsightsWindowProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportsInsightsWindowNotifierHash();

  @$internal
  @override
  ReportsInsightsWindowNotifier create() => ReportsInsightsWindowNotifier();
}

String _$reportsInsightsWindowNotifierHash() =>
    r'fa46e326dd259ae4cd5a016f9e5d41c4694bc9df';

abstract class _$ReportsInsightsWindowNotifier
    extends $AsyncNotifier<InsightsWindowMode> {
  FutureOr<InsightsWindowMode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<InsightsWindowMode>, InsightsWindowMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<InsightsWindowMode>, InsightsWindowMode>,
              AsyncValue<InsightsWindowMode>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
