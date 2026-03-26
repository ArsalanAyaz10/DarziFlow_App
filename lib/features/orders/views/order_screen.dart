import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';
import 'package:dariziflow_app/data/models/orderCard_model.dart';
import 'package:dariziflow_app/features/orders/controllers/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderScreen extends GetView<OrderController> {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Obx(() {
        if (controller.isLoading.value && controller.orders.isEmpty) {
          return _buildLoadingState();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState(context);
        }

        if (controller.orders.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          children: [
            _buildSearchBar(context),
            _buildFilterChips(context),
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
                      child: _buildOrderCard(context, order),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      title: Text(
        'Orders',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: theme.iconTheme.color,
          ),
          onPressed: () {
            // TODO Notifications Feature
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => TextField(
          controller: controller.searchController,
          onChanged: (value) => controller.updateSearchQuery(value),
          decoration: InputDecoration(
            hintText: 'Search Orders',
            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            prefixIcon: Icon(
              Icons.search,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            suffixIcon: controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      controller.clearSearch();
                      FocusScope.of(context).unfocus();
                    },
                  )
                : null,
            filled: true,
            fillColor: isDark
                ? theme.colorScheme.surfaceContainerHighest
                : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.filterOptions.length,
        itemBuilder: (context, index) {
          final filter = controller.filterOptions[index];
          final isSelected = controller.selectedFilter.value == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) controller.selectedFilter.value = filter;
              },
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              selectedColor: AppColors.primaryGreen,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderCardModel order) {
    final theme = Theme.of(context);

    final bool isCompleted = order.progress >= 100;
    final bool isOverdue = order.isOverdue;

    Color progressColor = AppColors.primaryGreen;
    if (isOverdue) progressColor = theme.colorScheme.error;
    if (isCompleted) progressColor = theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showOrderDetails(order),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: ID and Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.uniqueId.toUpperCase().substring(0, 6),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    _buildStatusBadge(theme, order),
                  ],
                ),
                const SizedBox(height: 8),

                // Order Name
                Text(
                  order.orderName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // Progress Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Production Progress',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${order.progress.toInt()}%',
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: order.progress / 100,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 16),

                // Footer: Due Date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: isOverdue
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order.dueDate != null
                          ? "Due: ${order.dueDate!.day}/${order.dueDate!.month}/${order.dueDate!.year}"
                          : "No Due Date",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isOverdue
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isOverdue
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: theme.disabledColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, OrderCardModel order) {
    final bool isCompleted = order.progress >= 100;
    final Color color = AppColors.primaryGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isCompleted ? "COMPLETED" : "ACTIVE",
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryGreen),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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

  void _showOrderDetails(OrderCardModel order) {
    Get.toNamed("/order-details", arguments: {"orderId": order.orderId});
  }
}
