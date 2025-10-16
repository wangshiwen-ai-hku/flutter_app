@# Repository Guidelines

## Project Structure & Module Organization
- `lib/` contains the core Flutter widgets, app entry (`lib/main.dart`), and domain logic.
- `test/` holds widget and unit coverage; mirror `lib/` naming so files like `lib/home.dart` map to `test/home_test.dart`.
- `assets/` stores static media declared in `pubspec.yaml`; update the manifest when adding files such as `page1.png`.
- Platform shells live in `android/`, `ios/`, `web/`, `macos/`, `linux/`, and `windows/`; keep platform-specific tweaks isolated there.
- Shared lint configuration sits in `analysis_options.yaml`; discuss before modifying project-wide rules.

## Build, Test, and Development Commands
- `flutter pub get` fetches or updates dependencies after cloning or pulling.
- `flutter run -d <device>` launches the app on the chosen emulator or device for interactive testing.
- `flutter analyze` runs static analysis and enforces the lint set from `package:flutter_lints`.
- `flutter test --coverage` executes the test suite and produces a coverage report under `coverage/`.
- `flutter build apk --release` generates a release APK artifact for Android handoff.

## Coding Style & Naming Conventions
- Follow Dart defaults: 2-space indentation, PascalCase for widgets and classes, lowerCamelCase for methods, variables, and test names.
- Split large widgets into focused components under `lib/widgets/` or feature folders to keep files concise.
- Run `dart format lib test` before committing; add `dart format <file>` in staged hotfixes.
- Prefer single quotes for strings unless interpolation or apostrophes require double quotes; add inline `// ignore` only with justification.

## Testing Guidelines
- Use `flutter test` locally before pushing; add `--coverage` when validating threshold expectations.
- Structure widget tests with `testWidgets` and descriptive finder labels; avoid time-based waits.
- Aim to keep logic branches covered; call out uncovered areas in the PR if trade-offs are necessary.

## Commit & Pull Request Guidelines
- Write concise imperative commit subjects (e.g., `add app`); group related changes and avoid mixed concerns.
- Reference issues or tasks in the PR body, summarize the intent, and list the commands run (e.g., `flutter analyze`, `flutter test`).
- Attach screenshots or recordings for UI-affecting changes across major platforms when practical.
- Ensure CI is green before requesting merge and tag at least one reviewer familiar with the touched area.

## Environment & Asset Tips
- Align on the Flutter SDK version noted in `README.md`; run `flutter --version` when syncing machines.
- Register any new font or image in `pubspec.yaml` and document UX-relevant assets in `APP.md` for designers.
