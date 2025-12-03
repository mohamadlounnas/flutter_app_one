import 'package:flutter/material.dart';
import '../../domain/entities/comment.dart';
import '../../core/utils/date_time_utils.dart';
import 'post_card.dart';

/// Reddit-style comment tile widget
class CommentTile extends StatelessWidget {
  final CommentEntity comment;
  final VoidCallback? onReply;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isOwner;
  final int depth;
  final int? upvotes;

  const CommentTile({
    super.key,
    required this.comment,
    this.onReply,
    this.onUpvote,
    this.onDownvote,
    this.onEdit,
    this.onDelete,
    this.isOwner = false,
    this.depth = 0,
    this.upvotes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Indent based on depth (for nested replies)
    final leftPadding = 16.0 + (depth * 16.0);
    
    return Container(
      padding: EdgeInsets.only(
        left: leftPadding,
        right: 16,
        top: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        border: depth > 0
            ? Border(
                left: BorderSide(
                  color: _getThreadColor(depth, theme),
                  width: 2,
                ),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with author and time
          Row(
            children: [
              AvatarWidget(
                imageUrl: comment.author?.imageUrl,
                name: comment.author?.name ?? 'Anonymous',
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'u/${comment.author?.name ?? 'anonymous'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '•',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateTimeUtils.timeAgo(comment.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (isOwner)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Comment text
          Text(
            comment.comment,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          
          // Action buttons
          Row(
            children: [
              // Upvote/Downvote
              _CommentAction(
                icon: Icons.arrow_upward,
                onTap: onUpvote,
              ),
              Text(
                '${upvotes ?? 0}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              _CommentAction(
                icon: Icons.arrow_downward,
                onTap: onDownvote,
              ),
              const SizedBox(width: 16),
              
              // Reply
              _CommentAction(
                icon: Icons.reply,
                label: 'Reply',
                onTap: onReply,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getThreadColor(int depth, ThemeData theme) {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];
    return colors[depth % colors.length].withOpacity(0.5);
  }
}

class _CommentAction extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onTap;

  const _CommentAction({
    required this.icon,
    this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(
                label!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
