import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/features/Client/controllers/client_tracking_controller.dart';
import 'package:dariziflow_app/features/Client/widgets/tracking_event_card.dart';
import 'package:dariziflow_app/features/Client/widgets/tracking_header.dart';
import 'package:dariziflow_app/features/Orders/widgets/order_workflow_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientTrackingScreen extends GetView<ClientTrackingController> {
  const ClientTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: CustomAppBar(
          isDashboard: false,
          isTransparent: true,
          showBackButton: true,
          title: "Order Tracking",
          centerTitle: true,
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: Obx(() {
        if (controller.isLoading.value) return const OrderWorkflowShimmer();

        final order = controller.order.value;
        if (order == null)
          return EmptyState(
            theme,
            "Order Not Found",
            Icons.inventory_2_outlined,
          );

        return RefreshIndicator(
          onRefresh: () => controller.fetchOrderDetails(),
          color: AppColors.atelierSilkGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                TrackingHeader(
                  order: order,
                  stepNames: controller.stepNames,
                  currentStep: controller.currentStep,
                  progressValue: controller.progressValue,
                  displayProgress: controller.displayProgress,
                ),
                Divider(color: theme.colorScheme.outlineVariant, height: 10),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "LATEST UPDATES",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: theme.hintColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (controller.events.isEmpty)
                  EmptyState(theme, "No Updates Yet.", null)
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.events.length,
                      itemBuilder: (context, i) => TrackingEventCard(
                        event: controller.events[i],
                        isFirst: i == 0,
                        isLast: i == controller.events.length - 1,
                      ),
                    ),
                  ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget EmptyState(ThemeData theme, String msg, IconData? icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) Icon(icon, size: 40, color: theme.disabledColor),
          const SizedBox(height: 10),
          Text(msg, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
