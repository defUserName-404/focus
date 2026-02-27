# Focus

Focus is a fully offline, privacy-first productivity app for managing your projects, tasks, and deep work sessions. Designed for makers, students, and professionals, Focus helps you organize your work, track progress, and maintain flow—all without ever needing an internet connection. Your data stays 100% on your device.

## What this app offers
- **You own your data**: This is a full offline app. All features work without an internet connection. Your data stays on your device.
- **Deep Work Focus**: Manage focus sessions with timers, breaks, and ambience controls for optimal productivity.
- **Hierarchical Organization**: Organize your work with projects, tasks, and subtasks, each with progress tracking and metadata.
- **Real-Time Feedback**: Get live notifications for session status, play position, and ambience changes, with interactive notification actions (pause, resume, stop).
- **Powerful Search & Organization**: Quickly find, sort, and filter your projects and tasks using search bars, filter chips, and sort order selectors.
- **Modern, Modular UI**: Enjoy a pixel-perfect, responsive interface built with reusable widgets and modal forms, supporting both light and dark themes.
- **Cross-Platform**: Use Focus on Android, iOS, Linux, macOS, Windows, and Web—all from a single codebase.
- **Open Source & Extensible**: Built with Riverpod state management and Drift ORM, the codebase is clean, modular, and easy to contribute to or extend.
- **Activity stats:** Pre-aggregated daily session statistics with DB-backed recalculation for activity/usage graphs.
- **Automatic task handling:** Sessions can auto-complete associated tasks and the app cleans up abandoned sessions on startup.
- **Media & hardware controls:** Media-button, lock-screen, and hardware controls are wired to session actions (pause/resume/skip/stop).
- **Audio & alarms:** Ambience presets with live-reload of audio preferences and configurable alarm playback.
- **Background notifications:** Actionable notifications with background handlers for pause/resume/stop/skip.


## App Showcase

<table>
  <tr>
    <td align="center">
      <img src="screenshots/Apple iPhone 16 Pro Max Screenshot 1.png">
    </td>
    <td align="center">
      <img src="screenshots/Apple iPhone 16 Pro Max Screenshot 2.png">
    </td>
    <td align="center">
      <img src="screenshots/Apple iPhone 16 Pro Max Screenshot 3.png">
    </td>
    <td align="center">
      <img src="screenshots/Apple iPhone 16 Pro Max Screenshot 4.png">
    </td>
  </tr>
</table>

## Documentation
Please visit the [GitHub Wiki](https://github.com/defUserName-404/focus/wiki) for the latest guides, usage instructions, and developer information.

## Getting Started
See <a href="docs/wiki/getting_started.md">docs/wiki/getting_started.md</a> for setup instructions.

## License
This project is open source. See LICENSE for details.

Testing and backup:
- Always back up the existing `focus.sqlite` file before testing a migration on device/emulator.
- To verify migration locally, run the app on a device/emulator with a copy of your DB and confirm rows are preserved after upgrade and deletes cascade as expected.
- If you want an automated check, I can prepare a test harness that constructs a v1 DB, runs the upgrade, and asserts data integrity.
