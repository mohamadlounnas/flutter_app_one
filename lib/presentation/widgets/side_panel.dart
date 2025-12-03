import 'package:flutter/material.dart';
import 'package:flutter_one/presentation/providers/app_providers.dart';
// removed unused import

/// A simple side panel to show trending posts, brief stats and a CTA for creating posts.
class SidePanel extends StatelessWidget {
  const SidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final postsController = PostsProvider.of(context);
    final theme = Theme.of(context);

    // Pick top 5 posts (best effort). If no posts show placeholder.
    final top = postsController.posts.isNotEmpty
        ? postsController.posts.take(5).toList()
        : <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trending', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Hot posts and community highlights', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 12),
                if (top.isEmpty)
                  Column(
                    children: [
                      Icon(Icons.local_fire_department, size: 48, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 8),
                      Text('No trending posts', style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Text('Start by sharing something interesting!', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))
                    ],
                  )
                else
                  ...top.map((p) => _TrendingItem(post: p as dynamic)).toList(),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () { Navigator.of(context).pushNamed('/posts/create'); },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Post'),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Extra card for stats
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Community', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text('${postsController.posts.length} posts', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                const Icon(Icons.people),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TrendingItem extends StatelessWidget {
  final dynamic post;

  const _TrendingItem({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => Navigator.of(context).pushNamed('/posts/${post.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.title ?? '', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('u/${post.author?.name ?? 'anonymous'} · ${post.upvotes ?? 0} upvotes', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (post.imageUrl != null) 
              ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network(post.imageUrl!, width: 48, height: 48, fit: BoxFit.cover)),
          ],
        ),
      ),
    );
  }
}
