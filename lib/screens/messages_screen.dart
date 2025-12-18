import 'package:flutter/material.dart';
import 'package:scrap_it_down/services/services.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final me = AuthService.instance.displayName.value.isNotEmpty ? AuthService.instance.displayName.value : 'Anonymous';
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ValueListenableBuilder<List<Message>>(
        valueListenable: MessagesService.instance.messages,
        builder: (context, msgs, _) {
          final myMsgs = msgs.where((m) => m.to == me).toList();
          if (myMsgs.isEmpty) return const Center(child: Text('No messages'));
          return ListView.separated(
            itemCount: myMsgs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final m = myMsgs[i];
              return ListTile(
                title: Text(m.from),
                subtitle: Text(m.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Text(_formatRelative(m.createdAt)),
                tileColor: m.read ? null : Colors.black26,
                onTap: () {
                  MessagesService.instance.markRead(m.id);
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('From ${m.from}'),
                      content: Text(m.content),
                      actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatRelative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
