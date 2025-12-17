Summary:
- Expanded `.github/copilot-instructions.md` with platform-by-platform Firebase setup and agent guidance.
- Added a safe scaffold `lib/services/auth_service.dart` and barrel `lib/services/services.dart`.
- Added a runtime warning/TODO around `Firebase.initializeApp()` in `lib/main.dart`.
- Updated `test/widget_test.dart` to use `ScrapItDownApp` and assert the welcome text.
- Added `CHANGELOG.md` (Unreleased) and `.github/PULL_REQUEST_TEMPLATE.md`.

Files changed (high level):
- [.github/copilot-instructions.md](.github/copilot-instructions.md)
- [lib/main.dart](lib/main.dart)
- [lib/services/auth_service.dart](lib/services/auth_service.dart)
- [lib/services/services.dart](lib/services/services.dart)
- [test/widget_test.dart](test/widget_test.dart)
- [CHANGELOG.md](CHANGELOG.md)
- [.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md)

Testing:
- Run `flutter test` locally — updated tests pass.
- Run `flutter analyze` to check for lint issues.

Notes for reviewer:
- `AuthService` is intentionally a non-op scaffold (no `firebase_auth` dependency) to avoid adding platform config or secrets.
- Do NOT commit private Firebase files (`google-services.json`, `GoogleService-Info.plist`) to the repository.

Suggested labels: `chore`, `docs`.
