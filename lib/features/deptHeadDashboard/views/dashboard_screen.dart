import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/controllers/deptHeadController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeptHeadDashboardScreen extends GetView<DeptHeadController> {
  const DeptHeadDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Obx(
          () => CustomAppBar(
            isDashboard: true,
            isTransparent: true,
            userAvatarUrl: controller.userAvatar.value,
            title: controller.userName.value,
            subtitle: controller.userRole.value,
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.search, color: theme.colorScheme.onSurface),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications_none,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.processedActivities.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshDashboard,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDeptHeader(context),
                      const SizedBox(height: 20),
                      _buildStatCards(context),
                      const SizedBox(height: 20),
                      _buildEfficiencyCard(context),
                      const SizedBox(height: 30),
                      _buildRecentActivityHeader(context),
                      _buildActivityList(context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            const BottomNavBar(currentIndex: 0),
          ],
        );
      }),
    );
  }

  Widget _buildDeptHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            controller.departmentName.value.isEmpty
                ? "Department"
                : controller.departmentName.value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: colors.onSurface,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 4,
                  backgroundColor: AppColors.primaryGreen,
                ),
                const SizedBox(width: 5),
                Text(
                  controller.deptStatus.value.isEmpty
                      ? "Unknown Status"
                      : controller.deptStatus.value,
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context) {
    return Obx(() {
      return Row(
        children: [
          _buildStatTile(
            context,
            "Total Orders",
            controller.totalOrders.value.toString(),
            "Orders Assigned",
            AppColors.primaryGreen,
            icon: Icons.shopping_bag_outlined,
          ),
          const SizedBox(width: 15),
          _buildStatTile(
            context,
            "Active Orders",
            controller.inProgressOrders.value.toString(),
            "In progress now",
            Colors.orange,
            icon: Icons.pending_actions,
            showTrend: false,
          ),
        ],
      );
    });
  }

  Widget _buildStatTile(
    BuildContext context,
    String label,
    String value,
    String subText,
    Color color, {
    IconData? icon,
    IconData? trendIcon,
    bool showTrend = true,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            if (showTrend)
              Row(
                children: [
                  Icon(
                    trendIcon ??
                        (subText.startsWith('+')
                            ? Icons.trending_up
                            : Icons.trending_down),
                    size: 14,
                    color: color,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    subText,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            else
              Text(
                subText,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Use a theme-adaptive background for the card
          gradient: LinearGradient(
            colors: isDark
                ? [
                    colors.primaryContainer,
                    colors.primaryContainer.withValues(alpha: 0.8),
                  ]
                : [AppColors.primaryGreen, const Color(0xFF4CAF50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.green.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Department Performance",
                      style: TextStyle(
                        color: isDark
                            ? colors.onPrimaryContainer.withValues(alpha: 0.7)
                            : Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Efficiency Score",
                      style: TextStyle(
                        color: isDark
                            ? colors.onPrimaryContainer
                            : AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? colors.onSurface.withValues(alpha: 0.1)
                            : AppColors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Quality: ${controller.qualityScore.value}%",
                        style: TextStyle(
                          color: isDark
                              ? colors.onPrimaryContainer
                              : AppColors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                _buildScoreCircle(context),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem(
                  context,
                  "Operations",
                  "${controller.completedOps.value}/${controller.totalOperationsHandled.value}",
                  Icons.checklist,
                ),
                _buildMetricItem(
                  context,
                  "Checkpoints",
                  "${controller.completedCheckpoints.value}/${controller.totalCheckpoints.value}",
                  Icons.task_alt,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCircle(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () => Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 70,
            width: 70,
            child: CircularProgressIndicator(
              value: controller.efficiencyScore.value / 100,
              strokeWidth: 6,
              backgroundColor: isDark
                  ? colors.onPrimaryContainer.withValues(alpha: 0.2)
                  : AppColors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? colors.onPrimaryContainer : Colors.white,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${controller.efficiencyScore.value}",
                style: TextStyle(
                  color: isDark ? colors.onPrimaryContainer : AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "%",
                style: TextStyle(
                  color: isDark
                      ? colors.onPrimaryContainer.withValues(alpha: 0.7)
                      : Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Icon(
          icon,
          color: isDark
              ? colors.onPrimaryContainer.withValues(alpha: 0.7)
              : Colors.white70,
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isDark ? colors.onPrimaryContainer : AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? colors.onPrimaryContainer.withValues(alpha: 0.7)
                : Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Recent Activity",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        GestureDetector(
          onTap: controller.navigateToFullActivityList,
          child: const Text(
            "VIEW ALL",
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityList(BuildContext context) {
    return Obx(() {
      final activities = controller.processedActivities;

      if (controller.isLoading.value && activities.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (activities.isEmpty) {
        final colors = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(
            child: Text(
              "No recent activity",
              style: TextStyle(color: AppColors.grey),
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length > 3 ? 3 : activities.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _buildActivityCard(context, activity);
        },
      );
    });
  }

  Widget _buildActivityCard(
    BuildContext context,
    Map<String, dynamic> activity,
  ) {
    final colors = Theme.of(context).colorScheme;
    final activityType = _getActivityType(activity);
    final iconData = _getActivityIcon(activityType);
    final color = _getActivityTypeColor(activityType);
    final timeAgo = activity['timeAgo'] ?? '';
    final title = activity['title'] ?? '';
    final subtitle = activity['subtitle'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with colored background
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: color, size: 20),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Time
          Text(
            timeAgo,
            softWrap: true,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 10),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String type) {
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

  String _getActivityType(Map<String, dynamic> activity) {
    // Determine activity type based on available data
    if (activity['type'] != null) return activity['type'];

    final action = activity['action'] ?? '';
    final message = activity['message'] ?? '';

    if (message.toLowerCase().contains('material') ||
        message.toLowerCase().contains('alert')) {
      return 'alert';
    }
    if (action == 'ASSIGN' || message.toLowerCase().contains('assigned')) {
      return 'assignment';
    }
    if (action == 'MOVE' || message.toLowerCase().contains('moved')) {
      return 'movement';
    }
    if (action == 'SUBMIT') {
      return 'submission';
    }
    if (action == 'APPROVE') {
      return 'approval';
    }
    if (action == 'REJECT') {
      return 'rejection';
    }

    return 'default';
  }

  Color _getActivityTypeColor(String type) {
    switch (type) {
      case 'movement':
        return Colors.blue;
      case 'alert':
        return Colors.orange;
      case 'assignment':
        return Colors.purple;
      case 'submission':
        return AppColors.primaryGreen;
      case 'approval':
        return Colors.green;
      case 'rejection':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
