import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Message {
  final String id;
  final String from;
  final String to;
  final String content;
  final DateTime createdAt;
  bool read;

  Message({
    required this.id,
    required this.from,
    required this.to,
    required this.content,
    DateTime? createdAt,
    this.read = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'from': from,
        'to': to,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'read': read,
      };

  factory Message.fromMap(Map<String, dynamic> m) => Message(
        id: m['id'] as String,
        from: m['from'] as String,
        to: m['to'] as String,
        content: m['content'] as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
        read: m['read'] as bool? ?? false,
      );
}

class MessagesService {
  MessagesService._();
  static final MessagesService instance = MessagesService._();

  final ValueNotifier<List<Message>> messages = ValueNotifier<List<Message>>([]);
  static const _prefsKey = 'messages';

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;
      final list = (json.decode(raw) as List<dynamic>).map((e) => Message.fromMap(Map<String, dynamic>.from(e as Map))).toList();
      messages.value = list;
    } catch (e) {
      debugPrint('MessagesService.init() failed: $e');
    }
  }

  void addMessage(Message m) {
    final cur = List<Message>.from(messages.value);
    cur.insert(0, m);
    messages.value = cur;
    _save();
  }

  void markRead(String id) {
    final cur = messages.value.map((m) {
      if (m.id == id) return Message(id: m.id, from: m.from, to: m.to, content: m.content, createdAt: m.createdAt, read: true);
      return m;
    }).toList();
    messages.value = cur;
    _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = json.encode(messages.value.map((m) => m.toMap()).toList());
      await prefs.setString(_prefsKey, raw);
    } catch (e) {
      debugPrint('MessagesService._save() failed: $e');
    }
  }

  List<Message> forRecipient(String recipient) {
    return messages.value.where((m) => m.to == recipient).toList();
  }
}
