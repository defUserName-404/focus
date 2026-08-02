// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_template_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(projectTemplateService)
final projectTemplateServiceProvider = ProjectTemplateServiceProvider._();

final class ProjectTemplateServiceProvider
    extends $FunctionalProvider<ProjectTemplateService, ProjectTemplateService, ProjectTemplateService>
    with $Provider<ProjectTemplateService> {
  ProjectTemplateServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectTemplateServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectTemplateServiceHash();

  @$internal
  @override
  $ProviderElement<ProjectTemplateService> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  ProjectTemplateService create(Ref ref) {
    return projectTemplateService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProjectTemplateService value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<ProjectTemplateService>(value));
  }
}

String _$projectTemplateServiceHash() => r'126b97ad48dcd11f69321ca6c64380a8e6b1cde3';

@ProviderFor(projectTemplates)
final projectTemplatesProvider = ProjectTemplatesProvider._();

final class ProjectTemplatesProvider
    extends $FunctionalProvider<AsyncValue<List<ProjectTemplate>>, List<ProjectTemplate>, Stream<List<ProjectTemplate>>>
    with $FutureModifier<List<ProjectTemplate>>, $StreamProvider<List<ProjectTemplate>> {
  ProjectTemplatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectTemplatesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectTemplatesHash();

  @$internal
  @override
  $StreamProviderElement<List<ProjectTemplate>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<ProjectTemplate>> create(Ref ref) {
    return projectTemplates(ref);
  }
}

String _$projectTemplatesHash() => r'0cc0f792506d5ff00dfca7ed6e70285e45a18315';
