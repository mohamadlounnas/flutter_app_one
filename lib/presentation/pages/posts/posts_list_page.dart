import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_one/presentation/providers/app_providers.dart';
import 'package:flutter_one/presentation/widgets/post_card.dart';
import 'package:flutter_one/presentation/widgets/responsive_layout.dart';
import 'package:flutter_one/presentation/widgets/side_panel.dart';
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
  String? _searchQuery;

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
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
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
              onPressed: () {
                context.go('/profile');
              },
            )
          else
            TextButton(
              onPressed: () {
                context.go('/login');
              },
              child: const Text('Login'),
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
                return _buildBody(postsController, theme);
              }

              // Desktop/tablet layout: show posts + side panel
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildBody(postsController, theme)),
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

  Widget _buildBody(PostsController postsController, ThemeData theme) {
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

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: postsController.posts.length + (postsController.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= postsController.posts.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final post = postsController.posts[index];
        return PostCard(
          post: post,
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
