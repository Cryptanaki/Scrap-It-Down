import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scrap_it_down/services/services.dart';
import 'package:scrap_it_down/models/comment.dart';
import 'package:scrap_it_down/models/post.dart';

class PostSocialScreen extends StatefulWidget {
  final String postId;
  const PostSocialScreen({super.key, required this.postId});

  @override
  State<PostSocialScreen> createState() => _PostSocialScreenState();
}

class _PostSocialScreenState extends State<PostSocialScreen> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    PostService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discussion')),
      body: ValueListenableBuilder<List<Post>>(
        valueListenable: PostService.instance.posts,
        builder: (context, postsList, _) {
          final matches = postsList.where((p) => p.id == widget.postId).toList();
          if (matches.isEmpty) return const Center(child: Text('Post not found'));
          final post = matches.first;
          final comments = List<Comment>.from(post.comments);
          comments.sort((a, b) => b.likedBy.length.compareTo(a.likedBy.length));
          return Column(
            children: [
              if (post.imagePath != null) Image.file(File(post.imagePath!), height: 200, width: double.infinity, fit: BoxFit.cover),
              ListTile(
                title: Text(post.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(post.description),
              ),
              const Divider(),
              Expanded(
                child: ListView.separated(
                  itemCount: comments.length,
                  separatorBuilder: (ctx, idx) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final c = comments[index];
                    final me = AuthService.instance.displayName.value;
                    final upvoted = c.upvotedBy.contains(me);
                    final downvoted = c.downvotedBy.contains(me);
                    return ListTile(
                      title: Text(c.author),
                      subtitle: Text(c.text),
                      trailing: Column(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                          icon: Icon(Icons.arrow_upward, color: upvoted ? Colors.green : null),
                          onPressed: () async {
                            final user = me.isNotEmpty ? me : 'Anonymous';
                            await PostService.instance.toggleUpvoteComment(post.id, c.id, user);
                            setState(() {});
                          },
                          iconSize: 18,
                        ),
                        Text('${c.upvotedBy.length - c.downvotedBy.length}'),
                        IconButton(
                          icon: Icon(Icons.arrow_downward, color: downvoted ? Colors.red : null),
                          onPressed: () async {
                            final user = me.isNotEmpty ? me : 'Anonymous';
                            await PostService.instance.toggleDownvoteComment(post.id, c.id, user);
                            setState(() {});
                          },
                          iconSize: 18,
                        ),
                      ]),
                      onLongPress: () async {
                        final me = AuthService.instance.displayName.value;
                        final canDelete = me.isNotEmpty && (me == c.author || me == post.sellerName);
                        if (!canDelete) return;
                        final confirm = await showDialog<bool>(context: context, builder: (ctx) {
                          return AlertDialog(
                            title: const Text('Delete comment?'),
                            content: const Text('This will remove the comment.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(ctx).pop<bool>(false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.of(ctx).pop<bool>(true), child: const Text('Delete')),
                            ],
                          );
                        });
                        if (confirm == true) {
                          await PostService.instance.removeComment(post.id, c.id);
                          setState(() {});
                        }
                      },
                    );
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: [
                    Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: 'Write a comment'))),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        final text = _ctrl.text.trim();
                        if (text.isEmpty) return;
                        final author = AuthService.instance.displayName.value.isNotEmpty ? AuthService.instance.displayName.value : 'Anonymous';
                        await PostService.instance.addComment(post.id, author, text);
                        _ctrl.clear();
                        setState(() {});
                      },
                    )
                  ]),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
