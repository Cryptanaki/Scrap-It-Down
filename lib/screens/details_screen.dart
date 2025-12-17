import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scrap_it_down/services/services.dart';
import 'package:scrap_it_down/models/post.dart';
import 'post_social_screen.dart';

class DetailsScreen extends StatefulWidget {
  final String? title;
  const DetailsScreen({super.key, this.title});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late final TextEditingController _socialInputCtrl;
  late final ScrollController _listController;
  final Set<String> _replying = <String>{};
  final Map<String, TextEditingController> _replyCtrls = {};
  @override
  void initState() {
    super.initState();
    PostService.instance.init();
    _socialInputCtrl = TextEditingController();
    _listController = ScrollController();
  }

  @override
  void dispose() {
    _socialInputCtrl.dispose();
    _listController.dispose();
    for (final c in _replyCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.title ?? 'Social';
    // Display title for the Social tab should read "Scrap Recovery Forms"
    final displayTitle = widget.title ?? 'Scrap Recovery Forms';

    return Scaffold(
      appBar: AppBar(title: Text(displayTitle)),
      body: ValueListenableBuilder<List<Post>>(
        valueListenable: PostService.instance.posts,
        builder: (context, postsList, _) {
            final all = postsList.where((p) => p.category == category).toList();
            final userCity = AuthService.instance.city.value;
            final cityPosts = (userCity.isNotEmpty)
              ? all.where((p) => p.city == userCity).toList()
              : <Post>[];
            cityPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            final remainingAll = all.where((p) => !cityPosts.contains(p)).toList();
          if (all.isEmpty) {
            return Center(child: Text('No posts in $category yet.'));
          }

          final now = DateTime.now();
          final sortedByUp = List<Post>.from(remainingAll)
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
          final posts = [...cityPosts, ...top3, ...newPosts, ...others];

          Widget buildPostItem(Post p) {
            // build top comments preview sorted by net score
            final comments = List.of(p.comments)
              ..sort((a, b) {
                final netA = a.upvotedBy.length - a.downvotedBy.length;
                final netB = b.upvotedBy.length - b.downvotedBy.length;
                if (netB != netA) return netB.compareTo(netA);
                return b.createdAt.compareTo(a.createdAt);
              });
            final preview = comments.take(3).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(26),
                    child: (p.category.toLowerCase().contains('scrap') || p.category.toLowerCase().contains('metal'))
                        ? const Icon(Icons.recycling, color: Colors.white)
                        : const Icon(Icons.sell, color: Colors.white),
                  ),
                  title: Row(children: [
                    Expanded(child: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                    if (now.difference(p.createdAt) < const Duration(hours: 24))
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Chip(label: Text('NEW'), backgroundColor: Colors.black, labelStyle: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                  ]),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (p.imagePath != null) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Image.file(File(p.imagePath!), height: 160, width: double.infinity, fit: BoxFit.cover),
                        ),
                      ],
                      Text(p.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Text(_formatRelative(p.createdAt), style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PostSocialScreen(postId: p.id))),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      for (final c in preview)
                        ListTile(
                          dense: true,
                          title: Text(c.author, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          subtitle: Text(c.text, style: const TextStyle(fontSize: 13)),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ValueListenableBuilder<bool>(
                                valueListenable: AuthService.instance.signedIn,
                                builder: (context, signedIn, _) {
                                  final me = AuthService.instance.displayName.value;
                                  final upvoted = c.upvotedBy.contains(me);
                                  final downvoted = c.downvotedBy.contains(me);
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.arrow_upward, color: upvoted ? Colors.green : null),
                                        iconSize: 18,
                                        onPressed: signedIn
                                            ? () async {
                                                final user = me.isNotEmpty ? me : 'Anonymous';
                                                await PostService.instance.toggleUpvoteComment(p.id, c.id, user);
                                                setState(() {});
                                              }
                                            : null,
                                      ),
                                      Text('${c.upvotedBy.length - c.downvotedBy.length}', style: const TextStyle(fontSize: 12)),
                                      IconButton(
                                        icon: Icon(Icons.arrow_downward, color: downvoted ? Colors.red : null),
                                        iconSize: 18,
                                        onPressed: signedIn
                                            ? () async {
                                                final user = me.isNotEmpty ? me : 'Anonymous';
                                                await PostService.instance.toggleDownvoteComment(p.id, c.id, user);
                                                setState(() {});
                                              }
                                            : null,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                      // Reply toggle
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            if (!AuthService.instance.signedIn.value) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in to reply')));
                              return;
                            }
                            setState(() => _replying.add(p.id));
                          },
                          icon: const Icon(Icons.reply, size: 14),
                          label: const Text('Reply', style: TextStyle(fontSize: 12)),
                        ),
                      ),

                      if (_replying.contains(p.id))
                        Row(children: [
                          Expanded(child: TextField(controller: _replyCtrls.putIfAbsent(p.id, () => TextEditingController()), decoration: const InputDecoration(hintText: 'Write a reply'))),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () async {
                              final text = _replyCtrls[p.id]?.text.trim() ?? '';
                              if (text.isEmpty) return;
                              final author = AuthService.instance.displayName.value.isNotEmpty ? AuthService.instance.displayName.value : 'Anonymous';
                              await PostService.instance.addComment(p.id, author, text);
                              _replyCtrls[p.id]?.clear();
                              setState(() {
                                _replying.remove(p.id);
                              });
                            },
                          )
                        ])
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            );
          }

          final listView = ListView.separated(
            controller: _listController,
            itemCount: posts.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = posts[index];
              return buildPostItem(p);
            },
          );

          if (category.toLowerCase().contains('social')) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: [
                    Expanded(child: TextField(controller: _socialInputCtrl, decoration: const InputDecoration(hintText: 'Whats on your mind?'))),
                    ValueListenableBuilder<bool>(
                      valueListenable: AuthService.instance.signedIn,
                      builder: (context, signedIn, _) {
                        return IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: signedIn
                              ? () async {
                                  final text = _socialInputCtrl.text.trim();
                                  if (text.isEmpty) return;
                                  final author = AuthService.instance.displayName.value.isNotEmpty ? AuthService.instance.displayName.value : 'Anonymous';
                                  final post = Post(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    category: category,
                                    title: text.length > 40 ? '${text.substring(0, 40)}...' : text,
                                    description: text,
                                    isFree: true,
                                    sellerName: author,
                                  );
                                  await PostService.instance.addPost(post);
                                  _socialInputCtrl.clear();
                                  setState(() {});
                                  try {
                                    if (_listController.hasClients) {
                                      await _listController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                    }
                                  } catch (_) {}
                                }
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in to post in Scrap Recovery Forms')));
                                },
                        );
                      },
                    )
                  ]),
                ),
                const Divider(height: 1),
                Expanded(child: listView),
              ],
            );
          }

          return listView;
        },
      ),
    );
  }

  String _formatRelative(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inSeconds < 60) return '${d.inSeconds}s';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }
}
