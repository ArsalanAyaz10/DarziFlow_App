import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/features/Orders/controllers/order_workflow_controller.dart';
import 'package:dariziflow_app/features/Orders/widgets/order_timeline.dart';
import 'package:dariziflow_app/features/Orders/widgets/order_workflow_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';

class OrderWorkflowScreen extends GetView<OrderWorkflowController> {
  const OrderWorkflowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Obx(() {
          final order = controller.order.value;
          return CustomAppBar(
            title: order?.orderName ?? "",
            centerTitle: true,
            isTransparent: true,
            showBackButton: true,
            isDashboard: false,
          );
        }),
      ),
      bottomNavigationBar: const BottomNavBar(),
      body: Obx(() {
        if (controller.isLoading.value || controller.order.value == null) {
          return const OrderWorkflowShimmer();
        }
        return RefreshIndicator(
          onRefresh: () => controller.refreshOrderDetails(),
          color: AppColors.primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Production Progress",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: controller.progress.value / 100,
                            backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(10),
                            minHeight: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "${controller.progress.value}%",
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (controller.userRole.value.toUpperCase() != 'QC_MEMBER' && 
                    controller.userRole.value.toUpperCase() != 'CLIENT') ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: AppColors.atelierAmber,
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          "Operations must be completed sequentially. Future steps remain locked until previous ones are finished.",
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.atelierAmber,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                OrderTimeline(
                  operations: controller.order.value?.operations ?? [],
                  orderId: controller.order.value?.orderId,
                  userRole: controller.userRole.value,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
