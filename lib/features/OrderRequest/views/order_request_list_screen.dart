import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
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
      body: Obx(() {
        if (controller.isLoading.value && controller.requests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text("No order requests yet."),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Get.toNamed(Routes.createOrderRequest),
                  child: const Text("Create First Request"),
                ),
              ],
            ),
          );
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: RefreshIndicator(
              onRefresh: controller.fetchRequests,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.requests.length,
                itemBuilder: (context, index) {
                  final request = controller.requests[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Text(request.name),
                      subtitle: Text("Status: ${request.status}"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        // Navigate to details (to be implemented)
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.createOrderRequest),
        backgroundColor: AppColors.atelierSilkGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
