import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/data/models/submissionModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    // Sort history to show latest at top
    final sortedHistory = history.reversed.toList();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          Text(
            "Session History",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            checkpointName,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 24),

          if (sortedHistory.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  "No activity history recorded yet.",
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: sortedHistory.length,
                itemBuilder: (context, index) {
                  final item = sortedHistory[index];
                  final isLast = index == sortedHistory.length - 1;

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline Connector
                        Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getActionColor(item.action),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24, width: 2),
                              ),
                            ),
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: Colors.white12,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item.action,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _getActionColor(item.action),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormat('MMM dd, hh:mm a').format(item.actedAt),
                                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                                  ),
                                ],
                              ),
                              Text(
                                "By User: ${item.actedBy}",
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              if (item.comment != null && item.comment!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white12),
                                  ),
                                  child: Text(
                                    item.comment!,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action.toUpperCase()) {
      case 'APPROVE':
      case 'FINAL_APPROVE':
        return AppColors.primaryGreen;
      case 'REJECT':
        return Colors.redAccent;
      case 'SUBMIT':
        return Colors.orange;
      default:
        return Colors.blueAccent;
    }
  }
}
