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
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2), // More compact margins
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Compact header with author and time in single line
                Row(
                  children: [
                    AvatarWidget(
                      imageUrl: widget.post.author?.imageUrl,
                      name: widget.post.author?.name ?? 'Anonymous',
                      size: 20, // Smaller avatar
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'u/${widget.post.author?.name ?? 'anonymous'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            ' · ${DateTimeUtils.timeAgo(widget.post.createdAt)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Reduced spacing

                // Title - more compact
                Text(
                  widget.post.title,
                  style: theme.textTheme.titleSmall?.copyWith( // Changed from titleMedium
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Description - more compact
                if (widget.post.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.post.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                    maxLines: 2, // Reduced from 3
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Image - more compact
                if (widget.post.imageUrl != null) ...[
                  const SizedBox(height: 8),
                  Hero(
                    tag: 'post-image-${widget.post.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.post.imageUrl!,
                        width: double.infinity,
                        height: 180, // Reduced from 200
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 180,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.image_not_supported, size: 32),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 8), // Reduced spacing

                // Compact action buttons
                Row(
                  children: [
                    // Upvote/Downvote - more compact
                    Container(
                      height: 28, // Fixed height for consistency
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_upward, size: 16),
                            onPressed: widget.onUpvote,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 28),
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          Text(
                            '${widget.upvotes ?? 0}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_downward, size: 16),
                            onPressed: widget.onDownvote,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 28),
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Comments - compact
                    _ActionButton(
                      icon: Icons.chat_bubble_outline,
                      label: '${widget.commentCount ?? 0}',
                      onTap: widget.onComment,
                    ),
                    const SizedBox(width: 6),

                    // Share - compact
                    _ActionButton(
                      icon: Icons.share_outlined,
                      label: 'Share',
                      onTap: widget.onShare,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 28, // Fixed height for consistency
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // More compact
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
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
