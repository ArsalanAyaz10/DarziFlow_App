import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/features/Orders/controllers/orderDetail_controller.dart';
import 'package:dariziflow_app/features/Orders/widgets/order_timeline.dart';
import 'package:dariziflow_app/features/Orders/widgets/order_workflow_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';

class OrderWorkflowScreen extends GetView<OrderDetailController> {
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
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Production Progress",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "${controller.progress.value}%",
                            style: const TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      LinearProgressIndicator(
                        value: controller.progress.value / 100,
                        backgroundColor: AppColors.primaryGreen.withValues(
                          alpha: 0.1,
                        ),
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 8,
                      ),
                    ],
                  ),
                ),
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
