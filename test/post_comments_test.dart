import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrap_it_down/services/post_service.dart';
import 'package:scrap_it_down/models/post.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // reset in-memory posts
    PostService.instance.posts.value = [];
    await PostService.instance.init();
  });

  test('add -> like -> unlike -> remove comment flow', () async {
    final post = Post(
      id: 'p1',
      category: 'General',
      title: 'T',
      description: 'D',
      isFree: true,
      sellerName: 'seller',
    );

    await PostService.instance.addPost(post);

    var p = PostService.instance.posts.value.firstWhere((p) => p.id == 'p1');
    expect(p.comments.length, 0);

    // add a comment
    await PostService.instance.addComment('p1', 'alice', 'hello');
    p = PostService.instance.posts.value.firstWhere((p) => p.id == 'p1');
    expect(p.comments.length, 1);
    final c = p.comments.first;
    expect(c.author, 'alice');
    expect(c.text, 'hello');

    // like the comment
    await PostService.instance.toggleLikeComment('p1', c.id, 'bob');
    p = PostService.instance.posts.value.firstWhere((p) => p.id == 'p1');
    final liked = p.comments.firstWhere((cm) => cm.id == c.id);
    expect(liked.likedBy, contains('bob'));

    // unlike the comment
    await PostService.instance.toggleLikeComment('p1', c.id, 'bob');
    p = PostService.instance.posts.value.firstWhere((p) => p.id == 'p1');
    final unliked = p.comments.firstWhere((cm) => cm.id == c.id);
    expect(unliked.likedBy, isNot(contains('bob')));

    // add another comment and remove it
    await PostService.instance.addComment('p1', 'seller', 'my reply');
    p = PostService.instance.posts.value.firstWhere((p) => p.id == 'p1');
    final toRemove = p.comments.firstWhere((cm) => cm.author == 'seller');
    await PostService.instance.removeComment('p1', toRemove.id);
    p = PostService.instance.posts.value.firstWhere((p) => p.id == 'p1');
    expect(p.comments.any((cm) => cm.id == toRemove.id), isFalse);
  });

  test('liking twice toggles without duplicates', () async {
    final post = Post(
      id: 'p2',
      category: 'General',
      title: 'T2',
      description: 'D2',
      isFree: false,
      sellerName: 'seller2',
    );
    await PostService.instance.addPost(post);
    await PostService.instance.addComment('p2', 'alice', 'hi');
    var p = PostService.instance.posts.value.firstWhere((p) => p.id == 'p2');
    final c = p.comments.first;

    // bob likes
    await PostService.instance.toggleLikeComment('p2', c.id, 'bob');
    p = PostService.instance.posts.value.firstWhere((p) => p.id == 'p2');
    expect(p.comments.first.likedBy, contains('bob'));

    // bob likes again -> should unlike (toggle) and not duplicate
    await PostService.instance.toggleLikeComment('p2', c.id, 'bob');
    p = PostService.instance.posts.value.firstWhere((p) => p.id == 'p2');
    expect(p.comments.first.likedBy.where((u) => u == 'bob').length, 0);
    expect(p.comments.first.likedBy, isNot(contains('bob')));
  });

  test('removing non-existent comment is a no-op', () async {
    final post = Post(
      id: 'p3',
      category: 'General',
      title: 'T3',
      description: 'D3',
      isFree: false,
      sellerName: 'seller3',
    );
    await PostService.instance.addPost(post);
    await PostService.instance.addComment('p3', 'alice', 'hello');
    var p = PostService.instance.posts.value.firstWhere((p) => p.id == 'p3');
    final before = p.comments.length;

    // attempt to remove a comment id that doesn't exist
    await PostService.instance.removeComment('p3', 'no-such-id');
    p = PostService.instance.posts.value.firstWhere((p) => p.id == 'p3');
    expect(p.comments.length, before);
  });
}
