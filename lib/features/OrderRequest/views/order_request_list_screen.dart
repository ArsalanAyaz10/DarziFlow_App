import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/data/models/order_request_model.dart';
import 'package:dariziflow_app/features/OrderRequest/controllers/order_request_controller.dart';
import 'package:dariziflow_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderRequestListScreen extends GetView<OrderRequestController> {
  const OrderRequestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.atelierBackgroundDark : AppColors.atelierBackgroundLight,
      bottomNavigationBar: const BottomNavBar(currentIndex: 2), // Requests tab
      appBar: const CustomAppBar(
        title: 'Order Requests',
        isTransparent: false,
        showBackButton: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: RefreshIndicator(
            onRefresh: controller.fetchRequests,
            color: AppColors.primaryBlue,
            child: Obx(() {
              if (controller.isLoading.value && controller.requests.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
              }

              if (controller.requests.isEmpty) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height - 200,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_late_outlined, size: 64, color: AppColors.grey),
                        const SizedBox(height: 16),
                        Text(
                          "No order requests yet.",
                          style: TextStyle(
                            color: isDark ? AppColors.white : AppColors.textColorDark,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Get.toNamed(Routes.createOrderRequest),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.atelierSilkGreen,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text("Create First Request", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: controller.requests.length,
                itemBuilder: (context, index) {
                  final request = controller.requests[index];
                  return _buildRequestCard(request, isDark);
                },
              );
            }),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.createOrderRequest),
        backgroundColor: AppColors.atelierSilkGreen,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildRequestCard(OrderRequestModel request, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? AppColors.atelierSurfaceDark : AppColors.atelierSurfaceLight,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.grey.withValues(alpha:0.2), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Route to Details Screen
          Get.toNamed(Routes.orderRequestDetails, arguments: request.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.white : AppColors.textColorDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Type: ${request.type}",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatusBadge(request.status),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderRequestStatus status) {
    Color badgeColor;
    String label;

    switch (status) {
      case OrderRequestStatus.PENDING_ADMIN:
        badgeColor = AppColors.atelierAmber;
        label = "PENDING ADMIN";
        break;
      case OrderRequestStatus.PENDING_CLIENT:
        badgeColor = AppColors.primaryBlue;
        label = "ACTION REQUIRED";
        break;
      case OrderRequestStatus.CONVERTED:
        badgeColor = AppColors.primaryGreen;
        label = "CONVERTED";
        break;
      case OrderRequestStatus.CANCELED:
        badgeColor = AppColors.error;
        label = "CANCELED";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
