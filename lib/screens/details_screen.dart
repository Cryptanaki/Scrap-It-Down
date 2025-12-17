import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scrap_it_down/services/services.dart';
import 'package:scrap_it_down/models/post.dart';
import 'create_post_screen.dart';
import 'post_social_screen.dart';

class DetailsScreen extends StatefulWidget {
  final String? title;
  const DetailsScreen({super.key, this.title});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late final TextEditingController _socialInputCtrl;
  @override
  void initState() {
    super.initState();
    PostService.instance.init();
    _socialInputCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _socialInputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.title ?? 'Social';
    // Display title for the Social tab should read "Gold Recovery Forms"
    final displayTitle = widget.title ?? 'Gold Recovery Forms';
    final isScrap = category.toLowerCase().contains('scrap');

    return Scaffold(
      appBar: AppBar(title: Text(displayTitle)),
      body: ValueListenableBuilder<List<Post>>(
        valueListenable: PostService.instance.posts,
        builder: (context, postsList, _) {
          final all = postsList.where((p) => p.category == category).toList();
          if (all.isEmpty) {
            return Center(child: Text('No posts in $category yet.'));
          }

          final now = DateTime.now();
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

          final listView = ListView.separated(
            itemCount: posts.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = posts[index];
              return ListTile(
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
                      child: Chip(label: Text('NEW'), backgroundColor: Colors.redAccent, labelStyle: TextStyle(color: Colors.white, fontSize: 12)),
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
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => PostSocialScreen(postId: p.id)));
                },
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Voting controls
                    IconButton(
                      icon: Icon(Icons.arrow_upward, color: p.upvotedBy.contains(AuthService.instance.displayName.value) ? Colors.green : null),
                      onPressed: () async {
                        final user = AuthService.instance.displayName.value.isNotEmpty ? AuthService.instance.displayName.value : 'Anonymous';
                        await PostService.instance.toggleUpvotePost(p.id, user);
                        setState(() {});
                      },
                      iconSize: 20,
                    ),
                    Text('${p.upvotedBy.length - p.downvotedBy.length}'),
                    IconButton(
                      icon: Icon(Icons.arrow_downward, color: p.downvotedBy.contains(AuthService.instance.displayName.value) ? Colors.red : null),
                      onPressed: () async {
                        final user = AuthService.instance.displayName.value.isNotEmpty ? AuthService.instance.displayName.value : 'Anonymous';
                        await PostService.instance.toggleDownvotePost(p.id, user);
                        setState(() {});
                      },
                      iconSize: 20,
                    ),
                    const SizedBox(height: 6),
                    p.isFree
                      ? Chip(label: const Text('Free'), backgroundColor: Colors.black, labelStyle: const TextStyle(color: Colors.white))
                      : Chip(label: Text('\$${p.price?.toStringAsFixed(2) ?? '-'}'), backgroundColor: Colors.black, labelStyle: const TextStyle(color: Colors.white)),
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.comment, size: 14),
                        const SizedBox(width: 4),
                        Text('${p.comments.length}'),
                      ]),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (v) async {
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        if (v == 'edit') {
                          await navigator.push(MaterialPageRoute(
                            builder: (_) => CreatePostScreen(category: category, priceAllowed: !isScrap, editPostId: p.id),
                          ));
                          if (!mounted) return;
                          setState(() {});
                        } else if (v == 'delete') {
                          await PostService.instance.removePost(p.id);
                          if (!mounted) return;
                          messenger.showSnackBar(const SnackBar(content: Text('Post deleted')));
                          setState(() {});
                        } else if (v == 'reserve') {
                          final buyer = AuthService.instance.displayName.value.isNotEmpty ? AuthService.instance.displayName.value : 'Anonymous';
                          await PostService.instance.reservePost(p.id, buyer);
                          if (!mounted) return;
                          messenger.showSnackBar(const SnackBar(content: Text('Post reserved')));
                          setState(() {});
                        } else if (v == 'start_meetup') {
                          // Ask for duration
                          final dur = await showDialog<int>(context: context, builder: (ctx) {
                            final ctrl = TextEditingController(text: '900');
                            return AlertDialog(
                              title: const Text('Meetup duration (seconds)'),
                              content: TextField(controller: ctrl, keyboardType: TextInputType.number),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(ctx).pop<int?>(null), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.of(ctx).pop<int>(int.tryParse(ctrl.text) ?? 900), child: const Text('Start')),
                              ],
                              
                            );
                          });
                          if (dur != null) {
                            await PostService.instance.startMeetup(p.id, dur);
                            if (!mounted) return;
                            messenger.showSnackBar(const SnackBar(content: Text('Meetup started')));
                            setState(() {});
                          }
                        } else if (v == 'mark_picked') {
                          // Offer seller forgiveness option
                          final forgive = await showDialog<bool>(context: context, builder: (ctx) {
                            return AlertDialog(
                              title: const Text('Seller forgave late pickup?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(ctx).pop<bool>(false), child: const Text('No')),
                                TextButton(onPressed: () => Navigator.of(ctx).pop<bool>(true), child: const Text('Yes')),
                              ],
                            );
                          });
                          await PostService.instance.markPickedUp(p.id, sellerForgave: forgive ?? false);
                          if (!mounted) return;
                          messenger.showSnackBar(const SnackBar(content: Text('Marked picked up')));
                          setState(() {});
                        }
                      },
                      itemBuilder: (_) {
                        final me = AuthService.instance.displayName.value;
                        final isSeller = me.isNotEmpty && me == p.sellerName;
                        final items = <PopupMenuEntry<String>>[];
                        items.add(const PopupMenuItem(value: 'edit', child: Text('Edit')));
                        items.add(const PopupMenuItem(value: 'delete', child: Text('Delete')));
                        if (p.status == 'available') items.add(const PopupMenuItem(value: 'reserve', child: Text('Reserve')));
                        if (isSeller && p.status == 'reserved') items.add(const PopupMenuItem(value: 'start_meetup', child: Text('Start Meetup')));
                        if (isSeller && p.status == 'reserved') items.add(const PopupMenuItem(value: 'mark_picked', child: Text('Mark Picked Up')));
                        return items;
                      },
                    ),
                  ],
                ),
              );
            },
          );

          if (category.toLowerCase().contains('social')) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: [
                    Expanded(child: TextField(controller: _socialInputCtrl, decoration: const InputDecoration(hintText: 'Whats on your mind?'))),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
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
      floatingActionButton: category.toLowerCase().contains('social')
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final priceAllowed = !isScrap;
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CreatePostScreen(category: category, priceAllowed: priceAllowed),
                ));
                setState(() {});
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  String _formatRelative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
