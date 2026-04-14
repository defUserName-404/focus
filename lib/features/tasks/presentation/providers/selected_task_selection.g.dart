// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_task_selection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedTaskSelection)
final selectedTaskSelectionProvider = SelectedTaskSelectionProvider._();

final class SelectedTaskSelectionProvider extends $NotifierProvider<SelectedTaskSelection, TaskSelection?> {
  SelectedTaskSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedTaskSelectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedTaskSelectionHash();

  @$internal
  @override
  SelectedTaskSelection create() => SelectedTaskSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskSelection? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<TaskSelection?>(value));
  }
}

String _$selectedTaskSelectionHash() => r'191322509414ca332b94a395f70422713b38c11a';

abstract class _$SelectedTaskSelection extends $Notifier<TaskSelection?> {
  TaskSelection? build();

  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TaskSelection?, TaskSelection?>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<TaskSelection?, TaskSelection?>, TaskSelection?, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
