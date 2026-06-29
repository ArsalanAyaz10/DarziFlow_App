import 'package:intl/intl.dart';

/// Formats a DateTime to 12-hour time string.
/// Example output: "9:54 pm"
String formatChatTime(DateTime date) {
  return DateFormat('h:mm a').format(date.toLocal()).toLowerCase();
}

/// Formats a DateTime for date dividers in the chat room.
/// Returns "Today", "Yesterday", or "12/06/2026".
String formatChatDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final targetDate = DateTime(date.year, date.month, date.day);

  if (targetDate == today) return 'Today';
  if (targetDate == yesterday) return 'Yesterday';
  return DateFormat('dd/MM/yyyy').format(date);
}

/// Formats a DateTime for the chat list tile timestamps.
/// Shows time for today, "Yesterday", day name for this week, or dd/MM.
String formatChatListTimestamp(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final targetDate = DateTime(dt.year, dt.month, dt.day);

  if (targetDate == today) return formatChatTime(dt);
  if (targetDate == yesterday) return 'Yesterday';

  final diff = now.difference(dt);
  if (diff.inDays < 7) return DateFormat('EEEE').format(dt);
  return DateFormat('dd/MM/yy').format(dt);
}
