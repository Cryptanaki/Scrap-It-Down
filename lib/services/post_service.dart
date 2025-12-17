import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrap_it_down/models/post.dart';
import 'package:scrap_it_down/models/comment.dart';
import 'rating_service.dart';
import 'notification_service.dart';
import 'firestore_sync_service.dart';

class PostService {
  PostService._();
  static final PostService instance = PostService._();

  static const _kPostsKey = 'posts_v1';

  final ValueNotifier<List<Post>> posts = ValueNotifier<List<Post>>([]);

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_kPostsKey) ?? <String>[];
      posts.value = raw.map((s) => Post.fromJson(s)).toList();
      // initialize Firestore sync if possible
      await FirestoreSyncService.instance.initIfPossible();
      if (FirestoreSyncService.instance.enabled) {
        FirestoreSyncService.instance.startListening((remote) async {
          try {
            _mergeRemotePosts(remote);
            await _save();
          } catch (e) {
            debugPrint('PostService merge error: $e');
          }
        });
      }
    } catch (e) {
      debugPrint('PostService.init failed: $e');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = posts.value.map((p) => p.toJson()).toList();
      await prefs.setStringList(_kPostsKey, raw);
    } catch (e) {
      debugPrint('PostService._save failed: $e');
    }
  }

  List<Post> postsForCategory(String category) {
    return posts.value.where((p) => p.category == category).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addPost(Post post) async {
    posts.value = [post, ...posts.value];
    await _save();
    // Notify potential top-pickers if this is a free scrap/e-waste post.
    if (post.isFree && (post.category.toLowerCase().contains('scrap') || post.category.toLowerCase().contains('e-waste'))) {
      NotificationService.instance.notifyFreePost(post);
    }
    await FirestoreSyncService.instance.pushPost(post);
  }

  // Post voting
  Future<void> toggleUpvotePost(String postId, String user) async {
    final idx = posts.value.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final p = posts.value[idx];
    final up = List<String>.from(p.upvotedBy);
    final down = List<String>.from(p.downvotedBy);
    if (up.contains(user)) {
      up.remove(user);
    } else {
      up.add(user);
      down.remove(user);
    }
    final updated = Post(
      id: p.id,
      category: p.category,
      title: p.title,
      description: p.description,
      isFree: p.isFree,
      price: p.price,
      createdAt: p.createdAt,
      sellerName: p.sellerName,
      buyerName: p.buyerName,
      status: p.status,
      meetupActive: p.meetupActive,
      meetupDurationSeconds: p.meetupDurationSeconds,
      meetupStartedAt: p.meetupStartedAt,
      comments: p.comments,
      upvotedBy: up,
      downvotedBy: down,
    );
    posts.value = posts.value.map((e) => e.id == postId ? updated : e).toList();
    await _save();
    await FirestoreSyncService.instance.pushPost(updated);
  }

  Future<void> toggleDownvotePost(String postId, String user) async {
    final idx = posts.value.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final p = posts.value[idx];
    final up = List<String>.from(p.upvotedBy);
    final down = List<String>.from(p.downvotedBy);
    if (down.contains(user)) {
      down.remove(user);
    } else {
      down.add(user);
      up.remove(user);
    }
    final updated = Post(
      id: p.id,
      category: p.category,
      title: p.title,
      description: p.description,
      isFree: p.isFree,
      price: p.price,
      createdAt: p.createdAt,
      sellerName: p.sellerName,
      buyerName: p.buyerName,
      status: p.status,
      meetupActive: p.meetupActive,
      meetupDurationSeconds: p.meetupDurationSeconds,
      meetupStartedAt: p.meetupStartedAt,
      comments: p.comments,
      upvotedBy: up,
      downvotedBy: down,
    );
    posts.value = posts.value.map((e) => e.id == postId ? updated : e).toList();
    await _save();
    await FirestoreSyncService.instance.pushPost(updated);
  }

  // Comment voting
  Future<void> toggleUpvoteComment(String postId, String commentId, String user) async {
    final idx = posts.value.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final p = posts.value[idx];
    final updatedComments = p.comments.map((c) {
      if (c.id != commentId) return c;
      final up = List<String>.from(c.upvotedBy);
      final down = List<String>.from(c.downvotedBy);
      if (up.contains(user)) {
        up.remove(user);
      } else {
        up.add(user);
        down.remove(user);
      }
      return Comment(id: c.id, author: c.author, text: c.text, createdAt: c.createdAt, likedBy: c.likedBy, upvotedBy: up, downvotedBy: down);
    }).toList();
    final updated = Post(
      id: p.id,
      category: p.category,
      title: p.title,
      description: p.description,
      isFree: p.isFree,
      price: p.price,
      createdAt: p.createdAt,
      sellerName: p.sellerName,
      buyerName: p.buyerName,
      status: p.status,
      meetupActive: p.meetupActive,
      meetupDurationSeconds: p.meetupDurationSeconds,
      meetupStartedAt: p.meetupStartedAt,
      comments: updatedComments,
      upvotedBy: p.upvotedBy,
      downvotedBy: p.downvotedBy,
    );
    posts.value = posts.value.map((e) => e.id == postId ? updated : e).toList();
    await _save();
    await FirestoreSyncService.instance.pushPost(updated);
  }

  Future<void> toggleDownvoteComment(String postId, String commentId, String user) async {
    final idx = posts.value.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final p = posts.value[idx];
    final updatedComments = p.comments.map((c) {
      if (c.id != commentId) return c;
      final up = List<String>.from(c.upvotedBy);
      final down = List<String>.from(c.downvotedBy);
      if (down.contains(user)) {
        down.remove(user);
      } else {
        down.add(user);
        up.remove(user);
      }
      return Comment(id: c.id, author: c.author, text: c.text, createdAt: c.createdAt, likedBy: c.likedBy, upvotedBy: up, downvotedBy: down);
    }).toList();
    final updated = Post(
      id: p.id,
      category: p.category,
      title: p.title,
      description: p.description,
      isFree: p.isFree,
      price: p.price,
      createdAt: p.createdAt,
      sellerName: p.sellerName,
      buyerName: p.buyerName,
      status: p.status,
      meetupActive: p.meetupActive,
      meetupDurationSeconds: p.meetupDurationSeconds,
      meetupStartedAt: p.meetupStartedAt,
      comments: updatedComments,
      upvotedBy: p.upvotedBy,
      downvotedBy: p.downvotedBy,
    );
    posts.value = posts.value.map((e) => e.id == postId ? updated : e).toList();
    await _save();
    await FirestoreSyncService.instance.pushPost(updated);
  }

  Future<void> addComment(String postId, String author, String text) async {
    final idx = posts.value.indexWhere((p) => p.id == postId);
    if (idx == -1) {
      return;
    }
    final p = posts.value[idx];
    final comment = Comment(id: DateTime.now().millisecondsSinceEpoch.toString(), author: author, text: text);
    final updated = Post(
      id: p.id,
      category: p.category,
      title: p.title,
      description: p.description,
      isFree: p.isFree,
      price: p.price,
      createdAt: p.createdAt,
      sellerName: p.sellerName,
      buyerName: p.buyerName,
      status: p.status,
      meetupActive: p.meetupActive,
      meetupDurationSeconds: p.meetupDurationSeconds,
      meetupStartedAt: p.meetupStartedAt,
      comments: [...p.comments, comment],
    );
    posts.value = posts.value.map((e) => e.id == postId ? updated : e).toList();
    await _save();
    await FirestoreSyncService.instance.pushPost(updated);
  }

  Future<void> toggleLikeComment(String postId, String commentId, String user) async {
    final idx = posts.value.indexWhere((p) => p.id == postId);
    if (idx == -1) {
      return;
    }
    final p = posts.value[idx];
    final updatedComments = p.comments.map((c) {
      if (c.id != commentId) return c;
      final liked = List<String>.from(c.likedBy);
      if (liked.contains(user)) {
        liked.remove(user);
      } else {
        liked.add(user);
      }
      return Comment(id: c.id, author: c.author, text: c.text, createdAt: c.createdAt, likedBy: liked);
    }).toList();
    final updated = Post(
      id: p.id,
      category: p.category,
      title: p.title,
      description: p.description,
      isFree: p.isFree,
      price: p.price,
      createdAt: p.createdAt,
      sellerName: p.sellerName,
      buyerName: p.buyerName,
      status: p.status,
      meetupActive: p.meetupActive,
      meetupDurationSeconds: p.meetupDurationSeconds,
      meetupStartedAt: p.meetupStartedAt,
      comments: updatedComments,
    );
    posts.value = posts.value.map((e) => e.id == postId ? updated : e).toList();
    await _save();
    await FirestoreSyncService.instance.pushPost(updated);
  }

  Future<void> removeComment(String postId, String commentId) async {
    final idx = posts.value.indexWhere((p) => p.id == postId);
    if (idx == -1) {
      return;
    }
    final p = posts.value[idx];
    final updatedComments = p.comments.where((c) => c.id != commentId).toList();
    final updated = Post(
      id: p.id,
      category: p.category,
      title: p.title,
      description: p.description,
      isFree: p.isFree,
      price: p.price,
      createdAt: p.createdAt,
      sellerName: p.sellerName,
      buyerName: p.buyerName,
      status: p.status,
      meetupActive: p.meetupActive,
      meetupDurationSeconds: p.meetupDurationSeconds,
      meetupStartedAt: p.meetupStartedAt,
      comments: updatedComments,
    );
    posts.value = posts.value.map((e) => e.id == postId ? updated : e).toList();
    await _save();
    await FirestoreSyncService.instance.pushPost(updated);
  }

  Future<void> reservePost(String postId, String buyerName) async {
    final idx = posts.value.indexWhere((p) => p.id == postId);
    if (idx == -1) {
      return;
    }
    final p = posts.value[idx];
    final updated = Post(
      id: p.id,
      category: p.category,
      title: p.title,
      description: p.description,
      isFree: p.isFree,
      price: p.price,
      createdAt: p.createdAt,
      sellerName: p.sellerName,
      buyerName: buyerName,
      status: 'reserved',
      meetupActive: false,
    );
    posts.value = posts.value.map((e) => e.id == postId ? updated : e).toList();
    await _save();
    await FirestoreSyncService.instance.pushPost(updated);
  }

  Future<void> startMeetup(String postId, int durationSeconds) async {
    final idx = posts.value.indexWhere((p) => p.id == postId);
    if (idx == -1) {
      return;
    }
    final p = posts.value[idx];
    final updated = Post(
      id: p.id,
      category: p.category,
      title: p.title,
      description: p.description,
      isFree: p.isFree,
      price: p.price,
      createdAt: p.createdAt,
      sellerName: p.sellerName,
      buyerName: p.buyerName,
      status: 'reserved',
      meetupActive: true,
      meetupDurationSeconds: durationSeconds,
      meetupStartedAt: DateTime.now(),
    );
    posts.value = posts.value.map((e) => e.id == postId ? updated : e).toList();
    await _save();
    await FirestoreSyncService.instance.pushPost(updated);
  }

  Future<void> markPickedUp(String postId, {bool sellerForgave = false}) async {
    final idx = posts.value.indexWhere((p) => p.id == postId);
    if (idx == -1) {
      return;
    }
    final p = posts.value[idx];
    final wasOnTime = !_isLatePickup(p) || sellerForgave;
    // Update ratings
    if (p.buyerName != null) {
      RatingService.instance.recordPickup(p.buyerName!, onTime: wasOnTime, category: p.category);
    }
    final updated = Post(
      id: p.id,
      category: p.category,
      title: p.title,
      description: p.description,
      isFree: p.isFree,
      price: p.price,
      createdAt: p.createdAt,
      sellerName: p.sellerName,
      buyerName: p.buyerName,
      status: 'picked_up',
      meetupActive: false,
      meetupDurationSeconds: null,
      meetupStartedAt: null,
    );
    posts.value = posts.value.map((e) => e.id == postId ? updated : e).toList();
    await _save();
    await FirestoreSyncService.instance.pushPost(updated);
  }

  bool _isLatePickup(Post p) {
    if (!p.meetupActive || p.meetupStartedAt == null || p.meetupDurationSeconds == null) return true;
    final deadline = p.meetupStartedAt!.add(Duration(seconds: p.meetupDurationSeconds!));
    return DateTime.now().isAfter(deadline);
  }

  Future<void> updatePost(Post post) async {
    // if updating image, remove old image file
    try {
      final existing = posts.value.firstWhere((p) => p.id == post.id, orElse: () => Post(id: '', category: '', title: '', description: '', isFree: true, sellerName: ''));
      if (existing.id.isNotEmpty && existing.imagePath != null && post.imagePath != null && existing.imagePath != post.imagePath) {
        final f = File(existing.imagePath!);
        if (await f.exists()) await f.delete();
      }
    } catch (e) {
      debugPrint('updatePost image delete error: $e');
    }
    posts.value = posts.value.map((p) => p.id == post.id ? post : p).toList();
    await _save();
    await FirestoreSyncService.instance.pushPost(post);
  }

  Future<void> removePost(String id) async {
    // delete any associated image file
    try {
      final toRemove = posts.value.firstWhere((p) => p.id == id, orElse: () => Post(id: '', category: '', title: '', description: '', isFree: true, sellerName: ''));
      if (toRemove.id.isNotEmpty && toRemove.imagePath != null) {
        final f = File(toRemove.imagePath!);
        if (await f.exists()) await f.delete();
      }
    } catch (e) {
      debugPrint('removePost file delete error: $e');
    }
    posts.value = posts.value.where((p) => p.id != id).toList();
    await _save();
    await FirestoreSyncService.instance.removePost(id);
  }

  void _mergeRemotePosts(List<Post> remote) {
    final localMap = {for (var p in posts.value) p.id: p};
    for (final r in remote) {
      final existing = localMap[r.id];
      if (existing == null) {
        localMap[r.id] = r;
      } else {
        // prefer the version with later createdAt
        if (r.createdAt.isAfter(existing.createdAt)) {
          localMap[r.id] = r;
        }
      }
    }
    final merged = localMap.values.toList();
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    posts.value = merged;
  }
}
