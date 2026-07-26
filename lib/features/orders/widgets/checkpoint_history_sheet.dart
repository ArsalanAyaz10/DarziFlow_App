import 'package:dariziflow_app/data/models/submissionModel.dart';
import 'package:dariziflow_app/features/Orders/widgets/timeline_item_card.dart';
import 'package:flutter/material.dart';

class CheckpointHistorySheet extends StatelessWidget {
  final List<HistoryItem> history;
  final String checkpointName;

  const CheckpointHistorySheet({
    super.key,
    required this.history,
    required this.checkpointName,
  });

  @override
  Widget build(BuildContext context) {
    final sortedHistory = history.reversed.toList();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          Text(
            "Session History",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            checkpointName,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),

          if (sortedHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  "No activity history recorded yet.",
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                itemCount: sortedHistory.length,
                itemBuilder: (context, index) {
                  final item = sortedHistory[index];
                  final isLast = index == sortedHistory.length - 1;

                  return TimelineItemCard(
                    item: item,
                    isLast: isLast,
                    isDark: isDark,
                  );
                },
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
