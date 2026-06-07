import 'package:dariziflow_app/data/models/submissionModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimelineItemCard extends StatelessWidget {
  final HistoryItem item;
  final bool isLast;
  final bool isDark;

  const TimelineItemCard({
    super.key,
    required this.item,
    required this.isLast,
    required this.isDark,
  });

  static const _successGreen = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final actionUpper = item.action.toUpperCase();
    IconData icon = Icons.info_outline;
    Color iconBg = Colors.grey;

    if (actionUpper.contains('APPROVE') || actionUpper.contains('COMPLET')) {
      icon = Icons.check_circle_outline;
      iconBg = _successGreen;
    } else if (actionUpper.contains('REJECT')) {
      icon = Icons.cancel_outlined;
      iconBg = colorScheme.error;
    } else if (actionUpper.contains('SUBMIT')) {
      icon = Icons.assignment_turned_in_outlined;
      iconBg = Colors.orange;
    } else {
      icon = Icons.info_outline;
      iconBg = Colors.blueAccent;
    }

    final formattedDate = DateFormat('MMM dd, yyyy – hh:mm a').format(item.actedAt.toLocal());

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left timeline column
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBg.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: iconBg.withValues(alpha: 0.35), width: 1.5),
                ),
                child: Icon(icon, color: iconBg, size: 16),
              ),
              Expanded(
                child: isLast
                    ? const SizedBox(height: 16)
                    : Container(
                        width: 2,
                        color: isDark 
                            ? theme.dividerColor.withValues(alpha: 0.15) 
                            : theme.dividerColor.withValues(alpha: 0.4),
                      ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Right content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.action.replaceAll('_', ' '),
                  style: TextStyle(
                    color: isDark ? Colors.white : colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'By ${item.actedBy} • $formattedDate',
                  style: TextStyle(
                    color: isDark 
                        ? Colors.white54 
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
                if (item.comment != null && item.comment!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.black.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : colorScheme.outlineVariant.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      item.comment!,
                      style: TextStyle(
                        color: isDark 
                            ? Colors.white70 
                            : colorScheme.onSurface.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ] else
                  const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
