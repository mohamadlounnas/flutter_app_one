import 'package:intl/intl.dart';

/// Date/time utility functions
class DateTimeUtils {
  DateTimeUtils._();

  /// Format date as "Jan 1, 2024"
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat.yMMMd().format(date);
  }

  /// Format date as "Jan 1, 2024 at 3:30 PM"
  static String formatDateTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat.yMMMd().add_jm().format(date);
  }

  /// Format as relative time (e.g., "2 hours ago", "3 days ago")
  static String timeAgo(DateTime? date) {
    if (date == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Parse ISO 8601 date string safely
  static DateTime? tryParse(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    return DateTime.tryParse(dateString);
  }
}
