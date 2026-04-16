import 'package:dariziflow_app/features/orders/controllers/orderDetail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';
import 'package:dariziflow_app/core/widgets/custom_elevated_button.dart';
import 'package:dariziflow_app/app/routes/app_pages.dart';

class OrderDetailScreen extends GetView<OrderDetailController> {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    const brandGreen = Color(0xFF96E072);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: "Order Details",
        centerTitle: false,
        isTransparent: true,
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: brandGreen),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.order.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: brandGreen),
          );
        }

        final order = controller.order.value;
        if (order == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Order not found"),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.refreshOrderDetails(),
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        final dueDateStr = order.dueDate != null
            ? "${order.dueDate!.day}/${order.dueDate!.month}/${order.dueDate!.year}"
            : "N/A";

        final createdAtStr = order.createdAt != null
            ? "${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}"
            : "Loading...";

        return RefreshIndicator(
          color: brandGreen,
          onRefresh: () async => await controller.refreshOrderDetails(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        order.orderName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildActiveStatusBadge(order.overallStatus, colors),
                  ],
                ),
                const SizedBox(height: 24),

                //  AMOUNT
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "TOTAL INVOICE AMOUNT",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        "${controller.order.value!.currency} ${controller.order.value!.amount}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _buildDateInfoBox(
                        "CREATED AT",
                        createdAtStr,
                        colors,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateInfoBox("DUE DATE", dueDateStr, colors),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Divider(
                  color: colors.outline.withValues(alpha: 0.1),
                  height: 1,
                ),
                const SizedBox(height: 32),

                // CLIENT DETAILS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Client Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    Icon(
                      Icons.contact_mail_rounded,
                      color: brandGreen.withValues(alpha: 0.8),
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: isDark
                            ? Colors.black26
                            : Colors.white60,
                        child: const Icon(Icons.person, color: brandGreen),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.order.value!.clientName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.order.value!.clientEmail,
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                CustomElevatedButton(
                  onPressed: () {},
                  text: "Chat",
                  icon: Icons.chat_bubble,
                  backgroundColor: brandGreen,
                  height: 56,
                  borderRadius: 25,
                ),
                const SizedBox(height: 16),
                CustomElevatedButton(
                  onPressed: () {
                    Get.toNamed(
                      Routes.workflow,
                      arguments: {"orderId": order.orderId},
                    );
                  },
                  text: "Open Workflow",
                  icon: Icons.account_tree,
                  backgroundColor: colors.surfaceContainerHighest,
                  height: 56,
                  borderRadius: 25,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  // PRIVATE  mthds

  Widget _buildActiveStatusBadge(String status, ColorScheme colors) {
    if (status == 'null' || status.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "Loading...",
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      );
    }

    Color activeColor = const Color(0xFF96E072);
    if (status == "IN_PROGRESS") {
      activeColor = Colors.orange;
    } else if (status == "COMPLETED") {
      activeColor = colors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: activeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: activeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: activeColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfoBox(String label, String date, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
