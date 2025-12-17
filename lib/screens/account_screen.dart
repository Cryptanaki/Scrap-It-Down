import 'package:flutter/material.dart';
import 'package:scrap_it_down/services/services.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(labelText: 'Display name'),
            onSubmitted: (v) => AuthService.instance.setDisplayName(v.trim()),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final signedIn = AuthService.instance.signedIn.value;
              if (signedIn) {
                await AuthService.instance.signOut();
              } else {
                await AuthService.instance.signInAnonymously();
              }
            },
            child: const Text('Toggle Sign-in'),
          ),
        ],
      ),
    );
  }
}
