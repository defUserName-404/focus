# Deep Project Overview

Focus is a cross-platform productivity app for managing projects, tasks, and focus sessions. It combines advanced data modeling, modular UI, and robust state management to deliver a seamless experience for end users and contributors.

## Key Concepts
- **Projects, Tasks, Subtasks**: Hierarchical management with CRUD, progress tracking, and metadata.
- **Focus Sessions**: Timed sessions with break/ambience logic, notification integration, and session state.
- **Data Layer**: Drift ORM, schema migrations, indexing, and efficient querying.
- **State Management**: Riverpod (modern generator), computed providers, separation of UI and business logic.
- **UI/UX**: Modular widgets, pixel-perfect cards, modal forms, search/sort/filter, responsive design.
- **Notifications & Ambience**: Custom notification actions, real-time updates, ambience mute/unmute, marquee animation.
- **Command Pattern**: Standardized actions for project/task operations.
- **Platform Support**: Android, iOS, Linux, macOS, Windows, Web.
- **CI/CD & Docs**: Automated Android/iOS builds and GitHub releases on version tags; docs/wiki auto-synced to GitHub Wiki.

## Architecture
See [architecture.md](architecture.md) for a full breakdown.

## History
See [changelog.md](changelog.md) for major milestones and refactors.
