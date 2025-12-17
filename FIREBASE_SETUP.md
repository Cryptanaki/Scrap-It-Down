Firebase setup (FlutterFire)

This project includes a lightweight Firestore sync scaffold that will work when Firebase is configured. To enable Firebase locally follow these steps:

1) Install the FlutterFire CLI locally:

```bash
dart pub global activate flutterfire_cli
```

2) From the project root run the interactive configure command and choose platforms:

```bash
flutterfire configure --project <YOUR_FIREBASE_PROJECT_ID>
```

This will generate `lib/firebase_options.dart` and update necessary platform config. Do NOT commit private platform files (google-services.json, GoogleService-Info.plist) to public repos.

3) After configuring, run:

```bash
flutter pub get
flutter run
```

4) Notes about the sync scaffold:
- The app writes local posts to Firestore when available. The `FirestoreSyncService` also listens for remote changes and merges them into the local cache (simple merge: remote wins when `createdAt` is later).
- For robust multi-user behavior you should add an `updatedAt` field and implement per-field merge/conflict resolution and security rules in Firestore.

If you want, I can scaffold Firestore security rules and a migration path from local SharedPreferences to Firestore documents.
