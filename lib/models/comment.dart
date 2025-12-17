import 'dart:convert';

class Comment {
  final String id;
  final String author;
  final String text;
  final DateTime createdAt;
  final List<String> likedBy;
  final List<String> upvotedBy;
  final List<String> downvotedBy;

  Comment({
    required this.id,
    required this.author,
    required this.text,
    DateTime? createdAt,
    List<String>? likedBy,
    List<String>? upvotedBy,
    List<String>? downvotedBy,
  })  : createdAt = createdAt ?? DateTime.now(),
      likedBy = likedBy ?? [],
      upvotedBy = upvotedBy ?? [],
      downvotedBy = downvotedBy ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author': author,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'likedBy': likedBy,
      'upvotedBy': upvotedBy,
      'downvotedBy': downvotedBy,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> m) {
    return Comment(
      id: m['id'] as String,
      author: m['author'] as String? ?? 'Anonymous',
      text: m['text'] as String? ?? '',
      createdAt: m['createdAt'] == null ? DateTime.now() : DateTime.parse(m['createdAt'] as String),
      likedBy: (m['likedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      upvotedBy: (m['upvotedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      downvotedBy: (m['downvotedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  String toJson() => json.encode(toMap());
  factory Comment.fromJson(String s) => Comment.fromMap(json.decode(s));
}
