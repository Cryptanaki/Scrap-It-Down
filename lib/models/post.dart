import 'dart:convert';
import 'comment.dart';

class Post {
  final String id;
  final String category;
  final String title;
  final String description;
  final bool isFree;
  final double? price;
  final String? imagePath;
  final DateTime createdAt;
  final String sellerName;
  String? buyerName;
  String status; // 'available','reserved','picked_up'

  // Meetup timer fields
  bool meetupActive;
  int? meetupDurationSeconds;
  DateTime? meetupStartedAt;
  List<Comment> comments;

  // Voting
  List<String> upvotedBy;
  List<String> downvotedBy;

  Post({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.isFree,
    this.price,
    this.imagePath,
    DateTime? createdAt,
    required this.sellerName,
    this.buyerName,
    this.status = 'available',
    this.meetupActive = false,
    this.meetupDurationSeconds,
    this.meetupStartedAt,
    List<Comment>? comments,
    List<String>? upvotedBy,
    List<String>? downvotedBy,
  }) : createdAt = createdAt ?? DateTime.now(),
      comments = comments ?? [],
      upvotedBy = upvotedBy ?? [],
      downvotedBy = downvotedBy ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'isFree': isFree,
      'price': price,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'sellerName': sellerName,
      'buyerName': buyerName,
      'status': status,
      'meetupActive': meetupActive,
      'meetupDurationSeconds': meetupDurationSeconds,
      'meetupStartedAt': meetupStartedAt?.toIso8601String(),
      'comments': comments.map((c) => c.toMap()).toList(),
      'upvotedBy': upvotedBy,
      'downvotedBy': downvotedBy,
    };
  }

  factory Post.fromMap(Map<String, dynamic> m) {
    return Post(
      id: m['id'] as String,
      category: m['category'] as String,
      title: m['title'] as String,
      description: m['description'] as String,
      isFree: m['isFree'] as bool,
      price: m['price'] == null ? null : (m['price'] as num).toDouble(),
      imagePath: m['imagePath'] as String?,
      createdAt: DateTime.parse(m['createdAt'] as String),
      sellerName: m['sellerName'] as String? ?? 'Anonymous',
      buyerName: m['buyerName'] as String?,
      status: m['status'] as String? ?? 'available',
      meetupActive: m['meetupActive'] as bool? ?? false,
      meetupDurationSeconds: m['meetupDurationSeconds'] as int?,
      meetupStartedAt: m['meetupStartedAt'] == null ? null : DateTime.parse(m['meetupStartedAt'] as String),
      comments: (m['comments'] as List<dynamic>?)?.map((e) => Comment.fromMap(Map<String, dynamic>.from(e as Map))).toList() ?? [],
      upvotedBy: (m['upvotedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      downvotedBy: (m['downvotedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  String toJson() => json.encode(toMap());
  factory Post.fromJson(String source) => Post.fromMap(json.decode(source));
}
