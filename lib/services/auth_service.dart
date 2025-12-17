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
  final ValueNotifier<String> city = ValueNotifier<String>('');

  /// Call during app startup if you want Auth initialized early.
  Future<void> init() async {
    debugPrint('AuthService.init() called - loading persisted state');
    try {
      final prefs = await SharedPreferences.getInstance();
      signedIn.value = prefs.getBool('signed_in') ?? false;
      displayName.value = prefs.getString('display_name') ?? '';
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
