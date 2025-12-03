import 'package:flutter/material.dart';
import '../../domain/entities/post.dart';
import '../../core/utils/date_time_utils.dart';

/// Reddit-style post card widget
class PostCard extends StatefulWidget {
  final PostEntity post;
  final VoidCallback? onTap;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final int? upvotes;
  final int? commentCount;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onUpvote,
    this.onDownvote,
    this.onComment,
    this.onShare,
    this.upvotes,
    this.commentCount,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with author and time
                  Row(
                    children: [
                      AvatarWidget(
                        imageUrl: widget.post.author?.imageUrl,
                        name: widget.post.author?.name ?? 'Anonymous',
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'u/${widget.post.author?.name ?? 'anonymous'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              DateTimeUtils.timeAgo(widget.post.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    widget.post.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Description
                  if (widget.post.description.isNotEmpty)
                    Text(
                      widget.post.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Image with Hero and AnimatedSwitcher
                  if (widget.post.imageUrl != null) ...[
                    const SizedBox(height: 12),
                    Hero(
                      tag: 'post-image-${widget.post.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeInOut,
                          child: Image.network(
                            widget.post.imageUrl!,
                            key: ValueKey(widget.post.imageUrl),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 200,
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Action buttons
                  Row(
                    children: [
                      // Upvote/Downvote
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_upward, size: 18),
                              onPressed: widget.onUpvote,
                              visualDensity: VisualDensity.compact,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            Text(
                              '${widget.upvotes ?? 0}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_downward, size: 18),
                              onPressed: widget.onDownvote,
                              visualDensity: VisualDensity.compact,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Comments
                      _ActionButton(
                        icon: Icons.chat_bubble_outline,
                        label: '${widget.commentCount ?? 0}',
                        onTap: widget.onComment,
                      ),
                      const SizedBox(width: 8),

                      // Share
                      _ActionButton(
                        icon: Icons.share_outlined,
                        label: 'Share',
                        onTap: widget.onShare,
                      ),
                    ],
                  ),
                ],
              ),
            ), // Padding
          ), // InkWell
        ), // Card
      ), // AnimatedScale
    ); // MouseRegion
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Avatar widget
class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(imageUrl!),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }

    // Generate initials
    final initials = name.isNotEmpty
        ? name
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .take(2)
              .join()
              .toUpperCase()
        : '?';

    // Generate color from name
    final colorIndex = name.hashCode % Colors.primaries.length;
    final backgroundColor = Colors.primaries[colorIndex.abs()];

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor,
      child: Text(
        initials,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
