
# FAQ (Deep)

## Data Layer
- Q: How is data stored?
	A: Drift ORM, schema migrations, indexed tables, efficient queries.
- Q: How are migrations handled?
	A: Automatic via Drift, see [architecture.md](architecture.md).

## State Management
- Q: Why Riverpod generator?
	A: Modern, maintainable, computed providers, separation of logic.

## UI/UX
- Q: How are widgets structured?
	A: Modular, reusable, pixel-perfect, command/modal patterns.

## Notifications
- Q: How do notifications work?
	A: NotificationService manages actions, updates, real-time sync.

## Platform
- Q: Which platforms are supported?
	A: Android, iOS, Linux, macOS, Windows, Web.

## Troubleshooting
- Q: Database issues?
	A: Run `flutter pub run build_runner build`, check schemaVersion.
- Q: UI bugs?
	A: Run `flutter analyze`, check provider/widget structure.

## Extending
- Q: How to add features?
	A: Add modules in lib/features/, use Riverpod/Drift, follow patterns.
