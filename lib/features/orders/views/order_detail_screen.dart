import 'package:dariziflow_app/features/Orders/controllers/orderDetail_controller.dart';
import 'package:dariziflow_app/features/Orders/widgets/order_detail_shimmer.dart';
import 'package:dariziflow_app/features/Client/views/client_operation_review_screen.dart';
import 'package:dariziflow_app/features/Client/controllers/client_department_review_controller.dart';
import 'package:dariziflow_app/core/widgets/status_badge.dart';
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
      ),
      body: Obx(() {
        if (controller.isInitialLoading.value) {
          return const OrderDetailShimmer();
        }

        final order = controller.order.value;
        if (order == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Order not found"),
                const SizedBox(height: 10),
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
                    const SizedBox(width: 12),
                    StatusBadge(status: order.workflowStatus),
                  ],
                ),
                const SizedBox(height: 20),

                // CLIENT DETAILS (SHIFTED TO TOP)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: isDark
                            ? Colors.white24
                            : Colors.grey.withValues(alpha: 0.2),
                        child: const Icon(
                          Icons.person,
                          color: brandGreen,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.clientName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                            ),
                            Text(
                              order.clientEmail,
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (controller.userRole.value != 'CLIENT')
                        IconButton(
                          icon: const Icon(Icons.chat_outlined, size: 20),
                          onPressed: () => Get.toNamed(Routes.messages),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

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
                      color: colors.outline.withValues(alpha: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "TOTAL ORDER AMOUNT",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        "${controller.order.value!.currency} ${controller.order.value!.amount}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: dateBox("CREATED AT", createdAtStr, colors),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: dateBox("DUE DATE", dueDateStr, colors)),
                  ],
                ),
                const SizedBox(height: 10),

                // ORDER TYPE & DESCRIPTION
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "TYPE: ${order.type}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      if (order.description != null &&
                          order.description!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          order.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // REQUIRED DOCUMENTS
                Text(
                  "Required Documents",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                if (order.requiredDocuments.isNotEmpty)
                  ...order.requiredDocuments.map(
                    (doc) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 20,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  doc.status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (doc.fileUrl != null)
                            TextButton.icon(
                              onPressed: () => Get.snackbar(
                                "Info",
                                "Opening ${doc.name}...",
                              ),
                              icon: const Icon(
                                Icons.visibility_outlined,
                                size: 16,
                              ),
                              label: const Text(
                                "View",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "No documents available",
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                const SizedBox(height: 25),

                // SUPPORT & QC SECTION (REFINED)
                if (controller.userRole.value == 'CLIENT') ...[
                  Row(
                    children: [
                      Expanded(
                        child: supportActionCard(
                          "Chat with QC",
                          "Verified Member",
                          () => Get.toNamed(Routes.messages),
                          colors,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: supportActionCard(
                          "Dept Head",
                          "Support",
                          () => Get.toNamed(Routes.messages),
                          colors,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: supportActionCard(
                          "Chat with QC",
                          order.qcMember ?? "Verified Member",
                          () => Get.toNamed(Routes.messages),
                          colors,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: supportActionCard(
                          "Chat with Client",
                          order.clientName,
                          () => Get.toNamed(Routes.messages),
                          colors,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                ],

                if (controller.userRole.value == 'CLIENT') ...[
                  CustomElevatedButton(
                    onPressed: () {
                      if (order.operations.isEmpty) {
                        Get.snackbar('Info', 'No operations to review');
                        return;
                      }
                      if (Get.isRegistered<
                        ClientDepartmentReviewController
                      >()) {
                        Get.delete<ClientDepartmentReviewController>();
                      }
                      Get.put(
                        ClientDepartmentReviewController(
                          orderId: order.orderId,
                          workflowStatus: order.workflowStatus,
                          operations: order.operations,
                        ),
                      );
                      Get.to(() => const ClientOperationReviewScreen());
                    },
                    text: "Open Workflow",
                    icon: Icons.account_tree,
                    backgroundColor: brandGreen,
                    foregroundColor: Colors.black,
                    height: 50,
                    borderRadius: 25,
                  ),
                  const SizedBox(height: 12),
                  CustomElevatedButton(
                    onPressed: () {
                      Get.toNamed(
                        Routes.clientTracking,
                        arguments: {"orderId": order.orderId},
                      );
                    },
                    text: "Show Progress",
                    icon: Icons.trending_up,
                    backgroundColor: colors.surfaceContainerHighest,
                    height: 50,
                    borderRadius: 25,
                  ),
                  const SizedBox(height: 20),
                ] else ...[
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
                    height: 50,
                    borderRadius: 25,
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  //mthds

  Widget dateBox(String label, String date, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 1)),
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
          const SizedBox(height: 5),
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

  Widget supportActionCard(
    String title,
    String subtitle,
    VoidCallback onTap,
    ColorScheme colors,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outline.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: colors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

}
