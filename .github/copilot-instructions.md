# Copilot / AI Agent Instructions — Scrap It Down

Purpose: Help an AI coding agent become productive quickly in this Flutter repo.

- **Big picture**: This is a small Flutter app (Dart SDK ^3.10.4). Entry point is `lib/main.dart` which initializes Firebase and runs `ScrapItDownApp` defined in `lib/app.dart`. UI lives under `lib/screens/` (e.g., `lib/screens/home_screen.dart`). Project follows a simple separation: `lib/services/` for integrations, `lib/models/` for data objects, and `lib/widgets/` for reusable UI — these folders are currently empty and intended as growth points.

- **Key files to inspect**:
  - `lib/main.dart` — app entry; calls `Firebase.initializeApp()` (important runtime dependency).
  - `lib/app.dart` — `MaterialApp` setup and theme.
  - `lib/screens/home_screen.dart` — simple example screen.
  - `test/widget_test.dart` — project's test; currently references `MyApp` which is stale (test likely needs updating to `ScrapItDownApp`).
  - `pubspec.yaml` — dependencies and Dart constraint.
  - `android/app/build.gradle.kts` — Android Gradle (Kotlin DSL) config.

- **Important integration notes (Firebase)**:
  - `lib/main.dart` calls `Firebase.initializeApp()` but there is no `firebase_options.dart` or platform config in the repo. Before running the app, a developer must add platform Firebase config:
    - Android: `android/app/google-services.json` + Gradle plugin configuration.
    - iOS: `ios/Runner/GoogleService-Info.plist`.
    - Or generate `lib/firebase_options.dart` using the FlutterFire CLI.
  - Typical setup commands (developer-run, not performed by agent):
    - `dart pub global activate flutterfire_cli`
    - `flutterfire configure --project <PROJECT_ID>`
  - If making changes to Firebase setup, update `android/app/build.gradle.kts` and iOS Runner settings accordingly.

  - Step-by-step Firebase setup (concise):
   1. Install the FlutterFire CLI (local dev machine):
     - `dart pub global activate flutterfire_cli`
   2. From the project root, run the interactive config to generate `lib/firebase_options.dart`:
     - `flutterfire configure --project <PROJECT_ID>`
     - This will prompt for platforms and can output `lib/firebase_options.dart` which the app can import.
   3. Android (manual fallback):
     - Add `android/app/google-services.json` (from Firebase console) to the `android/app/` directory.
     - Confirm the Android Gradle plugin and `com.google.gms:google-services` setup in the Android Gradle files; with Kotlin DSL you will typically add the plugin to the app module. See official Firebase docs for Kotlin DSL specifics.
   4. iOS (manual fallback):
     - Add `GoogleService-Info.plist` to `ios/Runner/` and make sure it is included in the Runner Xcode target.
   5. Web:
     - `flutterfire configure` can also produce web configuration. Alternatively copy the Firebase SDK config into `web/index.html` or a dart const map and use it when initializing.
   6. Desktop (macOS/Windows/Linux):
     - Desktop support sometimes requires additional native setup; prefer `flutterfire configure` when supported. If you target desktop and the CLI does not cover it, follow the native platform docs in the Firebase console and the FlutterFire docs.
   7. Verify locally by running a small init: the app already calls `Firebase.initializeApp()` in `lib/main.dart`. If initialization fails, check for `firebase_options.dart` or missing platform files.

  - Notes for agents: do not attempt to commit private config files (`google-services.json` or `GoogleService-Info.plist`) to public repos. Prefer instructions and TODOs in code and let developers add their own platform files or run `flutterfire configure` locally.

- **Build / run / test workflows (project-specific notes)**:
  - Fetch deps: `flutter pub get`.
  - Run (mobile): `flutter run` (add `-d <device>` as needed). For Windows desktop: `flutter run -d windows`.
  - Build: `flutter build apk` / `flutter build ios` / `flutter build windows` as appropriate.
  - Tests: `flutter test` — note the existing `test/widget_test.dart` appears outdated and may fail until updated.
  - Static analysis: `flutter analyze` (project uses `flutter_lints` via `analysis_options.yaml`).

- **Project conventions and patterns**:
  - Prefer `const` constructors where possible (project already uses `const` in widgets).
  - Dark theme is the default (`ThemeData.dark()` in `lib/app.dart`).
  - Keep integration code under `lib/services/` and platform configuration in `android/` and `ios/` folders.
  - Gradle uses Kotlin DSL files (`build.gradle.kts`) — edits to Android Gradle should follow Kotlin DSL conventions.

- **Common agent tasks & examples**:
  - Add a new service: create `lib/services/auth_service.dart` and export it from a barrel file under `lib/services/`.
    - Example: register any synchronous initialization before `runApp()` in `lib/main.dart`; for async setup keep `WidgetsFlutterBinding.ensureInitialized()` and await initialization as already done.
  - Update the test: replace `MyApp` with `ScrapItDownApp` in `test/widget_test.dart` to reflect current app class name.
  - Add Firebase safely: detect missing `firebase_options.dart` and add a TODO comment in `lib/main.dart` if runner config is absent.

- **Known pitfalls / discovery notes**:
  - Tests may be stale (see `test/widget_test.dart`).
  - Firebase initialization is present but platform config is not; attempting to `flutter run` on a device will fail without proper Firebase setup.
  - `lib/services/`, `lib/models/`, and `lib/widgets/` are empty — expect to scaffold new files rather than editing existing service code.

If any of the above assumptions are wrong (for example, you have private Firebase config not checked in), tell me which files to inspect and I will merge/adjust these instructions. Ready to update based on your feedback.
