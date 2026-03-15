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

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Create a local observable for the selected filter
    final selectedFilter = 0.obs;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: _buildAppBar(context, selectedFilter),
      body: Obx(() {
        // Use controller's processedActivities if available, otherwise use passed activities
        final activities = controller.processedActivities.isNotEmpty
            ? controller.processedActivities
            : initialActivities.obs;

        if (controller.isLoading.value && activities.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (activities.isEmpty) {
          return _buildEmptyState(context);
        }

        // Filter logic
        final filteredActivities = _filterActivities(
          activities.toList(),
          selectedFilter.value,
        );

        return _buildActivityList(context, filteredActivities, selectedFilter);
      }),
    );
  }

  List<Map<String, dynamic>> _filterActivities(
    List<Map<String, dynamic>> activities,
    int filterIndex,
  ) {
    if (filterIndex == 0) return activities; // All

    final typeMappings = {
      1: 'movement',
      2: 'alert',
      3: 'assignment',
      4: 'submission',
    };

    final filterType = typeMappings[filterIndex];

    if (filterType != null) {
      return activities.where((a) => a['type'] == filterType).toList();
    }

    return activities;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, RxInt selectedFilter) {
    final colors = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colors.onSurface),
        onPressed: () => Get.back(),
      ),
      title: Text(
        "All Activities",
        style: TextStyle(
          color: colors.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history,
              size: 50,
              color: colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No Activities Yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Activities from your department\nwill appear here",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => controller.refreshDashboard(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(
    BuildContext context,
    List<Map<String, dynamic>> activities,
    RxInt selectedFilter,
  ) {
    return Column(
      children: [
        _buildFilterBar(context, selectedFilter),
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.refreshDashboard,
            color: AppColors.primaryGreen,
            child: activities.isEmpty
                ? _buildEmptyFilteredState(context, selectedFilter)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildActivityCard(context, activity),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyFilteredState(BuildContext context, RxInt selectedFilter) {
    final colors = Theme.of(context).colorScheme;
    final filterNames = [
      'All',
      'Movement',
      'Alerts',
      'Assignments',
      'Submissions',
    ];
    final name = filterNames[selectedFilter.value];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: colors.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            "No $name Activities",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => selectedFilter.value = 0,
            child: Text(
              "Clear Filters",
              style: TextStyle(color: AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, RxInt selectedFilter) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: colors.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildFilterChip(context, "All", 0, selectedFilter),
            const SizedBox(width: 8),
            _buildFilterChip(context, "Movement", 1, selectedFilter),
            const SizedBox(width: 8),
            _buildFilterChip(context, "Alerts", 2, selectedFilter),
            const SizedBox(width: 8),
            _buildFilterChip(context, "Assignments", 3, selectedFilter),
            const SizedBox(width: 8),
            _buildFilterChip(context, "Submissions", 4, selectedFilter),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    int index,
    RxInt selectedFilter,
  ) {
    final colors = Theme.of(context).colorScheme;
    return Obx(() {
      final isSelected = selectedFilter.value == index;
      return FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          selectedFilter.value = index;
        },
        backgroundColor: colors.surfaceContainerLowest,
        selectedColor: AppColors.primaryGreen,
        checkmarkColor: colors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        labelStyle: TextStyle(
          color: isSelected ? colors.surface : colors.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? Colors.transparent
                : colors.outline.withValues(alpha: 0.3),
          ),
        ),
        showCheckmark: false,
        elevation: isSelected ? 2 : 0,
        pressElevation: 0,
      );
    });
  }

  Widget _buildActivityCard(
    BuildContext context,
    Map<String, dynamic> activity,
  ) {
    final colors = Theme.of(context).colorScheme;
    final iconData = activity['iconData'] ?? _getDefaultIcon(activity['type']);
    final color = activity['color'] ?? _getDefaultColor(activity['type']);
    final title = activity['title'] ?? 'Unknown Activity';
    final subtitle = activity['subtitle'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showActivityDetails(context, activity),
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withValues(alpha: 0.1),
          highlightColor: color.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon with colored background
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(iconData, color: color, size: 22),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                      if (activity['orderId'] != null) ...[
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActivityDetails(
    BuildContext context,
    Map<String, dynamic> activity,
  ) {
    final colors = Theme.of(context).colorScheme;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colors.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Activity Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: colors.onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: () => Get.back(),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: colors.outline.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            _buildDetailRow(context, "Title", activity['title'] ?? ''),
            _buildDetailRow(context, "Description", activity['subtitle'] ?? ''),
            _buildDetailRow(context, "Time", activity['timeAgo'] ?? ''),
            if (activity['orderId'] != null)
              _buildDetailRow(context, "Order ID", activity['orderId']),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
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
                  foregroundColor: colors.surface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "View Full Order",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
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
