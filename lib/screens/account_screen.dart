import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
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
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _cityCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: AuthService.instance.displayName.value);
    _passwordCtrl = TextEditingController();
    _cityCtrl = TextEditingController(text: AuthService.instance.city.value);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passwordCtrl.dispose();
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
                    name.isNotEmpty ? 'User: $name' : 'User: (not signed in)',
                    style: Theme.of(context).textTheme.titleLarge,
                  );
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: AuthService.instance.signedIn,
                builder: (context, signedIn, _) {
                  if (!signedIn) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(Icons.message),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MessagesScreen())),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<bool>(
            valueListenable: AuthService.instance.signedIn,
            builder: (context, signedIn, _) {
              if (!signedIn) {
                return Column(
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Display name'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordCtrl,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final name = _nameCtrl.text;
                            final pass = _passwordCtrl.text;
                            final ok = await AuthService.instance.signUp(name, pass);
                            if (ok) {
                              // reflect sanitized name
                              _nameCtrl.text = AuthService.instance.displayName.value;
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created and signed in')));
                              setState(() {});
                            }
                          },
                          child: const Text('Sign Up'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final name = _nameCtrl.text;
                            final pass = _passwordCtrl.text;
                            final ok = await AuthService.instance.signIn(name, pass);
                            if (ok) {
                              _nameCtrl.text = AuthService.instance.displayName.value;
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed in')));
                              setState(() {});
                            } else {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign-in failed')));
                            }
                          },
                          child: const Text('Sign In'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }

              // Signed in UI: show profile picture and editable display name (sanitized on save)
              return Column(
                children: [
                  ValueListenableBuilder<String?>(
                    valueListenable: AuthService.instance.profilePicture,
                    builder: (context, pic, _) {
                      return CircleAvatar(
                        radius: 36,
                        backgroundImage: pic != null ? FileImage(File(pic)) : null,
                        child: pic == null ? const Icon(Icons.person, size: 36) : null,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final result = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800);
                      if (result != null) {
                        await AuthService.instance.setProfilePicture(result.path);
                        if (!mounted) return;
                        setState(() {});
                      }
                    },
                    child: const Text('Upload Profile Picture'),
                  ),
                  const SizedBox(height: 12),
                ],
              );
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
