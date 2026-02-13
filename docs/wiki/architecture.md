
# Architecture (Deep)

## Layered Structure
- **Core**: Utilities, constants, services (db, notification, audio)
- **Features**: Modular folders for projects, tasks, focus sessions
- **Providers**: Riverpod state/computed providers, generator-based
- **Widgets**: Reusable UI components (cards, search bars, modals)

## Data Layer
- Drift ORM for local storage
- Schema migrations, indexing (@TableIndex)
- Efficient querying: watchProjectById, sort/filter at ORM level
- Migration strategy for schemaVersion bumps

## State Management
- Riverpod (generator, computed providers)
- Separation of UI and business logic
- Expansion, project, task, session, ambience providers

## UI/UX
- Modular widgets, pixel-perfect alignment
- Modal forms, confirmation dialogs, command pattern
- Search, sort, filter chips

## Notification & Ambience
- NotificationService: actions, updates, real-time sync
- AmbienceMuteProvider, AmbienceMarqueeProvider
- MarqueeText widget: animation, pause/stop logic

## Platform
- Cross-platform code, platform-specific folders
- Asset management: animations, audio, fonts, images

## Extensibility
- Add features as modules in lib/features/
- Use Riverpod for state, Drift for data
- Follow command/modal/provider/widget patterns
