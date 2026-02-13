
# Getting Started (Advanced)

## Prerequisites
- Flutter SDK >= 3.10.0
- Dart >= 3.0.0
- Git
- Drift ORM (auto-installed via pubspec)

## Installation
1. Clone the repo:
  ```bash
  git clone https://github.com/defUserName-404/focus.git
  cd focus
  ```
2. Install dependencies:
  ```bash
  flutter pub get
  ```
3. Generate code:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```
4. Run the app:
  ```bash
  flutter run
  ```

## Database Migration
- Drift handles schema migrations automatically.
- See [architecture.md](architecture.md) for migration strategy.

## Platform Notes
- For desktop/web, see Flutter docs for setup.
- For mobile, configure Android/iOS as per standard Flutter guides.

## Troubleshooting
- Run `flutter doctor` for environment checks.
- For database issues, see [faq.md](faq.md).
