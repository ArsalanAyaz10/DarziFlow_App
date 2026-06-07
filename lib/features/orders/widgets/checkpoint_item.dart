import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/status_badge.dart';
import 'package:dariziflow_app/data/models/checkpointModel.dart';
import 'package:dariziflow_app/features/Client/views/client_checkpoint_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckpointItem extends StatelessWidget {
  final CheckpointModel cp;
  final String? orderId;
  final bool isClientView;
  final bool showActions;
  final bool? isDark;

  const CheckpointItem({
    super.key,
    required this.cp,
    this.orderId,
    this.isClientView = false,
    this.showActions = false,
    this.isDark,
  });

  Color _resolveStatusColor(CheckpointModel cp, ColorScheme colors) {
    if (cp.isApproved ||
        cp.isCompleted ||
        cp.status == 'QC_APPROVED' ||
        cp.status == 'APPROVED') {
      return AppColors.atelierSilkGreen;
    }
    if (cp.isRejected ||
        cp.status == 'QC_REJECTED' ||
        cp.status == 'REJECTED') {
      return AppColors.error;
    }
    if (cp.isQcPending ||
        cp.status == 'SUBMITTED' ||
        cp.status == 'QC_PENDING' ||
        cp.status == 'PENDING') {
      return AppColors.atelierAmber;
    }
    if (cp.toBeSubmitted ||
        cp.status == 'IN_PROGRESS' ||
        cp.status == 'PRODUCTION') {
      return AppColors.primaryBlue;
    }
    return AppColors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isClientView) {
      final statusColor = _resolveStatusColor(cp, colorScheme);

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.to(() => ClientCheckpointDetailScreen(checkpoint: cp));
          },
          child: Row(
            children: [
              // Status dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.4),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          cp.name,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),

                        // Status badge
                        StatusBadge(
                          status: cp.status,
                          fontSize: 9,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    if (cp.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        cp.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    IconData stateIcon;
    Color stateColor;

    if (cp.isApproved || cp.status == 'QC_APPROVED') {
      stateIcon = Icons.check_circle;
      stateColor = AppColors.primaryGreen;
    } else if (cp.isRejected || cp.status == 'QC_REJECTED') {
      stateIcon = Icons.cancel;
      stateColor = Colors.red;
    } else if (cp.isQcPending || cp.status == 'SUBMITTED') {
      stateIcon = Icons.schedule;
      stateColor = Colors.orange;
    } else if (cp.toBeSubmitted) {
      stateIcon = Icons.upload_file;
      stateColor = Colors.blue;
    } else {
      stateIcon = Icons.radio_button_unchecked;
      stateColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(stateIcon, color: stateColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cp.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                if (cp.isRejected || cp.status == 'QC_REJECTED')
                  const Text(
                    "Rejected: View feedback",
                    style: TextStyle(color: Colors.red, fontSize: 11),
                  )
                else if (cp.isApproved || cp.status == 'QC_APPROVED')
                  const Text(
                    "Approved: Check Remarks",
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 11,
                    ),
                  )
                else if (cp.isQcPending || cp.status == 'SUBMITTED')
                  const Text(
                    "Awaiting Approval",
                    style: TextStyle(color: Colors.orange, fontSize: 11),
                  )
                else
                  const Text(
                    "View history",
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
