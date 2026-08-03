// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks_master_pane_width_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TasksMasterPaneWidth)
final tasksMasterPaneWidthProvider = TasksMasterPaneWidthProvider._();

final class TasksMasterPaneWidthProvider extends $AsyncNotifierProvider<TasksMasterPaneWidth, double> {
  TasksMasterPaneWidthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksMasterPaneWidthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksMasterPaneWidthHash();

  @$internal
  @override
  TasksMasterPaneWidth create() => TasksMasterPaneWidth();
}

String _$tasksMasterPaneWidthHash() => r'ff92117b854f6cb570425e4df79ee4e6cae062e5';

abstract class _$TasksMasterPaneWidth extends $AsyncNotifier<double> {
  FutureOr<double> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<double>, double>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<AsyncValue<double>, double>, AsyncValue<double>, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
