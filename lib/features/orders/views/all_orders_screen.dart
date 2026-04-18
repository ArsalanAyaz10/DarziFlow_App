import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/data/models/orderCard_model.dart';
import 'package:dariziflow_app/features/orders/controllers/all_orders_controller.dart';
import 'package:dariziflow_app/features/orders/widgets/order_card.dart';
import 'package:dariziflow_app/features/orders/widgets/order_filter_chips.dart';
import 'package:dariziflow_app/features/orders/widgets/order_list_shimmer.dart';
import 'package:dariziflow_app/features/orders/widgets/order_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllOrdersScreen extends GetView<AllOrdersController> {
  const AllOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'All Orders',
        isTransparent: false,
        showBackButton: true,
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
                    backgroundColor: AppColors.primaryGreen,
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
                  'There are no orders to display',
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
              onChanged: (value) => controller.updateSearchBar(value),
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
                        onTap: () => _showOrderDetails(order),
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

  void _showOrderDetails(OrderModel order) {
    if (order.operations.isEmpty) {
      _showNotStartedDialog(Get.context!);
      return;
    }
    Get.toNamed("/order-details", arguments: {"orderId": order.orderId});
  }

  void _showNotStartedDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(
          Icons.info_outline_rounded,
          size: 48,
          color: Colors.orange.shade400,
        ),
        title: Text(
          'Workflow Not Started',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This order has not started its workflow in this department yet.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
            ),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
