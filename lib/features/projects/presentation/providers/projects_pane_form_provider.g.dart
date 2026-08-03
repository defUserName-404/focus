// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projects_pane_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProjectsPaneFormNotifier)
final projectsPaneFormProvider = ProjectsPaneFormNotifierProvider._();

final class ProjectsPaneFormNotifierProvider extends $NotifierProvider<ProjectsPaneFormNotifier, ProjectsPaneForm?> {
  ProjectsPaneFormNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectsPaneFormProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectsPaneFormNotifierHash();

  @$internal
  @override
  ProjectsPaneFormNotifier create() => ProjectsPaneFormNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProjectsPaneForm? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<ProjectsPaneForm?>(value));
  }
}

String _$projectsPaneFormNotifierHash() => r'651e71b4f009d9518578098ab08bf76dabc8b843';

abstract class _$ProjectsPaneFormNotifier extends $Notifier<ProjectsPaneForm?> {
  ProjectsPaneForm? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ProjectsPaneForm?, ProjectsPaneForm?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProjectsPaneForm?, ProjectsPaneForm?>,
              ProjectsPaneForm?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
