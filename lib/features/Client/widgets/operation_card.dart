import 'package:flutter/material.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/data/models/operationModel.dart';
import 'package:dariziflow_app/core/widgets/status_badge.dart';
import 'package:dariziflow_app/features/Orders/widgets/checkpoint_item.dart';

class OperationCard extends StatelessWidget {
  final OperationModel operation;
  final String orderId;
  final bool isDark;
  final Color cardColor;
  final bool isFirst;
  final bool isLast;

  const OperationCard({
    super.key,
    required this.operation,
    required this.orderId,
    required this.isDark,
    required this.cardColor,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPending = operation.status == 'CLIENT_APPROVAL_PENDING';
    final isDone = operation.isCompleted;

    // Resolve visual indicator colors based on state
    final Color stepColor = isDone
        ? AppColors.atelierSilkGreen
        : (isPending ? AppColors.atelierAmber : colorScheme.outlineVariant);

    final lineColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.12);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline Visual Indicator Line ──
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Top line segment
                Container(
                  width: 2,
                  height: 16,
                  color: isFirst ? Colors.transparent : lineColor,
                ),
                // Indicator circle with status styling and optional shadow pulse
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.atelierSilkGreen.withValues(alpha: 0.15)
                        : (isPending
                              ? AppColors.atelierAmber.withValues(alpha: 0.15)
                              : Colors.transparent),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: stepColor,
                      width: isPending ? 2.0 : 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isDone
                          ? Icons.check_circle_rounded
                          : (isPending
                                ? Icons.pending_actions_rounded
                                : Icons.radio_button_unchecked_rounded),
                      size: isDone ? 18 : 16,
                      color: stepColor,
                    ),
                  ),
                ),
                // Bottom line segment
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : lineColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Operation Card Content ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isPending
                        ? AppColors.atelierAmber.withValues(alpha: 0.5)
                        : theme.dividerColor.withValues(alpha: 0.5),
                    width: isPending ? 1.5 : 1.0,
                  ),
                  boxShadow: isPending
                      ? [
                          BoxShadow(
                            color: AppColors.atelierAmber.withValues(
                              alpha: 0.05,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                clipBehavior: Clip.antiAlias,
                child: Theme(
                  data: theme.copyWith(
                    dividerColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: isPending,
                    collapsedIconColor: isDark
                        ? Colors.white70
                        : Colors.black54,
                    iconColor: isDark ? Colors.white : Colors.black,
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    childrenPadding: EdgeInsets.zero,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          operation.name,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.checklist_rounded,
                              size: 13,
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${operation.checkpoints.length} Checkpoints',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.8,
                                ),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: StatusBadge(
                      status: operation.status,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    children: [
                      Divider(
                        height: 1,
                        color: theme.dividerColor.withValues(alpha: 0.5),
                      ),
                      ...operation.checkpoints.asMap().entries.map((entry) {
                        final index = entry.key;
                        final cp = entry.value;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (index > 0)
                              Divider(
                                height: 1,
                                indent: 20,
                                endIndent: 20,
                                color: theme.dividerColor.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            CheckpointItem(
                              cp: cp,
                              orderId: orderId,
                              isClientView: true,
                              showActions: isPending,
                              isDark: isDark,
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
