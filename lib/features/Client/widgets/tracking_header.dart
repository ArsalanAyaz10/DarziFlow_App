import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/data/models/orderCard_model.dart';
import 'package:dariziflow_app/features/Client/widgets/step_progress_indicator.dart';
import 'package:flutter/material.dart';

class TrackingHeader extends StatelessWidget {
  final OrderModel order;
  final List<String> stepNames;
  final int currentStep;
  final double progressValue;
  final String displayProgress;

  const TrackingHeader({
    super.key,
    required this.order,
    required this.stepNames,
    required this.currentStep,
    required this.progressValue,
    required this.displayProgress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(order.overallStatus);
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    order.orderName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: AppColors.atelierSilkGreen.withValues(alpha: 0.4),
                    ),
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.overallStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
        ),
        Divider(color: theme.colorScheme.outlineVariant, height: 1),
        const SizedBox(height: 25),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5), // minimal padding to prevent clipping
            child: StepProgressIndicator(
              stepNames: stepNames,
              currentStep: currentStep,
              progress: progressValue,
              activeColor: AppColors.atelierSilkGreen,
              inactiveColor: theme.disabledColor.withValues(alpha: 0.2),
              activeLineColor: AppColors.atelierSilkGreen,
              inactiveLineColor: theme.disabledColor.withValues(alpha: 0.2),
          ),
        ),
          const SizedBox(height: 15),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Overall Progress",
                  style: TextStyle(fontSize: 12, color: theme.hintColor),
              ),
                Text(
                  displayProgress,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.atelierSilkGreen,
                ),
              ),
              ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    status = status.toUpperCase();
    if (status == 'COMPLETED' || status == 'DELIVERED')
      return AppColors.atelierSilkGreen;
    if (status == 'IN_PROGRESS' || status == 'PRODUCTION')
      return AppColors.primaryBlue;
    if (status == 'PENDING') return Colors.orange;
    if (status == 'CANCELLED' || status == 'REJECTED') return AppColors.error;
    return AppColors.grey;
  }
}
