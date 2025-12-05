import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_one/core/utils/date_time_utils.dart';
import 'package:flutter_one/presentation/providers/app_providers.dart';
import 'package:flutter_one/presentation/widgets/post_card.dart';
import 'package:flutter_one/presentation/widgets/responsive_layout.dart';
import 'package:flutter_one/presentation/widgets/side_panel.dart';
import 'package:flutter_one/presentation/widgets/comment_tile.dart';
import 'package:flutter_one/presentation/controllers/auth_controller.dart';
import 'package:flutter_one/presentation/controllers/posts_controller.dart';
import 'package:flutter_one/presentation/controllers/comments_controller.dart';

/// Post detail page with Reddit-inspired design
class PostDetailPage extends StatefulWidget {
  final int postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  bool _didInit = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      // Use didChangeDependencies since we depend on InheritedWidgets
      // (AuthProvider/PostsProvider/CommentsProvider) and it runs after
      // initState when context is available for lookups.
      _fetchData();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchData() {
    PostsProvider.of(context).getPost(widget.postId);
    CommentsProvider.of(context).fetchComments(widget.postId);
  }

  Future<void> _handleAddComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    final authController = AuthProvider.of(context);
    if (!authController.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to comment')),
      );
      return;
    }

    final commentsController = CommentsProvider.of(context);
    final result = await commentsController.createComment(
      postId: widget.postId,
      comment: comment,
    );

    if (result != null) {
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _handleDeletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final postsController = PostsProvider.of(context);
      final success = await postsController.deletePost(widget.postId);
      if (success && mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsController = PostsProvider.of(context);
    final commentsController = CommentsProvider.of(context);
    final authController = AuthProvider.of(context);
    final theme = Theme.of(context);
    final post = postsController.selectedPost;

    final isOwner = authController.isAuthenticated &&
        post != null &&
        authController.user?.id == post.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        actions: [
          if (isOwner)
            PopupMenuButton<String>(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  context.push('/posts/${widget.postId}/edit');
                } else if (value == 'delete') {
                  _handleDeletePost();
                }
              },
            ),
        ],
      ),
      body: ResponsiveLayout(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeInOut,
          child: LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1000;
            if (!isWide) {
              return _buildBody(postsController, commentsController, authController, theme);
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildBody(postsController, commentsController, authController, theme)),
                const SizedBox(width: 16),
                SizedBox(width: 340, child: SidePanel()),
              ],
            );
          }),
        ),
      ),
      bottomNavigationBar: authController.isAuthenticated
          ? _buildCommentInput(commentsController, theme)
          : null,
    );
  }

  Widget _buildBody(
    PostsController postsController,
    CommentsController commentsController,
    AuthController authController,
    ThemeData theme,
  ) {
    if (postsController.state == PostsState.loading &&
        postsController.selectedPost == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (postsController.state == PostsState.error &&
        postsController.selectedPost == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              postsController.error ?? 'Failed to load post',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _fetchData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    final post = postsController.selectedPost;
    if (post == null) {
      return const Center(child: Text('Post not found'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        _fetchData();
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author info
                  Row(
                    children: [
                      AvatarWidget(
                        imageUrl: post.author?.imageUrl,
                        name: post.author?.name ?? 'Anonymous',
                        size: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'u/${post.author?.name ?? 'anonymous'}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateTimeUtils.timeAgo(post.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    post.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                  const SizedBox(height: 8),

                  // Description
                  if (post.description.isNotEmpty) ...[
                    Text(
                      post.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Image
                  if (post.imageUrl != null) ...[
                    Hero(
                      tag: 'post-image-${post.id}',
                      child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          post.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 200,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Body
                  Text(
                    post.body,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            const Divider(),

            // Comments header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.comment_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${commentsController.comments.length} Comments',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Comments list
            if (commentsController.state == CommentsState.loading &&
                commentsController.comments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (commentsController.comments.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No comments yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Be the first to comment!',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: commentsController.comments.length,
                itemBuilder: (context, index) {
                  final comment = commentsController.comments[index];
                  final isCommentOwner = authController.isAuthenticated &&
                      authController.user?.id == comment.userId;

                  return CommentTile(
                    comment: comment,
                    isOwner: isCommentOwner,
                    onEdit: isCommentOwner
                        ? () {
                            // TODO: Implement edit comment
                          }
                        : null,
                    onDelete: isCommentOwner
                        ? () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Comment'),
                                content: const Text(
                                    'Are you sure you want to delete this comment?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              commentsController.deleteComment(comment.id!);
                            }
                          }
                        : null,
                  );
                },
              ),
            const SizedBox(height: 80), // Space for bottom input
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput(CommentsController commentsController, ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleAddComment(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _handleAddComment,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
