# scrap_it_down

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Local build notes

This repo includes a minimal placeholder `app/google-services.json` to allow the Windows build helpers to run without failing. Do NOT use this placeholder in production — replace it with your real `google-services.json` from the Firebase console or run `flutterfire configure` to generate platform config.

If you want to remove Firebase from native builds, delete or replace `app/google-services.json` before building.

### Debugger attach notes (Windows)

Sometimes `flutter run -d windows` builds successfully but the Flutter tool fails to attach the debugger ("Error waiting for a debug connection"). Workarounds:

- Launch the built executable directly:

```powershell
Start-Process build\\windows\\x64\\runner\\Debug\\scrap_it_down.exe
```

- Re-run with a fresh build:

```powershell
flutter clean
flutter build windows -v
flutter run -d windows
```

- If the debugger still won't attach, try disabling interfering antivirus/firewall software, or run the app without debugger and use logs printed to the terminal or Windows Event Viewer.
