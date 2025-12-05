import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_one/presentation/providers/app_providers.dart';
import 'package:flutter_one/presentation/widgets/post_card.dart';
import 'package:flutter_one/presentation/widgets/responsive_layout.dart';
import 'package:flutter_one/presentation/widgets/side_panel.dart';
import 'package:flutter_one/presentation/controllers/auth_controller.dart';
import 'package:flutter_one/presentation/controllers/posts_controller.dart';

/// Posts list page with Reddit-inspired design
class PostsListPage extends StatefulWidget {
  const PostsListPage({super.key});

  @override
  State<PostsListPage> createState() => _PostsListPageState();
}

class _PostsListPageState extends State<PostsListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _composerTitleController = TextEditingController();
  final _composerBodyController = TextEditingController();
  final _composerTitleFocus = FocusNode();
  final _composerBodyFocus = FocusNode();
  String? _searchQuery;
  bool _isComposerExpanded = false;
  bool _isSubmittingPost = false;
  String? _composerError;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Avoid calling context.dependOnInheritedWidgetOfExactType during initState
    // because the widget tree might not be fully ready yet. Schedule the
    // initial fetch for after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchPosts());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _composerTitleController.dispose();
    _composerBodyController.dispose();
    _composerTitleFocus.dispose();
    _composerBodyFocus.dispose();
    super.dispose();
  }

  void _fetchPosts() {
    PostsProvider.of(context).fetchPosts(refresh: true, search: _searchQuery);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      PostsProvider.of(context).loadMore(search: _searchQuery);
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query.isEmpty ? null : query;
    });
    PostsProvider.of(context).fetchPosts(refresh: true, search: _searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final postsController = PostsProvider.of(context);
    final authController = AuthProvider.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        centerTitle: false, // Left-aligned like Reddit
        titleTextStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            iconSize: 22, // Slightly smaller
            onPressed: () {
              showSearch(
                context: context,
                delegate: _PostSearchDelegate(
                  postsController: postsController,
                  onSearch: _handleSearch,
                ),
              );
            },
          ),
          if (authController.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.person),
              iconSize: 22,
              onPressed: () {
                context.go('/profile');
              },
            )
          else
            TextButton(
              onPressed: () {
                context.go('/login');
              },
              child: const Text('Login', style: TextStyle(fontSize: 13)),
            ),
        ],
      ),
      body: ResponsiveLayout(
        child: RefreshIndicator(
          onRefresh: () async {
            _fetchPosts();
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeInOut,
            child: LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1000;
              if (!isWide) {
                return _buildBody(postsController, authController, theme);
              }

              // Desktop/tablet layout: show posts + side panel
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildBody(postsController, authController, theme),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(width: 340, child: SidePanel()),
                ],
              );
            }),
          ),
        ),
      ),
      floatingActionButton: authController.isAuthenticated
          ? FloatingActionButton(
              onPressed: () {
                context.push('/posts/create');
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody(
    PostsController postsController,
    AuthController authController,
    ThemeData theme,
  ) {
    if (postsController.state == PostsState.initial ||
        (postsController.state == PostsState.loading &&
            postsController.posts.isEmpty)) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (postsController.state == PostsState.error &&
        postsController.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              postsController.error ?? 'Something went wrong',
              style: TextStyle(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _fetchPosts,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (postsController.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No posts yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share something!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final additionalItems = 1 + (postsController.hasMore ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.zero, // Remove padding for compact Reddit-style layout
      itemCount: postsController.posts.length + additionalItems,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildInlineComposer(authController, theme);
        }

        final postIndex = index - 1;

        if (postIndex >= postsController.posts.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final post = postsController.posts[postIndex];
        return PostCard(
          post: post,
          upvotes: post.upvotes,
          onTap: () {
            context.push('/posts/${post.id}');
          },
          onComment: () {
            context.push('/posts/${post.id}');
          },
        );
      },
    );
  }

  Widget _buildInlineComposer(AuthController authController, ThemeData theme) {
    final isAuthenticated = authController.isAuthenticated;
    final avatarUrl = authController.user?.imageUrl;
    final displayName = authController.user?.name ?? 'Guest';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Card(
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AvatarWidget(
                      imageUrl: avatarUrl,
                      name: displayName,
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _isComposerExpanded
                          ? Column(
                              children: [
                                TextField(
                                  controller: _composerTitleController,
                                  focusNode: _composerTitleFocus,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    hintText: 'Give it a quick headline (optional)',
                                    border: InputBorder.none,
                                  ),
                                  style: theme.textTheme.bodyMedium,
                                ),
                                TextField(
                                  controller: _composerBodyController,
                                  focusNode: _composerBodyFocus,
                                  decoration: const InputDecoration(
                                    hintText: "What's happening?",
                                    border: InputBorder.none,
                                  ),
                                  minLines: 3,
                                  maxLines: 5,
                                ),
                              ],
                            )
                          : GestureDetector(
                              onTap: () => _handleComposerTap(isAuthenticated),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  isAuthenticated
                                      ? "What's happening?"
                                      : 'Log in to post',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
                if (_composerError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _composerError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                if (_isComposerExpanded) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed:
                            _isSubmittingPost ? null : () => _resetComposer(collapse: true),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _isSubmittingPost
                            ? null
                            : () => _submitInlinePost(authController),
                        child: _isSubmittingPost
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Post'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleComposerTap(bool isAuthenticated) {
    if (!isAuthenticated) {
      context.go('/login');
      return;
    }

    setState(() {
      _isComposerExpanded = true;
      _composerError = null;
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      if (!_composerTitleFocus.hasFocus) {
        _composerTitleFocus.requestFocus();
      }
    });
  }

  void _resetComposer({bool collapse = false}) {
    setState(() {
      _composerTitleController.clear();
      _composerBodyController.clear();
      _composerError = null;
      _isSubmittingPost = false;
      if (collapse) {
        _isComposerExpanded = false;
      }
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _submitInlinePost(AuthController authController) async {
    if (!authController.isAuthenticated) {
      context.go('/login');
      return;
    }

    final body = _composerBodyController.text.trim();
    final titleInput = _composerTitleController.text.trim();

    if (body.isEmpty) {
      setState(() {
        _composerError = 'Write something before posting.';
      });
      return;
    }

    final title = titleInput.isNotEmpty ? titleInput : _deriveTitleFromBody(body);
    final description = _deriveDescription(body);

    setState(() {
      _isSubmittingPost = true;
      _composerError = null;
    });

    final postsController = PostsProvider.of(context);
    final result = await postsController.createPost(
      title: title,
      description: description,
      body: body,
      imageUrl: null,
    );

    if (!mounted) return;

    if (result != null) {
      _resetComposer(collapse: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post published')),
      );
    } else {
      setState(() {
        _isSubmittingPost = false;
        _composerError = postsController.error ?? 'Failed to publish post';
      });
    }
  }

  String _deriveTitleFromBody(String body) {
    final firstLine = body.split('\n').first.trim();
    final base = firstLine.isNotEmpty ? firstLine : body.trim();
    if (base.isEmpty) {
      return 'New post';
    }
    return base.length <= 80 ? base : base.substring(0, 80);
  }

  String _deriveDescription(String body) {
    const maxLength = 160;
    if (body.length <= maxLength) return body;
    return '${body.substring(0, maxLength - 3)}...';
  }
}

class _PostSearchDelegate extends SearchDelegate<String> {
  final PostsController postsController;
  final Function(String) onSearch;

  _PostSearchDelegate({
    required this.postsController,
    required this.onSearch,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    close(context, query);
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('Search for posts...'),
    );
  }
}
