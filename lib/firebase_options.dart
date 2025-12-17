// Placeholder firebase_options.dart
//
// This file is intentionally minimal so developers and CI do not fail
// when `lib/firebase_options.dart` is referenced by TODOs or docs.
//
// To generate a real `firebase_options.dart`, run locally:
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project <PROJECT_ID>
//
// DO NOT commit real platform config files (google-services.json,
// GoogleService-Info.plist) or secrets to a public repository.

// This file provides a harmless stub for `DefaultFirebaseOptions` so
// the codebase can compile and run in development without the
// real FlutterFire-generated file. Replace this file with the
// output of `flutterfire configure` for real Firebase options.

import 'package:firebase_core/firebase_core.dart';

/// Stub class emulating the FlutterFire-generated `DefaultFirebaseOptions`.
///
/// `currentPlatform` returns `null` here; when the real file is present
/// it should return a non-null `FirebaseOptions` for the current platform.
class DefaultFirebaseOptions {
	DefaultFirebaseOptions._();
	static FirebaseOptions? get currentPlatform => null;
}
