import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight scaffold for an authentication service.
///
/// This file is a safe scaffold so agents can implement auth
/// integration incrementally. Do not add direct `firebase_auth`
/// imports until `firebase_options.dart` and platform config are present.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  /// Notifier for signed-in state (in-memory). When integrating real
  /// auth, update this notifier based on actual auth events.
  final ValueNotifier<bool> signedIn = ValueNotifier<bool>(false);
  final ValueNotifier<String> displayName = ValueNotifier<String>('');
  final ValueNotifier<String> _password = ValueNotifier<String>('');
  final ValueNotifier<String?> profilePicture = ValueNotifier<String?>(null);
  final ValueNotifier<String> city = ValueNotifier<String>('');

  /// Call during app startup if you want Auth initialized early.
  Future<void> init() async {
    debugPrint('AuthService.init() called - loading persisted state');
    try {
      final prefs = await SharedPreferences.getInstance();
      signedIn.value = prefs.getBool('signed_in') ?? false;
      displayName.value = prefs.getString('display_name') ?? '';
      _password.value = prefs.getString('password') ?? '';
      profilePicture.value = prefs.getString('profile_picture');
      city.value = prefs.getString('city') ?? '';
    } catch (e) {
      debugPrint('AuthService.init() failed to load prefs: $e');
    }
  }

  /// Example sign-in method. This marks the user as signed in and
  /// returns `true` to indicate success. Replace with real auth calls.
  Future<bool> signInAnonymously() async {
    debugPrint('AuthService.signInAnonymously() called - persisting state');
    signedIn.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('signed_in', true);
    } catch (e) {
      debugPrint('Failed to persist sign-in: $e');
    }
    return true;
  }

  /// Create a basic local account with a display name and password.
  /// The display name will be sanitized by `setDisplayName`.
  Future<bool> signUp(String name, String password) async {
    await setDisplayName(name);
    _password.value = password;
    signedIn.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('password', password);
      await prefs.setBool('signed_in', true);
    } catch (e) {
      debugPrint('Failed to persist sign-up: $e');
    }
    return true;
  }

  /// Sign in with a saved display name (sanitized) and password.
  /// Returns true if credentials match the persisted ones.
  Future<bool> signIn(String name, String password) async {
    final sanitized = name.replaceAll(RegExp(r"\s+"), '');
    final finalName = sanitized.isEmpty ? '' : (sanitized.startsWith('@') ? sanitized : '@$sanitized');
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedName = prefs.getString('display_name') ?? '';
      final storedPassword = prefs.getString('password') ?? '';
      if (storedName == finalName && storedPassword == password && finalName.isNotEmpty) {
        displayName.value = storedName;
        _password.value = storedPassword;
        signedIn.value = true;
        return true;
      }
    } catch (e) {
      debugPrint('Sign-in error: $e');
    }
    return false;
  }

  Future<void> setDisplayName(String name) async {
    // remove whitespace and ensure an '@' prefix for non-empty names
    final sanitized = name.replaceAll(RegExp(r"\s+"), '');
    final finalName = sanitized.isEmpty ? '' : (sanitized.startsWith('@') ? sanitized : '@$sanitized');
    displayName.value = finalName;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('display_name', finalName);
    } catch (e) {
      debugPrint('Failed to persist display name: $e');
    }
  }

  Future<void> setCity(String c) async {
    city.value = c;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('city', c);
    } catch (e) {
      debugPrint('Failed to persist city: $e');
    }
  }

  Future<void> setProfilePicture(String? path) async {
    profilePicture.value = path;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (path == null) {
        await prefs.remove('profile_picture');
      } else {
        await prefs.setString('profile_picture', path);
      }
    } catch (e) {
      debugPrint('Failed to persist profile picture: $e');
    }
  }

  /// Example sign-out method.
  Future<void> signOut() async {
    debugPrint('AuthService.signOut() called - persisting state');
    signedIn.value = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('signed_in', false);
    } catch (e) {
      debugPrint('Failed to persist sign-out: $e');
    }
  }
}
