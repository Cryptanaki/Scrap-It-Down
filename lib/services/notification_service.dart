import 'package:flutter/foundation.dart';
import 'package:scrap_it_down/models/post.dart';

/// Simple local notification service stub.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final ValueNotifier<Post?> lastFreePost = ValueNotifier<Post?>(null);

  // Users who have top-picker notifications enabled
  final ValueNotifier<Set<String>> topPickers = ValueNotifier<Set<String>>({});

  void notifyFreePost(Post p) {
    lastFreePost.value = p;
  }

  bool isTopPicker(String user) => topPickers.value.contains(user);

  void setTopPicker(String user, bool enabled) {
    final s = Set<String>.from(topPickers.value);
    if (enabled) {
      s.add(user);
    } else {
      s.remove(user);
    }
    topPickers.value = s;
  }
}
