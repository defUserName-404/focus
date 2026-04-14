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

## Import Order

Use this order with a blank line between groups:

1. Dart SDK imports
2. Flutter imports
3. Third-party package imports
4. `package:focus/...` imports
5. Relative imports

Example:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:forui/forui.dart' as fu;

import 'package:focus/core/constants/app_constants.dart';

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

## Riverpod Rules

- Prefer Riverpod-managed state over local widget state for shared or persisted behavior.
- Use provider code generation consistently.
- Keep provider names explicit and feature-scoped.
- Use stream providers for reactive Drift-backed lists/details.

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
- Use app constants/theme tokens for spacing/sizing.
- Must avoid hardcoded spacing when a semantic constant exists.
- Avoid duplicate padding through nested wrappers (`FScaffold` + extra constrained wrappers).
- Always put a single widget on their own files, no two widgets should live on the same file.
- Always break larger widgets into smaller widgets. The widgets which are required by other classes should only be the ones with public. otherwise they should be private. those should be declared as part of directive by only the used screen.
- Common widgets, re-used widgets should be moved to the core level.
- Code duplication and non-reuse is heavily discouraged. 

## Forms and Date/Time Rules

- Keep date/time field behavior consistent across create/edit screens.
- Clearing a time field should map to null value where supported by business rules.
- Keep shared field behavior in reusable core widgets.

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
- No stale `.g.dart` dependency errors
- AGENTS and `.agents` docs updated when change is significant
