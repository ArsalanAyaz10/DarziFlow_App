import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/status_badge.dart';
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
              StatusBadge(
                status: order.overallStatus,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),
        ),
        Divider(color: theme.colorScheme.outlineVariant, height: 1),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
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
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
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

}
