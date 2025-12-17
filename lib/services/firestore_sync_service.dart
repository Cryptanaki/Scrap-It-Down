import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:scrap_it_down/models/post.dart';

/// Firestore sync service with optional live-listen support.
class FirestoreSyncService {
  FirestoreSyncService._();
  static final FirestoreSyncService instance = FirestoreSyncService._();

  bool _enabled = false;
  FirebaseFirestore? _db;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  Future<void> initIfPossible() async {
    if (_enabled) return;
    try {
      // If Firebase has not been initialized by the app entrypoint,
      // attempt a safe initialize here (no options). If the app uses
      // generated `firebase_options.dart` it may have already been
      // initialized in `main()`; otherwise native platform files
      // (google-services.json / Info.plist) will be used by the
      // default initialization when available.
      if (Firebase.apps.isEmpty) {
        try {
          await Firebase.initializeApp();
        } catch (e) {
          // initialization may fail if platform config is missing — that's OK
          debugPrint('FirestoreSyncService: Firebase.initializeApp() skipped/failed: $e');
        }
      }
      if (Firebase.apps.isEmpty) return;
      _db = FirebaseFirestore.instance;
      _enabled = true;
    } catch (e) {
      debugPrint('FirestoreSyncService: Firebase unavailable: $e');
      _enabled = false;
    }
  }

  bool get enabled => _enabled && _db != null;

  Future<void> pushPost(Post p) async {
    if (!enabled) return;
    try {
      // Use merge to avoid unintentionally overwriting other fields
      await _db!.collection('posts').doc(p.id).set(p.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('pushPost failed: $e');
    }
  }

  Future<void> removePost(String id) async {
    if (!enabled) return;
    try {
      await _db!.collection('posts').doc(id).delete();
    } catch (e) {
      debugPrint('removePost failed: $e');
    }
  }

  /// Start listening for remote posts and deliver them to [onChange].
  void startListening(void Function(List<Post> remote) onChange) {
    if (!enabled || _db == null) return;
    _sub?.cancel();
    _sub = _db!.collection('posts').snapshots().listen((snap) {
      try {
        final items = snap.docs.map((d) {
          final data = d.data();
          // Ensure 'id' is present
          if (!data.containsKey('id')) data['id'] = d.id;
          // Firestore may return nested lists/maps as dynamic; normalize before mapping
          final normalized = <String, dynamic>{};
          data.forEach((k, v) {
            normalized[k] = v;
          });
          return Post.fromMap(Map<String, dynamic>.from(normalized));
        }).toList();
        onChange(items);
      } catch (e) {
        debugPrint('Firestore listen parse error: $e');
      }
    }, onError: (e) {
      debugPrint('Firestore listen error: $e');
    });
  }

  void stopListening() {
    _sub?.cancel();
    _sub = null;
  }
}
