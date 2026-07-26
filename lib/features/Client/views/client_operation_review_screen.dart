import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/features/Client/controllers/client_department_review_controller.dart';
import 'package:dariziflow_app/features/Client/widgets/client_order_timeline.dart';
import 'package:dariziflow_app/features/Client/widgets/approve_confirmation_dialog.dart';
import 'package:dariziflow_app/features/Client/widgets/reject_department_sheet.dart';
import 'package:dariziflow_app/features/Orders/widgets/order_workflow_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientOperationReviewScreen extends GetView<ClientDepartmentReviewController> {
  const ClientOperationReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: CustomAppBar(
          title: 'Review Workflow',
          centerTitle: true,
          isTransparent: true,
          showBackButton: true,
          isDashboard: false,
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (controller.isSubmitting.value) {
            return const OrderWorkflowShimmer();
          }
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.atelierAmber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.atelierAmber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.atelierAmber.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.touch_app_rounded,
                        color: AppColors.atelierAmber,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap any operation card below to open the dropdown and review quality checkpoints.',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              ClientOrderTimeline(
                operations: controller.operations,
                orderId: controller.orderId,
              ),
            ],
          );
        }),
      ),

      bottomNavigationBar: Builder(builder: (context) {
        if (controller.isRejected) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This workflow has been rejected. It is currently being reviewed by the department.',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!controller.isApprovalPending) {
          return const SizedBox.shrink();
        }

        return Obx(() {
          final allCompleted = controller.isAllCompleted;
          final isSubmitting = controller.isSubmitting.value;
          return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: (allCompleted && !isSubmitting)
                      ? () => ApproveConfirmationDialog.show(
                          context,
                          theme.colorScheme,
                        )
                      : null,
                  icon: const Icon(Icons.verified_rounded),
                  label: const Text(
                    'Approve Department',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (allCompleted && !isSubmitting)
                        ? AppColors.primaryGreen
                        : Colors.grey.shade800,
                    foregroundColor: (allCompleted && !isSubmitting)
                        ? Colors.white
                        : Colors.white38,
                    disabledBackgroundColor: Colors.grey.shade900,
                    disabledForegroundColor: Colors.white24,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: (allCompleted && !isSubmitting) ? 2 : 0,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: isSubmitting
                      ? null
                      : () => RejectDepartmentSheet.show(
                          context,
                          theme.cardColor,
                          theme.colorScheme,
                        ),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text(
                    'Reject Department',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(
                      color: theme.colorScheme.error,
                      width: 1.5,
                    ),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        });
      }),
    );
  }
}
