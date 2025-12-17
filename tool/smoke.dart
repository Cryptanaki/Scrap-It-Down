import 'dart:developer' as developer;
import 'package:scrap_it_down/models/post.dart';
import 'package:scrap_it_down/models/comment.dart';

void main() {
  final now = DateTime.now();

  var p1 = Post(
    id: 'p1',
    category: 'Social',
    title: 'First post',
    description: 'Hello world',
    isFree: true,
    sellerName: 'Alice',
    createdAt: now.subtract(const Duration(hours: 2)),
  );
  p1.upvotedBy.addAll(['A', 'B', 'C']);
  p1.downvotedBy.addAll(['X']);

  var p2 = Post(
    id: 'p2',
    category: 'Social',
    title: 'Second post',
    description: 'Old unpopular',
    isFree: true,
    sellerName: 'Bob',
    createdAt: now.subtract(const Duration(hours: 26)),
  );
  p2.upvotedBy.addAll(['A']);
  p2.downvotedBy.addAll(['B', 'C']);

  var p3 = Post(
    id: 'p3',
    category: 'Social',
    title: 'Third post',
    description: 'Hot new',
    isFree: true,
    sellerName: 'Carol',
    createdAt: now.subtract(const Duration(hours: 1)),
  );
  p3.upvotedBy.addAll(['A', 'B', 'C', 'D']);

  var p4 = Post(
    id: 'p4',
    category: 'Social',
    title: 'Fourth post',
    description: 'Medium',
    isFree: true,
    sellerName: 'Dave',
    createdAt: now.subtract(const Duration(hours: 30)),
  );
  p4.upvotedBy.addAll(['A', 'B']);

  final all = [p1, p2, p3, p4];

  final sortedByUp = List<Post>.from(all)
    ..sort((a, b) => b.upvotedBy.length.compareTo(a.upvotedBy.length));
  final top3 = sortedByUp.take(3).toList();
  final top3Ids = top3.map((e) => e.id).toSet();
  final newPosts = all
      .where((p) => !top3Ids.contains(p.id) && now.difference(p.createdAt) < const Duration(hours: 24))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  final others = all
      .where((p) => !top3Ids.contains(p.id) && now.difference(p.createdAt) >= const Duration(hours: 24))
      .toList()
    ..sort((a, b) {
      final netA = a.upvotedBy.length - a.downvotedBy.length;
      final netB = b.upvotedBy.length - b.downvotedBy.length;
      return netB.compareTo(netA);
    });
  final posts = [...top3, ...newPosts, ...others];

  developer.log('Top 3 by upvotes: ${top3.map((p) => p.id).join(', ')}');
  developer.log('New posts: ${newPosts.map((p) => p.id).join(', ')}');
  developer.log('Others: ${others.map((p) => p.id).join(', ')}');
  developer.log('\nFinal order:');
  for (var p in posts) {
    final net = p.upvotedBy.length - p.downvotedBy.length;
    final isNew = now.difference(p.createdAt) < const Duration(hours: 24);
    developer.log('- ${p.id}: up=${p.upvotedBy.length} down=${p.downvotedBy.length} net=$net created=${p.createdAt} ${isNew ? '[NEW]' : ''}');
  }

  // Comments
  var c1 = Comment(id: 'c1', author: 'U', text: 'Nice post', createdAt: now, upvotedBy: ['A', 'B'], downvotedBy: ['X']);
  developer.log('\nComment c1 initial net: ${c1.upvotedBy.length - c1.downvotedBy.length}');
  toggleUpvoteComment(c1, 'A');
  developer.log('After toggle upvote by A net: ${c1.upvotedBy.length - c1.downvotedBy.length}');
  toggleDownvoteComment(c1, 'Y');
  developer.log('After toggle downvote by Y net: ${c1.upvotedBy.length - c1.downvotedBy.length}');
}

void toggleUpvoteComment(Comment c, String user) {
  if (c.upvotedBy.contains(user)) {
    c.upvotedBy.remove(user);
  } else {
    c.upvotedBy.add(user);
    c.downvotedBy.remove(user);
  }
}

void toggleDownvoteComment(Comment c, String user) {
  if (c.downvotedBy.contains(user)) {
    c.downvotedBy.remove(user);
  } else {
    c.downvotedBy.add(user);
    c.upvotedBy.remove(user);
  }
}
