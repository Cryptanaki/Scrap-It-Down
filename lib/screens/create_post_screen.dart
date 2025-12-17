import 'package:flutter/material.dart';
import 'package:scrap_it_down/models/post.dart';
import 'package:scrap_it_down/services/services.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img_package;

class CreatePostScreen extends StatefulWidget {
  final String category;
  final bool priceAllowed;
  final String? editPostId;
  const CreatePostScreen({super.key, required this.category, required this.priceAllowed, this.editPostId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleC = TextEditingController();
  final _descC = TextEditingController();
  final _priceC = TextEditingController();
  bool _isFree = false;
  String? _imagePath;

  @override
  void dispose() {
    _titleC.dispose();
    _descC.dispose();
    _priceC.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final id = const Uuid().v4();
    final title = _titleC.text.trim();
    final desc = _descC.text.trim();
    final isFree = _isFree || !widget.priceAllowed;
    final price = (!isFree && widget.priceAllowed && _priceC.text.isNotEmpty)
        ? double.tryParse(_priceC.text)
        : null;

    // determine sellerName: preserve existing when editing, otherwise current user displayName
    String seller = 'Anonymous';
    if (widget.editPostId != null) {
      final existing = PostService.instance.posts.value.firstWhere((p) => p.id == widget.editPostId, orElse: () => Post(id: '', category: '', title: '', description: '', isFree: true, sellerName: 'Anonymous'));
      seller = existing.sellerName;
    } else {
      seller = AuthService.instance.displayName.value.isNotEmpty ? AuthService.instance.displayName.value : 'Anonymous';
    }

    final post = Post(
      id: widget.editPostId ?? id,
      category: widget.category,
      title: title,
      description: desc,
      isFree: isFree,
      price: price,
      imagePath: _imagePath,
      city: widget.editPostId != null ?
        (PostService.instance.posts.value.firstWhere((p) => p.id == widget.editPostId, orElse: () => Post(id: '', category: '', title: '', description: '', isFree: true, sellerName: 'Anonymous')).city)
        : (AuthService.instance.city.value.isNotEmpty ? AuthService.instance.city.value : null),
      sellerName: seller,
    );

    if (widget.editPostId != null) {
      await PostService.instance.updatePost(post);
    } else {
      await PostService.instance.addPost(post);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isScrap = widget.category.toLowerCase().contains('scrap');
    final isJewelry = widget.category.toLowerCase().contains('jewel');
    final isCoin = widget.category.toLowerCase().contains('coin');
    final isSocial = widget.category.toLowerCase().contains('social');

    // If editing, prefill fields from existing post
    if (widget.editPostId != null && _titleC.text.isEmpty && _descC.text.isEmpty) {
      final existing = PostService.instance.posts.value.firstWhere(
        (p) => p.id == widget.editPostId,
        orElse: () => Post(id: '', category: '', title: '', description: '', isFree: true, sellerName: 'Anonymous'),
      );
      if (existing.id.isNotEmpty) {
        _titleC.text = existing.title;
        _descC.text = existing.description;
        _isFree = existing.isFree;
        // For Social category, images are not allowed
        _imagePath = isSocial ? null : existing.imagePath;
        if (existing.price != null) _priceC.text = existing.price.toString();
      }
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Images are disabled for Social posts
              if (!isSocial) ...[
                if (_imagePath != null) ...[
                  Image.file(File(_imagePath!)),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => setState(() => _imagePath = null),
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text('Remove image', style: TextStyle(color: Colors.white)),
                  ),
                ],
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Add Photo'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo),
                      label: const Text('Gallery'),
                    ),
                  ],
                ),
              ],
              TextFormField(
                controller: _titleC,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descC,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a description' : null,
              ),
              const SizedBox(height: 12),
              if (!isScrap) ...[
                // Jewelry and Coin posts are not allowed to be marked free
                if (!isJewelry && !isCoin) ...[
                  SwitchListTile(
                    title: const Text('Post for free'),
                    value: _isFree,
                    onChanged: (v) => setState(() => _isFree = v),
                  ),
                ],
                // Show price field when the post is not free, and always require for Jewelry/Coin
                if ((!_isFree && !isJewelry && !isCoin) || isJewelry || isCoin) ...[
                  TextFormField(
                    controller: _priceC,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final effectiveFree = (isJewelry || isCoin) ? false : _isFree;
                      if (effectiveFree) return null;
                      if (v == null || v.trim().isEmpty) return 'Enter a price';
                      if (double.tryParse(v) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                ],
              ] else ...[
                // Scrap/Metal: force free-only
                const ListTile(title: Text('This category allows FREE giveaways only.')),
              ],
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submit, child: const Text('Post')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ok = await _ensurePermission(Permission.camera);
    if (!ok) return;
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.camera, maxWidth: 1200);
    if (x == null) return;
    await _savePickedFile(x);
  }

  Future<void> _pickFromGallery() async {
    final ok = await _ensurePermission(Permission.photos) || await _ensurePermission(Permission.storage);
    if (!ok) return;
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (x == null) return;
    await _savePickedFile(x);
  }

  Future<bool> _ensurePermission(Permission perm) async {
    final status = await perm.status;
    if (status.isGranted) return true;
    final res = await perm.request();
    if (res.isGranted) return true;
    // inform user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission denied')));
    }
    // optionally prompt to open app settings
    return false;
  }

  Future<void> _savePickedFile(XFile xfile) async {
    try {
      final bytes = await xfile.readAsBytes();
      // decode and resize/compress
      final image = img_package.decodeImage(bytes);
      final resized = (image == null) ? null : img_package.copyResize(image, width: 1200);
      final jpg = resized == null ? bytes : img_package.encodeJpg(resized, quality: 85);
      final docDir = await getApplicationDocumentsDirectory();
      final dest = File('${docDir.path}/${const Uuid().v4()}.jpg');
      await dest.writeAsBytes(jpg);
      setState(() => _imagePath = dest.path);
    } catch (e) {
      debugPrint('savePickedFile error: $e');
    }
  }
}
