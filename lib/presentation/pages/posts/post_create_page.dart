import 'package:flutter/material.dart';
import 'package:flutter_one/core/utils/validators.dart';
import 'package:flutter_one/presentation/providers/app_providers.dart';
import 'package:flutter_one/presentation/widgets/responsive_layout.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'dart:io' show File;
import 'package:mime/mime.dart';

/// Create/Edit post page with Reddit-inspired design
class PostCreatePage extends StatefulWidget {
  final int? postId; // If provided, we're editing

  const PostCreatePage({super.key, this.postId});

  @override
  State<PostCreatePage> createState() => _PostCreatePageState();
}

class _PostCreatePageState extends State<PostCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bodyController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isLoading = false;
  // Image info not needed; we use returned URL in controller
  bool _didInit = false;

  bool get isEditing => widget.postId != null;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit && isEditing) {
      _didInit = true;
      _loadPost();
    }
  }

  void _loadPost() {
    final postsController = PostsProvider.of(context);
    final post = postsController.posts.firstWhere(
      (p) => p.id == widget.postId,
      orElse: () => postsController.selectedPost!,
    );

    _titleController.text = post.title;
    _descriptionController.text = post.description;
    _bodyController.text = post.body;
    _imageUrlController.text = post.imageUrl ?? '';
  }

  Future<void> _pickAndUploadForPost() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null) return;
    final file = result.files.first;
    Uint8List? bytes = file.bytes;
    if (bytes == null && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }
    if (bytes == null) return;
    final fileName = file.name;
    final contentType = lookupMimeType(fileName) ?? 'application/octet-stream';

    final storageController = StorageProvider.of(context);
    final uploaded = await storageController.uploadFile(
      fileName: fileName,
      bytes: bytes,
      contentType: contentType,
    );
    if (uploaded != null) {
      if (!mounted) return;
      setState(() {
        _imageUrlController.text = uploaded.url;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(storageController.error ?? 'Upload failed')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _bodyController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    final postsController = PostsProvider.of(context);
    final imageUrl = _imageUrlController.text.trim();

    try {
      if (isEditing) {
        final result = await postsController.updatePost(
          id: widget.postId!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          body: _bodyController.text.trim(),
          imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
        );

        if (result != null && mounted) {
          Navigator.of(context).pop(result);
        }
      } else {
        final result = await postsController.createPost(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          body: _bodyController.text.trim(),
          imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
        );

        if (result != null && mounted) {
          Navigator.of(context).pop(result);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    if (postsController.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(postsController.error!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Post' : 'Create Post'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSubmit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isEditing ? 'Save' : 'Post'),
          ),
        ],
      ),
      body: ResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1000;
              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildFormChildren(theme),
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _buildFormChildren(theme),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 340,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Preview', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                if (_imageUrlController.text.isNotEmpty)
                                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(_imageUrlController.text, height: 160, fit: BoxFit.cover, errorBuilder: (context, err, st) => Container(height: 160, color: theme.colorScheme.errorContainer, child: const Icon(Icons.image_not_supported)))),
                                const SizedBox(height: 8),
                                Text(_titleController.text.isNotEmpty ? _titleController.text : 'Title', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(_descriptionController.text.isNotEmpty ? _descriptionController.text : 'Brief description...', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                const SizedBox(height: 12),
                                FilledButton(onPressed: () => Navigator.of(context).pushNamed('/posts/create'), child: const Text('Save Preview')), // just a CTA
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Additional filler items for right column
                        Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Tips', style: theme.textTheme.titleSmall), const SizedBox(height: 8), Text('Use clear titles and images to get more engagement.', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))])))
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
       ), 
    );
  }

  List<Widget> _buildFormChildren(ThemeData theme) => [
        // Title field
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            hintText: 'An interesting title',
            border: OutlineInputBorder(),
          ),
          maxLength: 200,
          validator: Validators.validateTitle,
        ),
        const SizedBox(height: 16),

        // Description field
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description (optional)',
            hintText: 'A brief description of your post',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          maxLength: 500,
        ),
        const SizedBox(height: 16),

        // Body field
        TextFormField(
          controller: _bodyController,
          decoration: const InputDecoration(
            labelText: 'Content',
            hintText: 'What\'s on your mind?',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 10,
          validator: Validators.validateBody,
        ),
        const SizedBox(height: 16),

        // Image URL field
        TextFormField(
          controller: _imageUrlController,
          decoration: InputDecoration(
            labelText: 'Image URL (optional)',
            hintText: 'https://example.com/image.jpg',
            border: const OutlineInputBorder(),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: _pickAndUploadForPost,
                  tooltip: 'Pick image',
                ),
                IconButton(
                  icon: const Icon(Icons.preview),
                  onPressed: () {
                    if (_imageUrlController.text.isNotEmpty) {
                      setState(() {}); // Refresh to show preview
                    }
                  },
                ),
              ],
            ),
          ),
          keyboardType: TextInputType.url,
          validator: Validators.validateUrl,
        ),
        const SizedBox(height: 16),

        // Image preview
        if (_imageUrlController.text.isNotEmpty)
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Image Preview', style: theme.textTheme.labelMedium),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                  child: Image.network(
                    _imageUrlController.text,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: theme.colorScheme.errorContainer,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 48, color: theme.colorScheme.error),
                            const SizedBox(height: 8),
                            Text('Failed to load image', style: TextStyle(color: theme.colorScheme.error)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),

        // Submit button
        FilledButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(isEditing ? 'Save Changes' : 'Create Post'),
          ),
        ),
      ];
}
