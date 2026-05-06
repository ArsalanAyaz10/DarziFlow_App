import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/data/models/orderCard_model.dart';
import 'package:dariziflow_app/features/Orders/controllers/order_controller.dart';
import 'package:dariziflow_app/features/Orders/widgets/order_card.dart';
import 'package:dariziflow_app/features/Orders/widgets/order_filter_chips.dart';
import 'package:dariziflow_app/features/Orders/widgets/order_list_shimmer.dart';
import 'package:dariziflow_app/features/Orders/widgets/order_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dariziflow_app/app/routes/app_pages.dart';
import 'package:dariziflow_app/features/Notifications/controllers/notification_controller.dart' as darizi_notifications;

class AllOrderScreen extends GetView<OrderController> {
  const AllOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      appBar: CustomAppBar(
        title: 'All Orders',
        isTransparent: false,
        centerTitle: true,
        showBackButton: false,
        actions: [
          IconButton(
            icon: Obx(() {
              final unreadCount =
                  Get.find<darizi_notifications.NotificationController>()
                      .unreadCount
                      .value;
              return Badge(
                isLabelVisible: unreadCount > 0,
                label: Text(unreadCount > 99 ? '99+' : unreadCount.toString()),
                backgroundColor: AppColors.error,
                child: Icon(
                  Icons.notifications_outlined,
                  color: theme.iconTheme.color,
                ),
              );
            }),
            onPressed: () {
              Get.toNamed('/notification-inbox');
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const OrderListShimmer();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 10),
                Text(
                  controller.errorMessage.value,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: controller.fetchOrders,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.filteredOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'No Orders Found',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    controller.userRole.value == "QC_MEMBER" 
                        ? 'There are no orders currently in production'
                        : 'There are no active orders in your department',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            OrderSearchBar(
              searchController: controller.searchController,
              onChanged: (value) => controller.updateSearchQuery(value),
              searchQuery: controller.searchQuery.value,
              onClear: () => controller.clearSearch(),
            ),
            OrderFilterChips(
              filterOptions: controller.filterOptions,
              selectedFilter: controller.selectedFilter.value,
              onFilterSelected: (filter) =>
                  controller.selectedFilter.value = filter,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.fetchOrders,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  itemCount: controller.filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = controller.filteredOrders[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: OrderCard(
                        order: order,
                        onTap: () => showOrderDetails(order),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void showOrderDetails(OrderModel order) {
    Get.toNamed(Routes.orderDetails, arguments: order);
  }
}
