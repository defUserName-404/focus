// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks_pane_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TasksPaneFormNotifier)
final tasksPaneFormProvider = TasksPaneFormNotifierProvider._();

final class TasksPaneFormNotifierProvider extends $NotifierProvider<TasksPaneFormNotifier, TasksPaneForm?> {
  TasksPaneFormNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksPaneFormProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksPaneFormNotifierHash();

  @$internal
  @override
  TasksPaneFormNotifier create() => TasksPaneFormNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TasksPaneForm? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<TasksPaneForm?>(value));
  }
}

String _$tasksPaneFormNotifierHash() => r'e9d83b9e6af68f61ce416d44a72747574fbda21f';

abstract class _$TasksPaneFormNotifier extends $Notifier<TasksPaneForm?> {
  TasksPaneForm? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TasksPaneForm?, TasksPaneForm?>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<TasksPaneForm?, TasksPaneForm?>, TasksPaneForm?, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
