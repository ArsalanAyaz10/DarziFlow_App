import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/controllers/deptHeadController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllActivitiesScreen extends GetView<DeptHeadController> {
  const AllActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments passed from dashboard
    final arguments = Get.arguments as Map<String, dynamic>?;
    final initialActivities =
        arguments?['activities'] as List<Map<String, dynamic>>? ?? [];

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: _buildAppBar(),
      body: Obx(() {
        // Use controller's processedActivities if available, otherwise use passed activities
        final activities = controller.processedActivities.isNotEmpty
            ? controller.processedActivities
            : initialActivities.obs;

        if (controller.isLoading.value && activities.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (activities.isEmpty) {
          return _buildEmptyState();
        }

        return _buildActivityList(activities);
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        "All Activities",
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.grey),
          onPressed: _showFilterOptions,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history, size: 50, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Activities Yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Activities from your department\nwill appear here",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => controller.refreshDashboard(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Refresh", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(RxList<Map<String, dynamic>> activities) {
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.refreshDashboard,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildActivityCard(activity),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    // Selected filter index (0 = All, 1 = Movement, 2 = Alerts, 3 = Assignments, 4 = Submissions)
    final selectedFilter = 0.obs;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip("All", 0, selectedFilter),
            const SizedBox(width: 8),
            _buildFilterChip("Movement", 1, selectedFilter),
            const SizedBox(width: 8),
            _buildFilterChip("Alerts", 2, selectedFilter),
            const SizedBox(width: 8),
            _buildFilterChip("Assignments", 3, selectedFilter),
            const SizedBox(width: 8),
            _buildFilterChip("Submissions", 4, selectedFilter),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, RxInt selectedFilter) {
    return Obx(
      () => FilterChip(
        label: Text(label),
        selected: selectedFilter.value == index,
        onSelected: (selected) {
          selectedFilter.value = index;
          // TODO: Implement filtering logic
        },
        backgroundColor: Colors.grey.shade50,
        selectedColor: AppColors.primaryGreen.withValues(alpha: 0.1),
        checkmarkColor: AppColors.primaryGreen,
        labelStyle: TextStyle(
          color: selectedFilter.value == index
              ? AppColors.primaryGreen
              : Colors.grey.shade700,
          fontWeight: selectedFilter.value == index
              ? FontWeight.bold
              : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selectedFilter.value == index
                ? AppColors.primaryGreen
                : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final iconData = activity['iconData'] ?? _getDefaultIcon(activity['type']);
    final color = activity['color'] ?? _getDefaultColor(activity['type']);
    final title = activity['title'] ?? 'Unknown Activity';
    final subtitle = activity['subtitle'] ?? '';
    final timeAgo = activity['timeAgo'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showActivityDetails(activity),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon with colored background
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconData, color: color, size: 20),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      if (activity['orderId'] != null) ...[
                        const SizedBox(height: 8),
                        _buildOrderChip(activity['orderId']),
                      ],
                    ],
                  ),
                ),

                // Time and arrow
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Colors.grey.shade400,
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

  Widget _buildOrderChip(String orderId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 12,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 4),
          Text(
            "View Order",
            style: TextStyle(
              fontSize: 11,
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showActivityDetails(Map<String, dynamic> activity) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Activity Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailRow("Title", activity['title'] ?? ''),
            _buildDetailRow("Description", activity['subtitle'] ?? ''),
            _buildDetailRow("Time", activity['timeAgo'] ?? ''),
            if (activity['orderId'] != null)
              _buildDetailRow("Order ID", activity['orderId']),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  if (activity['orderId'] != null) {
                    Get.toNamed(
                      '/order-details',
                      arguments: activity['orderId'],
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "View Full Order",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filter Activities",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildFilterOption("All Activities", Icons.list, () {}),
            _buildFilterOption("Today", Icons.today, () {}),
            _buildFilterOption("This Week", Icons.date_range, () {}),
            _buildFilterOption("This Month", Icons.calendar_month, () {}),
            _buildFilterOption("Custom Range", Icons.tune, () {}),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text("Cancel"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(label),
      onTap: onTap,
    );
  }

  IconData _getDefaultIcon(String? type) {
    switch (type) {
      case 'movement':
        return Icons.swap_horiz;
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'assignment':
        return Icons.person_add_alt;
      case 'submission':
        return Icons.upload_file;
      case 'approval':
        return Icons.check_circle;
      case 'rejection':
        return Icons.cancel;
      default:
        return Icons.circle;
    }
  }

  Color _getDefaultColor(String? type) {
    switch (type) {
      case 'movement':
        return Colors.blue;
      case 'alert':
        return Colors.orange;
      case 'assignment':
        return Colors.purple;
      case 'submission':
        return Colors.green;
      case 'approval':
        return Colors.green;
      case 'rejection':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
