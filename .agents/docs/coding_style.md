# Focus Coding Style

This document defines the coding style expected from coding agents in Focus.

## Formatting

- Use `dart format . --line-length=120`
- Max line width: 120
- Use 2-space indentation
- Prefer trailing commas for multi-line parameter lists
- Keep functions focused and small when practical
- Must avoid too much unnecessary comments like # Singleton class etc. Only need to add comments where intent might not be clear.
- Must avoid emdashes on the comments.
- Within a function, there should not be any blank lines.
- Between two functions on a class there should exactly be one blank line.

## Generated File Policy

- Never manually edit generated files (`*.g.dart`, `*.mapper.dart`).
- Refactor only source files, then regenerate artifacts.
- For Riverpod provider changes, update source provider files and run codegen.

## Import Order

Use this order with a blank line between groups:

1. Dart SDK imports
2. Flutter imports
3. Third-party package imports
4. Relative imports
Always use relative import for this project's files

Example:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:forui/forui.dart' as fu;

import '../providers/project_provider.dart';
```

## Naming Conventions

- Classes/types: `PascalCase`
- Variables/methods: `camelCase`
- Private members: `_camelCase`
- Files/directories: `snake_case`
- Repository interfaces: `I<Name>Repository`
- Repository implementations: `<Name>RepositoryImpl`
- Service classes: `<Feature>Service`
- Providers: `<name>Provider`

## Architecture and Organization Rules

- Follow feature-first clean architecture (`data`, `domain`, `presentation`).
- Keep presentation-only models in `presentation/models`.
- Keep domain free from UI/presentation concerns.
- Avoid introducing business logic in widgets.
- The repositories, usecases, etc should always be handled by the get_it. It should be registered as lazy singletons where ever applicable.
- Riverpod should strictly maintain the presentation layer's state. It should not be used as dependency injection.

## Riverpod Rules

- Prefer Riverpod-managed state over local widget state for shared or persisted behavior.
- Use provider code generation consistently.
- Keep provider names explicit and feature-scoped.
- Use stream providers for reactive Drift-backed lists/details.
- Keep provider source files focused: one provider/notifier concern per source file in `presentation/providers`.
- Do not hand-edit provider generated files.\
- Do not use set state or value notifers for state. they should always be managed by the riverpod.
- In riverpod the state classes should be in differnt files from the providers themselves.
 

After provider annotation changes, regenerate code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Error Handling Rules

- Service layer should return `Result<T>` for fallible operations.
- Avoid throwing from service methods for expected failures.
- Use exhaustive handling at call sites (`switch` on `Success`/`Failure`).

Pattern:

```dart
final result = await service.createProject(title: title);
switch (result) {
  case Success(:final value):
    // success path
  case Failure(:final failure):
    // error path
}
```

## Logging Rules

Do not use `print` or `debugPrint`.
Use `LogService`:

```dart
final _log = LogService.instance;

_log.debug('Message', tag: 'ClassName');
_log.info('Message', tag: 'ClassName');
_log.warning('Message', tag: 'ClassName', error: e, stackTrace: st);
_log.error('Message', tag: 'ClassName', error: e, stackTrace: st);
```

## UI and Spacing Rules

- Prefer ForUI widgets and styles already used in the codebase.
- MUST use app constants/theme tokens for spacing/sizing.
- Must avoid hardcoded spacing when a semantic constant exists.
- Avoid duplicate padding through nested wrappers (`FScaffold` + extra constrained wrappers).
- Widget files (`core/widgets`, `presentation/widgets`) must contain one public widget.
- Widget files must not contain additional private helper widget classes (except a private `State` companion for a `StatefulWidget`).
- Screen-local, non-reused helper widgets has to be private classes in the owning screen file, extracted into their own files by 'part' directive.
- Do not use widget-returning helper methods inside widgets/screens (`Widget _buildX(...)`); extract each subtree into its own widget class (private when screen-local).
- Common widgets, re-used widgets should be moved to the core level.
- Code duplication and non-reuse is heavily discouraged.

## Forms and Date/Time Rules

- Keep date/time field behavior consistent across create/edit screens.
- Clearing a time field should map to null value where supported by business rules.
- Keep shared field behavior in reusable core widgets.
- Date/time parsing and calculations must not live in screens/widgets.
- Move date/time arithmetic and parsing into `core/utils` or domain/service helpers.
- UI should only render prepared date/time values.

## SOLID and Reuse Rules

- Respect SRP: each class/file should have one primary responsibility.
- Respect DRY: if create/edit flows share structure, extract shared form widgets and helpers.
- Keep screen orchestration in screens and move reusable form sections into dedicated widgets.
- Keep business decision logic out of widgets and in providers/services.
- Depend on abstractions in domain/data boundaries (`I<Feature>Repository` pattern).
- Avoid large multi-concern UI files; split into smaller widget units.

## Database and Migration Rules

For Drift schema changes:
1. Update table definitions.
2. Increment schema version.
3. Add `onUpgrade` migration logic.
4. Run codegen.
5. Validate migration scenarios.

## Pre-Commit Checklist

- Code formatted (`dart format`)
- Analyzer clean (`flutter analyze`)
- Codegen updated when required
- No `print`/`debugPrint`
- No architecture boundary violations
- No manual edits in generated files (`*.g.dart`, `*.mapper.dart`)
- No widget helper methods (`Widget _...`) inside widgets/screens
- No date/time parsing or arithmetic in widgets/screens
- No stale `.g.dart` dependency errors
- AGENTS and `.agents` docs updated when change is significant
