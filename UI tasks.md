---
name: darziflow-chat-ui-polish
description: Workflow to refine the Chat List and Chat Room UI to match a WhatsApp-style aesthetic, implement 12-hour time formatting, and add a read-only profile view interaction.
---

# Feature: Chat UI Polish & Profile View

## 📌 Context
The core real-time messaging logic is fully functional. Now, we need to upgrade the visual presentation to match a modern, premium messaging aesthetic (similar to WhatsApp Dark Mode). We also need to format timestamps to 12-hour notation and allow users to tap avatars to view a read-only profile screen.

## 🛠️ Step 1: 12-Hour Time Formatting Integration

Agent, all timestamps in the chat UI must be formatted to standard 12-hour AM/PM notation.

1. Ensure the `intl` package is available in `pubspec.yaml`.
2. Create or update a utility function (e.g., in `utils/date_formatter.dart`) to parse MongoDB ISO dates:
```dart
import 'package:intl/intl.dart';

String formatChatTime(DateTime date) {
  // Outputs: "9:54 pm"
  return DateFormat('h:mm a').format(date.toLocal()).toLowerCase();
}

String formatChatDate(DateTime date) {
  // Utility for date dividers (e.g., "Yesterday", "Today", or "12/06/2026")
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final targetDate = DateTime(date.year, date.month, date.day);

  if (targetDate == today) return formatChatTime(date);
  if (targetDate == yesterday) return 'Yesterday';
  return DateFormat('dd/MM/yyyy').format(date);
}