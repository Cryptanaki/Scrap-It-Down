Release signing for Android

This project includes instructions to create a keystore, configure Gradle signing, and build a release-signed APK.

1) Generate a keystore locally (replace paths/passwords as needed):

```bash
keytool -genkey -v -keystore ~/scrapitdown-release.jks -alias scrapitdown_key -keyalg RSA -keysize 2048 -validity 10000
```

2) Add the following properties to your `android/gradle.properties` (do NOT commit these to source control):

```
RELEASE_STORE_FILE=/absolute/path/to/scrapitdown-release.jks
RELEASE_STORE_PASSWORD=your_store_password
RELEASE_KEY_ALIAS=scrapitdown_key
RELEASE_KEY_PASSWORD=your_key_password
```

3) Example `android/app/build.gradle.kts` signing config snippet (insert inside `android {}`):

```kotlin
signingConfigs {
    create("release") {
        storeFile = file(System.getenv("RELEASE_STORE_FILE") ?: project.property("RELEASE_STORE_FILE") as String)
        storePassword = System.getenv("RELEASE_STORE_PASSWORD") ?: project.property("RELEASE_STORE_PASSWORD") as String
        keyAlias = System.getenv("RELEASE_KEY_ALIAS") ?: project.property("RELEASE_KEY_ALIAS") as String
        keyPassword = System.getenv("RELEASE_KEY_PASSWORD") ?: project.property("RELEASE_KEY_PASSWORD") as String
    }
}

buildTypes {
    getByName("release") {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = false
    }
}
```

4) Build the release APK locally:

```bash
flutter build apk --release
```

Notes:
- Keep your keystore and passwords secret; do not commit them.
- If `keytool` or `java` is not installed, install OpenJDK (JDK 11+ recommended).
- The CI/CD pipeline should use environment variables or secret storage to provide keystore paths/passwords.
