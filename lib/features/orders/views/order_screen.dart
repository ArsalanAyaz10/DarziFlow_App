import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/data/models/orderCard_model.dart';
import 'package:dariziflow_app/features/orders/controllers/order_controller.dart';
import 'package:dariziflow_app/features/orders/widgets/order_card.dart';
import 'package:dariziflow_app/features/orders/widgets/order_filter_chips.dart';
import 'package:dariziflow_app/features/orders/widgets/order_list_shimmer.dart';
import 'package:dariziflow_app/features/orders/widgets/order_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dariziflow_app/app/routes/app_pages.dart';

class OrderScreen extends GetView<OrderController> {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Orders',
        isTransparent: false,
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: theme.iconTheme.color,
            ),
            onPressed: () {
              // TODO: Notifications Feature
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
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: controller.fetchOrders,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.orders.isEmpty) {
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
                const SizedBox(height: 16),
                Text('No Orders Found', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'There are no active orders in your department',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
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
            const BottomNavBar(currentIndex: 1),
          ],
        );
      }),
    );
  }

  void showOrderDetails(OrderModel order) {
    Get.toNamed(Routes.orderDetails, arguments: order);
  }
}
