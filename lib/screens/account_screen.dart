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

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final TextEditingController _signupNameCtrl;
  late final TextEditingController _signupPassCtrl;

  @override
  void initState() {
    super.initState();
    _signupNameCtrl = TextEditingController();
    _signupPassCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _signupNameCtrl.dispose();
    _signupPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _signupNameCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _signupPassCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final email = _signupNameCtrl.text.trim();
                final pass = _signupPassCtrl.text;
                if (email.isEmpty || pass.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter email and password')));
                  return;
                }
                // Register but do not sign in; user returns to login to sign in explicitly
                final ok = await AuthService.instance.register(email, pass);
                if (ok) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created — please sign in')));
                  Navigator.of(context).pop();
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create account')));
                }
              },
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountScreenState extends State<AccountScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _cityCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: '');
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Top-centered Sign Up button that opens the separate signup flow
          Center(
            child: SizedBox(
              width: 260,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.green,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignupScreen()));
                  // after returning, stay on the account tab (login view)
                  setState(() {});
                },
                child: const Text('Sign Up'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ValueListenableBuilder<String>(
                valueListenable: AuthService.instance.displayName,
                builder: (context, name, _) {
                      if (name.isNotEmpty) {
                        return Text('User: $name', style: Theme.of(context).textTheme.titleLarge);
                      }
                      return const SizedBox.shrink();
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
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordCtrl,
                          decoration: const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            final email = _nameCtrl.text.trim();
                            final pass = _passwordCtrl.text;
                            final ok = await AuthService.instance.signIn(email, pass);
                            if (ok) {
                              // after successful sign-in restore username into the controller for profile editing
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
                  ),
                );
              }

              // Signed in UI: show profile picture and editable username (sanitized on save)
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
                  // Username field (editable when signed in)
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Username'),
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
          ValueListenableBuilder<bool>(
            valueListenable: AuthService.instance.signedIn,
            builder: (context, signedIn, _) {
              if (!signedIn) return const SizedBox.shrink();
              return TextField(
                controller: _cityCtrl,
                decoration: const InputDecoration(labelText: 'City'),
                onSubmitted: (v) => AuthService.instance.setCity(v.trim()),
              );
            },
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<bool>(
            valueListenable: AuthService.instance.signedIn,
            builder: (context, signedIn, _) {
              if (!signedIn) return const SizedBox.shrink();
              return ElevatedButton(
                onPressed: () async {
                  await AuthService.instance.setDisplayName(_nameCtrl.text);
                  // only persist city when user is signed in
                  if (AuthService.instance.signedIn.value) {
                    await AuthService.instance.setCity(_cityCtrl.text.trim());
                  }
                  // reflect sanitized name back into the text field
                  _nameCtrl.text = AuthService.instance.displayName.value;
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
                },
                child: const Text('Save Profile'),
              );
            },
          ),
        ],
      ),
    );
  }
}
