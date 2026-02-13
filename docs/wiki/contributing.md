
# Contributing (Advanced)

## Workflow
1. Fork and clone the repo
2. Create a feature branch (`feature/<your-feature>`)
3. Make changes (modular, provider-driven)
4. Run `flutter analyze` and `flutter pub run build_runner build`
5. Commit, push, open PR

## Code Style
- Modular files, separation of concerns
- UI logic in widgets, business logic in providers
- Use Riverpod generator, Drift ORM
- Command pattern for actions

## Testing
- Widget and provider tests
- Use test/widget_test.dart as template

## Issue Reporting
- Use GitHub Issues, provide steps and logs

## Pull Requests
- Reference issues, describe changes, ensure checks pass

## Community
- Respectful, collaborative, open source standards
- See [CODE_OF_CONDUCT.md](../CODE_OF_CONDUCT.md)
