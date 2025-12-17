import 'package:flutter/material.dart';
import 'package:scrap_it_down/services/services.dart';
import 'messages_screen.dart';

// ignore_for_file: use_build_context_synchronously

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _cityCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: AuthService.instance.displayName.value);
    _cityCtrl = TextEditingController(text: AuthService.instance.city.value);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ValueListenableBuilder<String>(
                valueListenable: AuthService.instance.displayName,
                builder: (context, name, _) {
                  return Text(
                    name.isNotEmpty ? 'User: $name' : 'User: (set a display name)',
                    style: Theme.of(context).textTheme.titleLarge,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.message),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MessagesScreen())),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Display name'),
            onSubmitted: (v) async {
              await AuthService.instance.setDisplayName(v);
              _nameCtrl.text = AuthService.instance.displayName.value;
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cityCtrl,
            decoration: const InputDecoration(labelText: 'City'),
            onSubmitted: (v) => AuthService.instance.setCity(v.trim()),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              // toggle sign-in for demo purposes
              final signedIn = AuthService.instance.signedIn.value;
              if (signedIn) {
                await AuthService.instance.signOut();
              } else {
                await AuthService.instance.signInAnonymously();
              }
              if (!mounted) return;
              setState(() {});
            },
            child: const Text('Toggle Sign-in'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              await AuthService.instance.setDisplayName(_nameCtrl.text);
              await AuthService.instance.setCity(_cityCtrl.text.trim());
              // reflect sanitized name back into the text field
              _nameCtrl.text = AuthService.instance.displayName.value;
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
            },
            child: const Text('Save Profile'),
          ),
        ],
      ),
    );
  }
}
